/**
 * S3 Hash (Also called 3S - Used by 1Coin)
 */

extern "C" {
#include "sph/sph_skein.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
}

#include "miner.h"
#include "cuda_helper.h"

#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif

extern void x11_shavite512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_shavite512_setBlock_80(int thr_id, void *pdata);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void quark_skein512_cpu_init(int thr_id);
extern void quark_skein512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);
extern void quark_skein512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, uint32_t *h_found, uint32_t target);

/* CPU HASH */
void s3hash(void *output, const void *input)
{
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_skein512_context ctx_skein;

	unsigned char hash[64];

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, input, 80);
	sph_shavite512_close(&ctx_shavite, (void*) hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, (const void*) hash, 64);
	sph_simd512_close(&ctx_simd, (void*) hash);

	sph_skein512_init(&ctx_skein);
	sph_skein512(&ctx_skein, (const void*) hash, 64);
	sph_skein512_close(&ctx_skein, (void*) hash);

	memcpy(output, hash, 32);
}

/* Main S3 entry point */
extern int scanhash_s3(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;
	static THREAD uint32_t *h_found = nullptr;

	const uint32_t first_nonce = pdata[19];
	unsigned int intensity = 20; // 256*256*8*2;
#ifdef WIN32
	// reduce by one the intensity on windows
	intensity--;
#endif
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1 << intensity);
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;
	if (opt_benchmark)
		ptarget[7] = 0x0000000fu;

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

		x11_simd512_cpu_init(thr_id, throughputmax);
		quark_skein512_cpu_init(thr_id);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughputmax));
		CUDA_SAFE_CALL(cudaMallocHost(&(h_found), 2 * sizeof(uint32_t)));

		cuda_check_cpu_init(thr_id, throughputmax);
		mining_has_stopped[thr_id] = false;

		init = true;
	}

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	x11_shavite512_setBlock_80(thr_id, (void*)endiandata);
	cuda_check_cpu_setTarget(ptarget, thr_id);

	do {
		x11_shavite512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash, simdthreads);
		quark_skein512_cpu_hash_64_final(thr_id, throughput, pdata[19], NULL, d_hash, h_found, ptarget[7]);

		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], h_found[0]);
			s3hash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (h_found[1] != 0xffffffff)
				{
					if(opt_verify){ be32enc(&endiandata[19], h_found[1]);
					s3hash(vhash64, endiandata);
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
