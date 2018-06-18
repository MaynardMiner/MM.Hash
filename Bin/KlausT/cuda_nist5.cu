extern "C"
{
#include "sph/sph_blake.h"
#include "sph/sph_groestl.h"
#include "sph/sph_skein.h"
#include "sph/sph_jh.h"
#include "sph/sph_keccak.h"
}

#include "miner.h"

#include "cuda_helper.h"

extern void quark_blake512_cpu_init(int thr_id);
extern void quark_blake512_cpu_setBlock_80(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_setBlock_80_multi(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void quark_blake512_cpu_hash_80_multi(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void quark_groestl512_cpu_init(int thr_id, uint32_t threads);
extern void quark_groestl512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_jh512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_keccak512_cpu_init(int thr_id, uint32_t threads);
extern void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_skein512_cpu_init(int thr_id);
extern void quark_skein512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);
extern void quark_skein512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, uint32_t *h_found, uint32_t target);


// Original nist5hash Funktion aus einem miner Quelltext
void nist5hash(void *state, const void *input)
{
    sph_blake512_context ctx_blake;
    sph_groestl512_context ctx_groestl;
    sph_jh512_context ctx_jh;
    sph_keccak512_context ctx_keccak;
    sph_skein512_context ctx_skein;
    
    uint8_t hash[64];

    sph_blake512_init(&ctx_blake);
    sph_blake512 (&ctx_blake, input, 80);
    sph_blake512_close(&ctx_blake, (void*) hash);
    
    sph_groestl512_init(&ctx_groestl);
    sph_groestl512 (&ctx_groestl, (const void*) hash, 64);
    sph_groestl512_close(&ctx_groestl, (void*) hash);

    sph_jh512_init(&ctx_jh);
    sph_jh512 (&ctx_jh, (const void*) hash, 64);
    sph_jh512_close(&ctx_jh, (void*) hash);

    sph_keccak512_init(&ctx_keccak);
    sph_keccak512 (&ctx_keccak, (const void*) hash, 64);
    sph_keccak512_close(&ctx_keccak, (void*) hash);

    sph_skein512_init(&ctx_skein);
    sph_skein512 (&ctx_skein, (const void*) hash, 64);
    sph_skein512_close(&ctx_skein, (void*) hash);

    memcpy(state, hash, 32);
}

extern int scanhash_nist5(int thr_id, uint32_t *pdata,
    uint32_t *ptarget, uint32_t max_nonce,
    uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;
	static THREAD uint32_t *h_found = nullptr;
	static THREAD uint32_t oldthroughput;

	const uint32_t first_nonce = pdata[19];

	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1 << 19); // 256*256*16
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x0Fu;

	static THREAD volatile bool init = false;
	if(!init)
	{
		oldthroughput = throughput;
		if(throughputmax == 1<<19)
			applog(LOG_INFO, "GPU #%d: using default intensity 19", device_map[thr_id]);
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));
#if defined WIN32 && !defined _WIN64
		// 2GB limit for cudaMalloc
		if(throughput > 0x7fffffffULL / (16 * sizeof(uint32_t)))
		{
			applog(LOG_ERR, "intensity too high");
			mining_has_stopped[thr_id] = true;
			cudaStreamDestroy(gpustream[thr_id]);
			proper_exit(2);
		}
#endif

		// Konstanten kopieren, Speicher belegen
		quark_groestl512_cpu_init(thr_id, throughput);
		quark_skein512_cpu_init(thr_id);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughput));
		CUDA_SAFE_CALL(cudaMallocHost(&(h_found), 2 * sizeof(uint32_t)));

//		cuda_check_cpu_init(thr_id, throughput);
		mining_has_stopped[thr_id] = false;
		init = true;
	}
	if(throughput > oldthroughput)
	{
		oldthroughput = throughput;
		CUDA_SAFE_CALL(cudaFree(d_hash));
		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughput));
	}

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	quark_blake512_cpu_setBlock_80(thr_id, (uint64_t *)endiandata);
//	cuda_check_cpu_setTarget(ptarget, thr_id);

	do {

		// Hash with CUDA
		quark_blake512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		quark_groestl512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_jh512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_keccak512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_skein512_cpu_hash_64_final(thr_id, throughput, pdata[19], NULL, d_hash, h_found, ptarget[7]);

		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], h_found[0]);
			nist5hash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (h_found[1] != 0xffffffff)
				{
					if(opt_verify){ be32enc(&endiandata[19], h_found[1]);
					nist5hash(vhash64, endiandata);
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
