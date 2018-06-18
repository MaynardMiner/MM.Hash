/*
 * qubit algorithm
 *
 */
extern "C" {
#include "sph/sph_luffa.h"
}

#include "miner.h"

#include "cuda_helper.h"

extern void qubit_luffa512_cpu_init(int thr_id, uint32_t threads);
extern void qubit_luffa512_cpu_setBlock_80(int thr_id, void *pdata);
extern void qubit_luffa512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void qubit_luffa512_cpufinal_setBlock_80(int thr_id, void *pdata, const void *ptarget);
extern uint32_t qubit_luffa512_cpu_finalhash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void doomhash(void *state, const void *input)
{
	// luffa512
	sph_luffa512_context ctx_luffa;

	uint8_t hash[64];

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512 (&ctx_luffa, input, 80);
	sph_luffa512_close(&ctx_luffa, (void*) hash);

	memcpy(state, hash, 32);
}

extern int scanhash_doom(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;

	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1U << 22); // 256*256*8*8
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x0000f;

	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == 1<<22)
			applog(LOG_INFO, "GPU #%d: using default intensity 22", device_map[thr_id]);
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

		qubit_luffa512_cpu_init(thr_id, (int) throughputmax);
		mining_has_stopped[thr_id] = false;

		init = true;
	}

	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	qubit_luffa512_cpufinal_setBlock_80(thr_id, (void*)endiandata,ptarget);

	do {

		uint32_t foundNonce = qubit_luffa512_cpu_finalhash_80(thr_id, (int) throughput, pdata[19], d_hash);
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNonce != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify){ be32enc(&endiandata[19], foundNonce);
			doomhash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget)) {
				*hashes_done = min(max_nonce - first_nonce, (uint64_t) pdata[19] - first_nonce + throughput);
				pdata[19] = foundNonce;
				return 1;
			}
			else {
				applog(LOG_INFO, "GPU #%d: result for nonce $%08X does not validate on CPU!", device_map[thr_id], foundNonce);
			}
		}

		pdata[19] += throughput; CUDA_SAFE_CALL(cudaGetLastError());
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
