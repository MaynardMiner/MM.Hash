
#include <string.h>
#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif
#include <openssl/sha.h>

#include "sph/sph_groestl.h"
#include "cuda_groestlcoin.h"

#include "miner.h"
#include <cuda.h>
#include <cuda_runtime.h>
extern bool stop_mining;
extern volatile bool mining_has_stopped[MAX_GPUS];

#define CUDA_SAFE_CALL(call)                                          \
do {                                                                  \
	cudaError_t err = call;                                           \
	if (cudaSuccess != err) {                                         \
		fprintf(stderr, "Cuda error in func '%s' at line %i : %s.\n", \
		         __FUNCTION__, __LINE__, cudaGetErrorString(err) );   \
		proper_exit(EXIT_FAILURE);                                           \
		}                                                                 \
} while (0)

#define SWAP32(x) swab32(x)

// CPU-groestl
void groestlhash(void *state, const void *input)
{
    sph_groestl512_context ctx_groestl;

    //these uint512 in the c++ source of the client are backed by an array of uint32
    uint32_t hashA[16], hashB[16];

    sph_groestl512_init(&ctx_groestl);
    sph_groestl512 (&ctx_groestl, input, 80); //6
    sph_groestl512_close(&ctx_groestl, hashA); //7

    sph_groestl512_init(&ctx_groestl);
    sph_groestl512 (&ctx_groestl, hashA, 64); //6
    sph_groestl512_close(&ctx_groestl, hashB); //7

    memcpy(state, hashB, 32);
}

extern cudaStream_t gpustream[MAX_GPUS];

extern int scanhash_groestlcoin(int thr_id, uint32_t *pdata, uint32_t *ptarget,
    uint32_t max_nonce, uint32_t *hashes_done)
{
	static THREAD uint32_t *foundNounce = nullptr;

    uint32_t start_nonce = pdata[19];
	unsigned int intensity = (device_sm[device_map[thr_id]] > 500) ? 24 : 23;
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1U << intensity);
	uint32_t throughput = min(throughputmax, max_nonce - start_nonce) & 0xfffffc00;

    if (opt_benchmark)
        ptarget[7] = 0x0000000f;

    // init
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

		groestlcoin_cpu_init(thr_id, throughputmax);
		CUDA_SAFE_CALL(cudaMallocHost(&foundNounce, 2 * 4));
		mining_has_stopped[thr_id] = false;
		init = true;
    }

    // Endian Drehung ist notwendig
    uint32_t endiandata[32];
    for (int kk=0; kk < 32; kk++)
        be32enc(&endiandata[kk], pdata[kk]);

    // Context mit dem Endian gedrehten Blockheader vorbereiten (Nonce wird später ersetzt)
    groestlcoin_cpu_setBlock(thr_id, endiandata);

	do
	{
		// GPU
		const uint32_t Htarg = ptarget[7];

		groestlcoin_cpu_hash(thr_id, throughput, pdata[19], foundNounce, ptarget[7]);

		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNounce[0] < 0xffffffff)
		{
			uint32_t tmpHash[8];
			endiandata[19] = SWAP32(foundNounce[0]);
			groestlhash(tmpHash, endiandata);

			if(tmpHash[7] <= Htarg && fulltest(tmpHash, ptarget))
			{
				int res = 1;
				if(opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", device_map[thr_id], foundNounce[0]);
				*hashes_done = pdata[19] - start_nonce + throughput;
				if(foundNounce[1] != 0xffffffff)
				{
					endiandata[19] = SWAP32(foundNounce[1]);
					groestlhash(tmpHash, endiandata);
					if(tmpHash[7] <= Htarg && fulltest(tmpHash, ptarget))
					{
						pdata[21] = foundNounce[1];
						res++;
						if(opt_benchmark)
							applog(LOG_INFO, "GPU #%d Found second nounce %08x", device_map[thr_id], foundNounce[1]);
					}
					else
					{
						if(tmpHash[7] != Htarg)
						{
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNounce[1]);
						}
					}
				}
				pdata[19] = foundNounce[0];
				return res;
			}
			else
			{
				if(tmpHash[7] != Htarg)
				{
					applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNounce[0]);
				}
			}
		}

		pdata[19] += throughput;
		cudaError_t err = cudaGetLastError();
		if(err != cudaSuccess)
		{
			applog(LOG_ERR, "GPU #%d: %s", device_map[thr_id], cudaGetErrorString(err));
			proper_exit(EXIT_FAILURE);
		}
	} while(!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

    *hashes_done = pdata[19] - start_nonce;
    return 0;
}

