#include <string.h>
#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif
#include <openssl/sha.h>

#include "sph/sph_groestl.h"

#include "miner.h"
#include <cuda_runtime.h>
extern bool stop_mining;
extern volatile bool mining_has_stopped[MAX_GPUS];

void myriadgroestl_cpu_init(int thr_id, uint32_t threads);
void myriadgroestl_cpu_setBlock(int thr_id, void *data, void *pTargetIn);
void myriadgroestl_cpu_hash(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *nounce);

void myriadhash(void *state, const void *input)
{
	uint32_t hashA[16], hashB[16];
	sph_groestl512_context ctx_groestl;
	SHA256_CTX sha256;

	sph_groestl512_init(&ctx_groestl);
	sph_groestl512 (&ctx_groestl, input, 80);
	sph_groestl512_close(&ctx_groestl, hashA);

	SHA256_Init(&sha256);
	SHA256_Update(&sha256,(unsigned char *)hashA, 64);
	SHA256_Final((unsigned char *)hashB, &sha256);

	memcpy(state, hashB, 32);
}

extern int scanhash_myriad(int thr_id, uint32_t *pdata, uint32_t *ptarget,
	uint32_t max_nonce, uint32_t *hashes_done)
{
	static THREAD uint32_t *h_found = nullptr;

	uint32_t start_nonce = pdata[19];
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1 << 19);
	uint32_t throughput = min(throughputmax, max_nonce - start_nonce) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x0000ff;

	// init
	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == 1<<19)
			applog(LOG_INFO, "GPU #%d: using default intensity 19", device_map[thr_id]);
#if BIG_DEBUG
#else
#if defined WIN32 && !defined _WIN64
		// 2GB limit for cudaMalloc
		if(throughputmax > 0x7fffffffULL / (16 * sizeof(uint32_t)))
		{
			applog(LOG_ERR, "intensity too high");
			mining_has_stopped[thr_id] = true;
			proper_exit(2);
		}
#endif
		myriadgroestl_cpu_init(thr_id, throughputmax);
#endif
		cudaMallocHost(&h_found, 4 * sizeof(uint32_t));
		mining_has_stopped[thr_id] = false;
		init = true;
	}

	uint32_t endiandata[32];
	for (int kk=0; kk < 32; kk++)
		be32enc(&endiandata[kk], pdata[kk]);

	// Context mit dem Endian gedrehten Blockheader vorbereiten (Nonce wird später ersetzt)
	myriadgroestl_cpu_setBlock(thr_id, endiandata, (void*)ptarget);

	do {
		const uint32_t Htarg = ptarget[7];

		myriadgroestl_cpu_hash(thr_id, throughput, pdata[19], h_found);

		if(stop_mining) {mining_has_stopped[thr_id] = true; pthread_exit(nullptr);}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], h_found[0]);
			myriadhash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - start_nonce + throughput;
				if (h_found[1] != 0xffffffff)
				{
					if(opt_verify){ be32enc(&endiandata[19], h_found[1]);
					myriadhash(vhash64, endiandata);
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
		pdata[19] += throughput;
		cudaError_t err = cudaGetLastError();
		if (err != cudaSuccess)
		{
			applog(LOG_ERR, "GPU #%d: %s", device_map[thr_id], cudaGetErrorString(err));
			proper_exit(EXIT_FAILURE);
		}
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - start_nonce;
	return 0;
}

