/*
 * whirlpool routine djm&SP
 */
extern "C"
{
#include "sph/sph_whirlpool.h"
}
#include "miner.h"
#include "cuda_helper.h"

extern void x15_whirlpool_cpu_init(int thr_id, uint32_t threads, int mode);
extern void x15_whirlpool_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce,  uint32_t *d_hash);

extern void whirlpool512_setBlock_80(int thr_id, void *pdata, const void *ptarget);
extern void whirlpool512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern uint32_t* whirlpool512_cpu_finalhash_64(int thr_id, uint32_t threads, uint32_t startNounce,  uint32_t *d_hash);


// CPU Hash function
void wcoinhash(void *state, const void *input)
{
	sph_whirlpool_context ctx_whirlpool;

	unsigned char hash[128]; // uint32_t hashA[16], hashB[16];
	#define hashB hash+64

	memset(hash, 0, sizeof hash);

	// shavite 1
	sph_whirlpool1_init(&ctx_whirlpool);
	sph_whirlpool1(&ctx_whirlpool, input, 80);
	sph_whirlpool1_close(&ctx_whirlpool, hash);

	sph_whirlpool1_init(&ctx_whirlpool);
	sph_whirlpool1(&ctx_whirlpool, hash, 64);
	sph_whirlpool1_close(&ctx_whirlpool, hashB);

	sph_whirlpool1_init(&ctx_whirlpool);
	sph_whirlpool1(&ctx_whirlpool, hashB, 64);
	sph_whirlpool1_close(&ctx_whirlpool, hash);

	sph_whirlpool1_init(&ctx_whirlpool);
	sph_whirlpool1(&ctx_whirlpool, hash, 64);
	sph_whirlpool1_close(&ctx_whirlpool, hash);

	memcpy(state, hash, 32);
}

extern int scanhash_whc(int thr_id, uint32_t *pdata,
    uint32_t *ptarget, uint32_t max_nonce,
    uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;

	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1U << 20); // 19=256*256*8;
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x0000ff;

	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == 1<<20)
			applog(LOG_INFO, "GPU #%d: using default intensity 20", device_map[thr_id]);
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
		x15_whirlpool_cpu_init(thr_id, throughputmax, 1 /* old whirlpool */);
		mining_has_stopped[thr_id] = false;

		init = true;
	}

	for (int k=0; k < 20; k++) {
		be32enc(&endiandata[k], pdata[k]);
	}

	whirlpool512_setBlock_80(thr_id, (void*)endiandata, ptarget);

	do {
		uint32_t* foundNonce;

		whirlpool512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		x15_whirlpool_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x15_whirlpool_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);

		foundNonce = whirlpool512_cpu_finalhash_64(thr_id, throughput, pdata[19],  d_hash);
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNonce[0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], foundNonce[0]);
			wcoinhash(vhash64, endiandata);
			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundNonce[1] != UINT32_MAX)
				{
					if(opt_verify){ be32enc(&endiandata[19], foundNonce[1]);
					wcoinhash(vhash64, endiandata);
					} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{

						if (opt_benchmark) applog(LOG_INFO, "GPU #%d: found second nounce %08x", device_map[thr_id], foundNonce[1]);
						pdata[21] = foundNonce[1];
						res++;
					}
					else
					{
						if (vhash64[7] != Htarg)
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNonce[1]);
					}
				}
				pdata[19] = foundNonce[0];
				if (opt_benchmark) applog(LOG_INFO, "GPU #%d: found nounce %08x", device_map[thr_id], foundNonce[0]);

				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
					applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNonce[0]);
			}
		}
		pdata[19] += throughput; CUDA_SAFE_CALL(cudaGetLastError());
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
