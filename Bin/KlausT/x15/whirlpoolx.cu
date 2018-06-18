/*
 * whirlpool routine (djm)
 * whirlpoolx routine (provos alexis)
 */
extern "C"
{
#include "sph/sph_whirlpool.h"
}
#include "miner.h"


#include "cuda_helper.h"

extern void whirlpoolx_cpu_init(int thr_id, uint32_t threads);
extern void whirlpoolx_setBlock_80(int thr_id, void *pdata, const void *ptarget);
extern void cpu_whirlpoolx(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *foundNonce);
extern void whirlpoolx_precompute(int thr_id);

// CPU Hash function
extern "C" void whirlxHash(void *state, const void *input)
{

	sph_whirlpool_context ctx_whirlpool;

	unsigned char hash[64];
	unsigned char hash_xored[32];

	memset(hash, 0, sizeof(hash));

	sph_whirlpool_init(&ctx_whirlpool);
	sph_whirlpool(&ctx_whirlpool, input, 80);
	sph_whirlpool_close(&ctx_whirlpool, hash);

    
	for (uint32_t i = 0; i < 32; i++){
	        hash_xored[i] = hash[i] ^ hash[i + 16];
	}
	memcpy(state, hash_xored, 32);
}

int scanhash_whirlpoolx(int thr_id, uint32_t *pdata, uint32_t *ptarget, uint32_t max_nonce, uint32_t *hashes_done)
{
	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, (1 << 27));
	uint32_t throughput = min(throughputmax, max_nonce - first_nonce) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x5;

	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == 1<<27)
			applog(LOG_INFO, "GPU #%d: using default intensity 27", device_map[thr_id]);
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));
		whirlpoolx_cpu_init(thr_id, throughputmax);
		mining_has_stopped[thr_id] = false;
		init = true;
	}

	for (int k=0; k < 20; k++)
	{
		be32enc(&endiandata[k], pdata[k]);
	}

	whirlpoolx_setBlock_80(thr_id, (void*)endiandata, &ptarget[6]);
	whirlpoolx_precompute(thr_id);
	do {
		uint32_t foundNonce[2];
		cpu_whirlpoolx(thr_id, throughput, pdata[19], foundNonce);
		CUDA_SAFE_CALL(cudaGetLastError());
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNonce[0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			/* check now with the CPU to confirm */
			if(opt_verify){ be32enc(&endiandata[19], foundNonce[0]);
			whirlxHash(vhash64, endiandata);
			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundNonce[1] != UINT32_MAX)
				{
					if(opt_verify){ be32enc(&endiandata[19], foundNonce[1]);
					whirlxHash(vhash64, endiandata);
					} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{
						pdata[21] = foundNonce[1];
						res++;
						if (opt_benchmark) applog(LOG_INFO, "GPU #%d: found nonce %08x", device_map[thr_id], foundNonce[1]);
					}
					else
					{
						if (vhash64[7] != Htarg)
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNonce[1]);
					}
				}
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d: found nonce %08x", device_map[thr_id], foundNonce[0], vhash64[7]);
				pdata[19] = foundNonce[0];
				return res;
			}
			else
			{
				if(vhash64[7] != Htarg)
					applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNonce[0]);
			}
		}
		pdata[19] += throughput;
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));
	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
