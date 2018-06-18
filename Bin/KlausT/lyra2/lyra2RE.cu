extern "C" {
#include "sph/sph_blake.h"
#include "sph/sph_groestl.h"
#include "sph/sph_skein.h"
#include "sph/sph_keccak.h"
#include "lyra2/Lyra2.h"
}

#include "miner.h"
#include "cuda_helper.h"
#include <cuda_profiler_api.h>
static _ALIGN(64) uint64_t *d_hash[MAX_GPUS];
static THREAD uint32_t *foundNonce;


extern void blake256_cpu_hash_80(const int thr_id, const uint32_t threads, const uint32_t startNonce, uint64_t *Hash);
extern void blake256_cpu_setBlock_80(int thr_id, uint32_t *pdata);
extern void keccak256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);
extern void keccak256_cpu_init(int thr_id, uint32_t threads);
extern void skein256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);
extern void skein256_cpu_init(int thr_id, uint32_t threads);

extern void lyra2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);
extern void lyra2_cpu_hash_32_multi(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);

extern void groestl256_setTarget(int thr_id, const void *ptarget);
extern void lyra2_cpu_init(int thr_id, uint32_t threads);
extern void lyra2_cpu_init_multi(int thr_id, uint32_t threads, uint64_t *hash, uint64_t* hash2);
extern void groestl256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_outputHash, uint32_t *resultnonces);
extern void groestl256_cpu_init(int thr_id, uint32_t threads);

extern "C" void lyra2_hash(void *state, const void *input)
{
	sph_blake256_context     ctx_blake;
	sph_keccak256_context    ctx_keccak;
	sph_skein256_context     ctx_skein;
	sph_groestl256_context   ctx_groestl;

	uint32_t hashA[8], hashB[8];

	sph_blake256_init(&ctx_blake);
	sph_blake256(&ctx_blake, input, 80);
	sph_blake256_close(&ctx_blake, hashA);

	sph_keccak256_init(&ctx_keccak);
	sph_keccak256(&ctx_keccak, hashA, 32);
	sph_keccak256_close(&ctx_keccak, hashB);

	LYRA2_old(hashA, 32, hashB, 32, hashB, 32, 1, 8, 8);
	sph_skein256_init(&ctx_skein);
	sph_skein256(&ctx_skein, hashA, 32);
	sph_skein256_close(&ctx_skein, hashB);

	sph_groestl256_init(&ctx_groestl);
	sph_groestl256(&ctx_groestl, hashB, 32);
	sph_groestl256_close(&ctx_groestl, hashA);

	memcpy(state, hashA, 32);
}

static volatile bool init[MAX_GPUS] = { false };

extern int scanhash_lyra2(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	const uint32_t first_nonce = pdata[19];
	unsigned int intensity = (device_sm[device_map[thr_id]] > 500) ? 256 * 256 * 4 : 256 * 256 * 4 ;
    intensity = (device_sm[device_map[thr_id]] == 500) ? 256 * 256 * 2 : intensity;
	uint32_t throughput = device_intensity(device_map[thr_id], __func__, intensity); // 18=256*256*4;
	

	if (opt_benchmark)
		ptarget[7] = 0x00ff;

	
	if(!init[thr_id])
	{ 
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));
		CUDA_SAFE_CALL(cudaProfilerStop());
		CUDA_SAFE_CALL(cudaMallocHost(&foundNonce, 2 * 4));
		CUDA_SAFE_CALL(cudaMalloc(&d_hash[thr_id], 8 * sizeof(uint32_t) * throughput));
		keccak256_cpu_init(thr_id, throughput);
		skein256_cpu_init(thr_id, throughput);
		groestl256_cpu_init(thr_id, throughput);
		lyra2_cpu_init(thr_id, throughput);

		init[thr_id] = true; 
	}
	else
		CUDA_SAFE_CALL(cudaProfilerStart());

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	blake256_cpu_setBlock_80(thr_id, pdata);
	groestl256_setTarget(thr_id, ptarget);
	do {
		blake256_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]);
		keccak256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		lyra2_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		skein256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		groestl256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], foundNonce);
		CUDA_SAFE_CALL(cudaGetLastError());
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNonce[0] != 0)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[19], foundNonce[0]);
			lyra2_hash(vhash64, endiandata);
			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				// check if there was some other ones...
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundNonce[1] != 0)
				{
					be32enc(&endiandata[19], foundNonce[1]);
					lyra2_hash(vhash64, endiandata);

					if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{
						pdata[21] = foundNonce[1];
						res++;
						if (opt_benchmark)  applog(LOG_INFO, "GPU #%d: Found second nounce %08x", device_map[thr_id], foundNonce[1]);
					}
					else
					{
						if (vhash64[7] != Htarg) // don't show message if it is equal but fails fulltest
							applog(LOG_WARNING, "GPU #%d: result %08x does not validate on CPU!", device_map[thr_id], foundNonce[1]);
					}
				}
				pdata[19] = foundNonce[0];
				if (opt_benchmark) applog(LOG_INFO, "GPU #%d: Found nounce %08x", device_map[thr_id], foundNonce[0]);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg) // don't show message if it is equal but fails fulltest
					applog(LOG_WARNING, "GPU #%d: result %08x does not validate on CPU!", device_map[thr_id], foundNonce[0]);
			}
		}

		pdata[19] += throughput;

	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce + 1;
	return 0;
}
