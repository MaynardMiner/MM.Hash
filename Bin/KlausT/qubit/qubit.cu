/*
 * qubit algorithm
 *
 */
extern "C" {
#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"
}

#include "miner.h"
#include "cuda_helper.h"

extern void qubit_luffa512_cpu_init(int thr_id, uint32_t threads);
extern void qubit_luffa512_cpu_setBlock_80(int thr_id, void *pdata);
extern void qubit_luffa512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_cubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_shavite512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern int x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash,const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
//extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *d_hash, uint32_t target, uint32_t *h_found);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *inpHashes,
											const uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

void qubithash(void *state, const void *input)
{
	// luffa1-cubehash2-shavite3-simd4-echo5

	sph_luffa512_context ctx_luffa;
	sph_cubehash512_context ctx_cubehash;
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_echo512_context ctx_echo;

	uint8_t hash[64];

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512 (&ctx_luffa, input, 80);
	sph_luffa512_close(&ctx_luffa, (void*) hash);

	sph_cubehash512_init(&ctx_cubehash);
	sph_cubehash512 (&ctx_cubehash, (const void*) hash, 64);
	sph_cubehash512_close(&ctx_cubehash, (void*) hash);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512 (&ctx_shavite, (const void*) hash, 64);
	sph_shavite512_close(&ctx_shavite, (void*) hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512 (&ctx_simd, (const void*) hash, 64);
	sph_simd512_close(&ctx_simd, (void*) hash);

	sph_echo512_init(&ctx_echo);
	sph_echo512 (&ctx_echo, (const void*) hash, 64);
	sph_echo512_close(&ctx_echo, (void*) hash);

	memcpy(state, hash, 32);
}

extern int scanhash_qubit(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;
	static THREAD uint32_t *h_found = nullptr;

	uint32_t endiandata[20];
	const uint32_t first_nonce = pdata[19];

	uint32_t intensity = 256 * 256 * 10;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;

	cudaDeviceProp props;
	cudaGetDeviceProperties(&props, device_map[thr_id]);
	if(strstr(props.name, "1080"))
	{
		intensity = 256 * 256 * 24;
	}
	else if(strstr(props.name, "1070"))
	{
		intensity = 256 * 256 * 24;
	}
	else if(strstr(props.name, "970"))
	{
		intensity = 256 * 256 * 16;
	}
	else if (strstr(props.name, "980"))
	{
		intensity = 256 * 256 * 24;
	}
	else if (strstr(props.name, "750 Ti"))
	{
		intensity = 256 * 256 * 12;
	}
	else if (strstr(props.name, "750"))
	{
		intensity = 256 * 256 * 10;
	}
	else if (strstr(props.name, "960"))
	{
		intensity = 256 * 256 * 16;
	}
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, intensity);
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x0000ff;

	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == intensity)
			applog(LOG_INFO, "GPU #%d: using default intensity %.3f", device_map[thr_id], throughput2intensity(throughputmax));
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));

#if defined WIN32 && !defined _WIN64
		// 2GB limit for cudaMalloc
		if(throughputmax > 0x7fffffffULL / (64 * sizeof(uint4)))
		{
			applog(LOG_ERR, "intensity too high");
			mining_has_stopped[thr_id] = true;
			cudaStreamDestroy(gpustream[thr_id]);
			proper_exit(2);
		}
#endif

		qubit_luffa512_cpu_init(thr_id, throughputmax);
		x11_simd512_cpu_init(thr_id, throughputmax);
		x11_echo512_cpu_init(thr_id, throughputmax);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughputmax));
		CUDA_SAFE_CALL(cudaMallocHost(&(h_found), 4 * sizeof(uint32_t)));
		mining_has_stopped[thr_id] = false;

		init = true;
	}

	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	qubit_luffa512_cpu_setBlock_80(thr_id, (void*)endiandata);

	do {

		// Hash with CUDA
		qubit_luffa512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		x11_cubehash512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_simd512_cpu_hash_64(thr_id,throughput, pdata[19], d_hash,simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash, ptarget[7], h_found);
		cudaStreamSynchronize(gpustream[thr_id]);
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], h_found[0]);
			qubithash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (h_found[1] != 0xffffffff)
				{
					if(opt_verify){ be32enc(&endiandata[19], h_found[1]);
					qubithash(vhash64, endiandata);
					} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{

						pdata[21] = h_found[1];
						res++;
						if (opt_benchmark)
							applog(LOG_INFO, "GPU #%d Found second nounce %08x", device_map[thr_id], h_found[1]);
					}
					else
					{
						if (vhash64[7] != Htarg)
						{
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], h_found[1]);
						}
					}

				}
				pdata[19] = h_found[0];
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", device_map[thr_id], h_found[0]);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
				{
					applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], h_found[0]);
				}
			}
		}
		pdata[19] += throughput; CUDA_SAFE_CALL(cudaGetLastError());
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
