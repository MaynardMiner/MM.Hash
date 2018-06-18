/**
* SKEIN512 80 + SHA256 64
* by tpruvot@github - 2015
* Optimized by sp-hash@github - 2015
*/

extern "C" {
#include "sph/sph_skein.h"
}

#include "miner.h"
#include "cuda_helper.h"
#include <openssl/sha.h>

extern void skein512_cpu_setBlock_80(int thr_id,void *pdata);
extern void skein512_cpu_hash_80_6x(int thr_id, uint32_t threads, uint32_t startNounce, int swapu, uint64_t target, uint32_t *h_found);
extern void skein512_cpu_hash_80_50(int thr_id, uint32_t threads, uint32_t startNounce, int swapu, uint64_t target, uint32_t *h_found);
extern void skein512_cpu_hash_80_52(int thr_id, uint32_t threads, uint32_t startNounce, int swapu, uint64_t target, uint32_t *h_found);

void skeincoinhash(void *output, const void *input)
{
	sph_skein512_context ctx_skein;
	SHA256_CTX sha256;

	uint32_t hash[16];

	sph_skein512_init(&ctx_skein);
	sph_skein512(&ctx_skein, input, 80);
	sph_skein512_close(&ctx_skein, hash);

	SHA256_Init(&sha256);
	SHA256_Update(&sha256, (unsigned char *)hash, 64);
	SHA256_Final((unsigned char *)hash, &sha256);

	memcpy(output, hash, 32);
}

static __inline uint32_t swab32_if(uint32_t val, bool iftrue)
{
	return iftrue ? swab32(val) : val;
}

int scanhash_skeincoin(int thr_id, uint32_t *pdata,
								  uint32_t *ptarget, uint32_t max_nonce,
								  uint32_t *hashes_done)
{
	static THREAD uint32_t *foundnonces = nullptr;

	const uint32_t first_nonce = pdata[19];
	const int swap = 1;

	uint32_t intensity = (device_sm[device_map[thr_id]] > 500) ? 1 << 28 : 1 << 27;;
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, intensity); // 256*4096
	uint32_t throughput = min(throughputmax, max_nonce - first_nonce) & 0xfffffc00;

	if (opt_benchmark)
	{
		((uint64_t*)ptarget)[3] = 0x3000f0000;
	}
	uint64_t target = ((uint64_t*)ptarget)[3];

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
		CUDA_SAFE_CALL(cudaMallocHost(&foundnonces, 2 * 4));
		mining_has_stopped[thr_id] = false;
		init = true;
	}

	uint32_t endiandata[20];
	for (int k = 0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	skein512_cpu_setBlock_80(thr_id, (void*)endiandata);
	do
	{
		*hashes_done = pdata[19] - first_nonce + throughput;

		if(device_sm[device_map[thr_id]] >= 600)
			skein512_cpu_hash_80_6x(thr_id, throughput, pdata[19], swap, target, foundnonces);
		else
			if(device_sm[device_map[thr_id]] > 500)
				skein512_cpu_hash_80_52(thr_id, throughput, pdata[19], swap, target, foundnonces);
			else
				skein512_cpu_hash_80_50(thr_id, throughput, pdata[19], swap, target, foundnonces);

		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundnonces[0] != 0xffffffff)
		{
			uint32_t vhash64[8]={0};

			endiandata[19] = swab32_if(foundnonces[0], swap);
			
			skeincoinhash(vhash64, endiandata);

			uint64_t test = ((uint64_t*)vhash64)[3];
			if (test <= target && fulltest(vhash64, ptarget))
			{
				int res = 1;
				if (opt_debug || opt_benchmark)
					applog(LOG_INFO, "GPU #%d: found nonce $%08X", device_map[thr_id], foundnonces[0]);
				if (foundnonces[1] != 0xffffffff)
				{
					endiandata[19] = swab32_if(foundnonces[1], swap);
					skeincoinhash(vhash64, endiandata);
					uint64_t test2 = ((uint64_t*)vhash64)[3];
					if (test2 <= target && fulltest(vhash64, ptarget))
					{
						if (opt_debug || opt_benchmark)
							applog(LOG_INFO, "GPU #%d: found nonce $%08X", device_map[thr_id], foundnonces[1]);
						pdata[19 + res] = swab32_if(foundnonces[1], !swap);
						res++;
					}
					else
					{
						if (test2 != target) applog(LOG_WARNING, "GPU #%d: result for nonce $%08X does not validate on CPU!", device_map[thr_id], foundnonces[1]);
					}
				}
				pdata[19] = swab32_if(foundnonces[0], !swap);
				return res;
			}
			else 
			{
				if (test != target)
					applog(LOG_WARNING, "GPU #%d: result for nonce $%08X does not validate on CPU!", device_map[thr_id], foundnonces[0]);
				else
					applog(LOG_WARNING, "Lost work: #%d", test);

			}
		}

		pdata[19] += throughput;

	} while(!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
