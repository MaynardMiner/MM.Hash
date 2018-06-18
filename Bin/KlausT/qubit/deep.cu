/*
 * deepcoin algorithm
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
extern void qubit_luffa512_cpufinal_setBlock_80(int thr_id, void *pdata, const void *ptarget);
extern uint32_t qubit_luffa512_cpu_finalhash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_cubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *d_hash, uint32_t target, uint32_t *h_found);

void deephash(void *state, const void *input)
{
	// luffa1-cubehash2-shavite3-simd4-echo5
	sph_luffa512_context ctx_luffa;
	sph_cubehash512_context ctx_cubehash;
	sph_echo512_context ctx_echo;

	uint8_t hash[64];

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512 (&ctx_luffa, input, 80);
	sph_luffa512_close(&ctx_luffa, (void*) hash);

	sph_cubehash512_init(&ctx_cubehash);
	sph_cubehash512 (&ctx_cubehash, (const void*) hash, 64);
	sph_cubehash512_close(&ctx_cubehash, (void*) hash);

	sph_echo512_init(&ctx_echo);
	sph_echo512 (&ctx_echo, (const void*) hash, 64);
	sph_echo512_close(&ctx_echo, (void*) hash);

	memcpy(state, hash, 32);
}

extern int scanhash_deep(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;
	static THREAD uint32_t *h_found = nullptr;

	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1U << 19); // 256*256*8
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x00ff;

	static THREAD volatile bool init = false;
	if (!init)
	{
		if(throughputmax == 1<<19)
			applog(LOG_INFO, "GPU #%d: using default intensity 19", device_map[thr_id]);
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));
#if defined WIN32 && !defined _WIN64
		// 2GB limit for cudaMalloc
		if(throughputmax > 0x7fffffffULL / (16 * sizeof(uint32_t)))
		{
			applog(LOG_ERR, "intensity too high");
			mining_has_stopped[thr_id] = true;
			cudaStreamDestroy(gpustream[thr_id]);
			proper_exit(2);
		}
#endif

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughputmax));

		qubit_luffa512_cpu_init(thr_id, throughputmax);
		x11_echo512_cpu_init(thr_id, throughputmax);
		CUDA_SAFE_CALL(cudaMallocHost(&(h_found), 4 * sizeof(uint32_t)));

		cuda_check_cpu_init(thr_id, throughputmax);
		mining_has_stopped[thr_id] = false;

		init = true;
	}

	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	qubit_luffa512_cpufinal_setBlock_80(thr_id, (void*)endiandata,ptarget);
	cuda_check_cpu_setTarget(ptarget, thr_id);

	do {

		qubit_luffa512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		x11_cubehash512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash, ptarget[7], h_found);
		cudaStreamSynchronize(gpustream[thr_id]);
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], h_found[0]);
			deephash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (h_found[1] != 0xffffffff)
				{
					if(opt_verify){ be32enc(&endiandata[19], h_found[1]);
					deephash(vhash64, endiandata);
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
