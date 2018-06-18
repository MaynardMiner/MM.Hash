/*
 * X15 algorithm (CHC, BBC, X15C)
 * Added in ccminer by Tanguy Pruvot - 2014
 */

extern "C" {
#include "sph/sph_blake.h"
#include "sph/sph_bmw.h"
#include "sph/sph_groestl.h"
#include "sph/sph_skein.h"
#include "sph/sph_jh.h"
#include "sph/sph_keccak.h"

#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"

#include "sph/sph_hamsi.h"
#include "sph/sph_fugue.h"
#include "sph/sph_shabal.h"
#include "sph/sph_whirlpool.h"
}

#include "miner.h"

#include "cuda_helper.h"

extern void quark_blake512_cpu_init(int thr_id);
extern void quark_blake512_cpu_setBlock_80(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_setBlock_80_multi(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void quark_blake512_cpu_hash_80_multi(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void quark_bmw512_cpu_init(int thr_id, uint32_t threads);
extern void quark_bmw512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_groestl512_cpu_init(int thr_id, uint32_t threads);
extern void quark_groestl512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_skein512_cpu_init(int thr_id);
extern void quark_skein512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_jh512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void x11_luffaCubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce,  uint32_t *d_hash);

extern void x11_shavite512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x13_hamsi512_cpu_init(int thr_id, uint32_t threads);
extern void x13_hamsi512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x13_fugue512_cpu_init(int thr_id, uint32_t threads);
extern void x13_fugue512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x14_shabal512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x15_whirlpool_cpu_init(int thr_id, uint32_t threads, int mode);
extern void x15_whirlpool_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x15_whirlpool_cpu_free(int thr_id);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *inpHashes,
											const uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

// X15 CPU Hash function
void x15hash(void *output, const void *input)
{
	sph_blake512_context     ctx_blake;
	sph_bmw512_context       ctx_bmw;
	sph_groestl512_context   ctx_groestl;
	sph_jh512_context        ctx_jh;
	sph_keccak512_context    ctx_keccak;
	sph_skein512_context     ctx_skein;
	sph_luffa512_context     ctx_luffa;
	sph_cubehash512_context  ctx_cubehash;
	sph_shavite512_context   ctx_shavite;
	sph_simd512_context      ctx_simd;
	sph_echo512_context      ctx_echo;
	sph_hamsi512_context     ctx_hamsi;
	sph_fugue512_context     ctx_fugue;
	sph_shabal512_context    ctx_shabal;
	sph_whirlpool_context    ctx_whirlpool;

	unsigned char hash[128]; // uint32_t hashA[16], hashB[16];
	#define hashB hash+64

	memset(hash, 0, sizeof hash);

	sph_blake512_init(&ctx_blake);
	sph_blake512(&ctx_blake, input, 80);
	sph_blake512_close(&ctx_blake, hash);

	sph_bmw512_init(&ctx_bmw);
	sph_bmw512(&ctx_bmw, hash, 64);
	sph_bmw512_close(&ctx_bmw, hashB);

	sph_groestl512_init(&ctx_groestl);
	sph_groestl512(&ctx_groestl, hashB, 64);
	sph_groestl512_close(&ctx_groestl, hash);

	sph_skein512_init(&ctx_skein);
	sph_skein512(&ctx_skein, hash, 64);
	sph_skein512_close(&ctx_skein, hashB);

	sph_jh512_init(&ctx_jh);
	sph_jh512(&ctx_jh, hashB, 64);
	sph_jh512_close(&ctx_jh, hash);

	sph_keccak512_init(&ctx_keccak);
	sph_keccak512(&ctx_keccak, hash, 64);
	sph_keccak512_close(&ctx_keccak, hashB);

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512(&ctx_luffa, hashB, 64);
	sph_luffa512_close(&ctx_luffa, hash);

	sph_cubehash512_init(&ctx_cubehash);
	sph_cubehash512(&ctx_cubehash, hash, 64);
	sph_cubehash512_close(&ctx_cubehash, hashB);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, hashB, 64);
	sph_shavite512_close(&ctx_shavite, hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, hash, 64);
	sph_simd512_close(&ctx_simd, hashB);

	sph_echo512_init(&ctx_echo);
	sph_echo512(&ctx_echo, hashB, 64);
	sph_echo512_close(&ctx_echo, hash);

	sph_hamsi512_init(&ctx_hamsi);
	sph_hamsi512(&ctx_hamsi, hash, 64);
	sph_hamsi512_close(&ctx_hamsi, hashB);

	sph_fugue512_init(&ctx_fugue);
	sph_fugue512(&ctx_fugue, hashB, 64);
	sph_fugue512_close(&ctx_fugue, hash);

	sph_shabal512_init(&ctx_shabal);
	sph_shabal512(&ctx_shabal, hash, 64);
	sph_shabal512_close(&ctx_shabal, hashB);

	sph_whirlpool_init(&ctx_whirlpool);
	sph_whirlpool(&ctx_whirlpool, hashB, 64);
	sph_whirlpool_close(&ctx_whirlpool, hash);

	memcpy(output, hash, 32);
}

extern int scanhash_x15(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	static THREAD uint32_t *d_hash = nullptr;

	const uint32_t first_nonce = pdata[19];

	int intensity = 256 * 256 * 13;
	if (device_sm[device_map[thr_id]] == 520)  intensity = 256 * 256 * 22;
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, intensity); // 19=256*256*8;
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;

	if (opt_benchmark)
		ptarget[7] = 0x0fF;

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

		quark_groestl512_cpu_init(thr_id, throughputmax);
		quark_skein512_cpu_init(thr_id);
		quark_bmw512_cpu_init(thr_id, throughputmax);
		x11_simd512_cpu_init(thr_id, throughputmax);
		x11_echo512_cpu_init(thr_id, throughputmax);
		x13_hamsi512_cpu_init(thr_id, throughputmax);
		x13_fugue512_cpu_init(thr_id, throughputmax);
		x15_whirlpool_cpu_init(thr_id, throughputmax, 0);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * sizeof(uint32_t) * throughputmax));

		cuda_check_cpu_init(thr_id, throughputmax);
		mining_has_stopped[thr_id] = false;
		init = true;
	}
	
	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	quark_blake512_cpu_setBlock_80(thr_id, (uint64_t *)endiandata);
	cuda_check_cpu_setTarget(ptarget, thr_id);

	do {
		quark_blake512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		quark_bmw512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_groestl512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_skein512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_jh512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_keccak512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		x11_luffaCubehash512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash,simdthreads);
		x11_echo512_cpu_hash_64(thr_id, throughput, pdata[19],  d_hash);
		x13_hamsi512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x13_fugue512_cpu_hash_64(thr_id, throughput, pdata[19],  d_hash);
		x14_shabal512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x15_whirlpool_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);

		uint32_t foundNonce = cuda_check_hash(thr_id, throughput, pdata[19], d_hash);
		if(stop_mining) {mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);}
		if(foundNonce != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			/* check now with the CPU to confirm */
			if(opt_verify){ be32enc(&endiandata[19], foundNonce);
			x15hash(vhash64, endiandata);

			} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget)) {
				int res = 1;
				uint32_t secNonce = cuda_check_hash_suppl(thr_id, throughput, pdata[19], d_hash, foundNonce);
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (secNonce != 0)
				{
					if(opt_verify){ be32enc(&endiandata[19], secNonce);
					x15hash(vhash64, endiandata);
					} if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{
						pdata[21] = secNonce;
						res++;
						if (opt_benchmark)
							applog(LOG_INFO, "GPU #%d: found nounce %08x", device_map[thr_id], secNonce);
					}
					else
					{
						applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], secNonce);
					}
				}
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d: found nounce %08x", device_map[thr_id], foundNonce);
				pdata[19] = foundNonce;
				return res;
			}
			else
			{
				applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], foundNonce);
			}
		}

		pdata[19] += throughput; CUDA_SAFE_CALL(cudaGetLastError());
	} while (!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;

	return 0;
}
