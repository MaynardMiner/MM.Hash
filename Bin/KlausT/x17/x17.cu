/*
 * X17 algorithm built on cbuchner1's original X11
 *
 */

extern "C"
{
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

#include "sph/sph_sha2.h"
#include "sph/sph_haval.h"
}

#include "miner.h"
#include "cuda_helper.h"

static uint32_t *d_hash[MAX_GPUS];
static THREAD uint32_t *h_found = nullptr;

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

extern void cuda_jh512Keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_luffaCubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

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

extern void x15_whirlpool_cpu_init(int thr_id, uint32_t threads, int flag);
extern void x15_whirlpool_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x17_sha512_cpu_init(int thr_id, uint32_t threads);
extern void x17_sha512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce,uint64_t *d_hash);

extern void x17_haval256_cpu_init(int thr_id, uint32_t threads);
extern void x17_haval256_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t target, uint32_t *result);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *inpHashes,
											const uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

// X17 Hashfunktion
void x17hash(void *output, const void *input)
{
	// blake1-bmw2-grs3-skein4-jh5-keccak6-luffa7-cubehash8-shavite9-simd10-echo11-hamsi12-fugue13-shabal14-whirlpool15-sha512-haval17

	sph_blake512_context ctx_blake;
	sph_bmw512_context ctx_bmw;
	sph_groestl512_context ctx_groestl;
	sph_jh512_context ctx_jh;
	sph_keccak512_context ctx_keccak;
	sph_skein512_context ctx_skein;
	sph_luffa512_context ctx_luffa;
	sph_cubehash512_context ctx_cubehash;
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_echo512_context ctx_echo;
	sph_hamsi512_context ctx_hamsi;
	sph_fugue512_context ctx_fugue;
	sph_shabal512_context ctx_shabal;
	sph_whirlpool_context ctx_whirlpool;
	sph_sha512_context ctx_sha512;
	sph_haval256_5_context ctx_haval;

	unsigned char hash[128]; // uint32_t hashA[16], hashB[16];
	#define hashB hash+64

	sph_blake512_init(&ctx_blake);
	sph_blake512(&ctx_blake, input, 80);
	sph_blake512_close(&ctx_blake, hash);

	sph_bmw512_init(&ctx_bmw);
	sph_bmw512(&ctx_bmw, (const void*) hash, 64);
	sph_bmw512_close(&ctx_bmw, hash);

	sph_groestl512_init(&ctx_groestl);
	sph_groestl512(&ctx_groestl, (const void*) hash, 64);
	sph_groestl512_close(&ctx_groestl, hash);

	sph_skein512_init(&ctx_skein);
	sph_skein512(&ctx_skein, (const void*) hash, 64);
	sph_skein512_close(&ctx_skein, hash);

	sph_jh512_init(&ctx_jh);
	sph_jh512(&ctx_jh, (const void*) hash, 64);
	sph_jh512_close(&ctx_jh, hash);

	sph_keccak512_init(&ctx_keccak);
	sph_keccak512(&ctx_keccak, (const void*) hash, 64);
	sph_keccak512_close(&ctx_keccak, hash);

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512(&ctx_luffa, (const void*) hash, 64);
	sph_luffa512_close (&ctx_luffa, hash);

	sph_cubehash512_init(&ctx_cubehash);
	sph_cubehash512(&ctx_cubehash, (const void*) hash, 64);
	sph_cubehash512_close(&ctx_cubehash, hash);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, (const void*) hash, 64);
	sph_shavite512_close(&ctx_shavite, hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, (const void*) hash, 64);
	sph_simd512_close(&ctx_simd, hash);

	sph_echo512_init(&ctx_echo);
	sph_echo512(&ctx_echo, (const void*) hash, 64);
	sph_echo512_close(&ctx_echo, hash);

	sph_hamsi512_init(&ctx_hamsi);
	sph_hamsi512(&ctx_hamsi, (const void*) hash, 64);
	sph_hamsi512_close(&ctx_hamsi, hash);

	sph_fugue512_init(&ctx_fugue);
	sph_fugue512(&ctx_fugue, (const void*) hash, 64);
	sph_fugue512_close(&ctx_fugue, hash);

	sph_shabal512_init(&ctx_shabal);
	sph_shabal512(&ctx_shabal, (const void*) hash, 64);
	sph_shabal512_close(&ctx_shabal, hash);

	sph_whirlpool_init(&ctx_whirlpool);
	sph_whirlpool (&ctx_whirlpool, (const void*) hash, 64);
	sph_whirlpool_close(&ctx_whirlpool, hash);

	sph_sha512_init(&ctx_sha512);
	sph_sha512(&ctx_sha512,(const void*) hash, 64);
	sph_sha512_close(&ctx_sha512,(void*) hash);

	sph_haval256_5_init(&ctx_haval);
	sph_haval256_5(&ctx_haval,(const void*) hash, 64);
	sph_haval256_5_close(&ctx_haval,hash);

	memcpy(output, hash, 32);
}

static volatile bool init[MAX_GPUS] = { false };

extern int scanhash_x17(int thr_id, uint32_t *pdata,
	uint32_t *ptarget, uint32_t max_nonce,
	uint32_t *hashes_done)
{
	const uint32_t first_nonce = pdata[19];

	int intensity = 256 * 256 * 9;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;
	if (device_sm[device_map[thr_id]] == 520)  intensity = 256 * 256 * 15;
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, intensity); // 19=256*256*8;
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce)) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0x03f;

	if (!init[thr_id])
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
		x17_sha512_cpu_init(thr_id, throughputmax);
		x17_haval256_cpu_init(thr_id, throughputmax);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash[thr_id], 16ULL * sizeof(uint32_t) * throughputmax));
		CUDA_SAFE_CALL(cudaMallocHost(&(h_found), 2 * sizeof(uint32_t)));
 
		mining_has_stopped[thr_id] = false;
		init[thr_id] = true;
	}

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	quark_blake512_cpu_setBlock_80(thr_id, (uint64_t *)endiandata);
	cuda_check_cpu_setTarget(ptarget, thr_id);

	do {
		// Hash with CUDA
		quark_blake512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]);
		quark_bmw512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id]);
		quark_groestl512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id]);
		quark_skein512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id]);
		cuda_jh512Keccak512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x11_luffaCubehash512_cpu_hash_64(thr_id, throughput, pdata[19],d_hash[thr_id]);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		x11_echo512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x13_hamsi512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x13_fugue512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x14_shabal512_cpu_hash_64(thr_id, throughput, pdata[19],d_hash[thr_id]);
		x15_whirlpool_cpu_hash_64(thr_id, throughput, pdata[19],d_hash[thr_id]);
		x17_sha512_cpu_hash_64(thr_id, throughput, pdata[19], (uint64_t*)d_hash[thr_id]);
		x17_haval256_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], ptarget[7], h_found);

		if(stop_mining)	{	mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);	}
		if(h_found[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8] = {0};
			if(opt_verify)
			{
				be32enc(&endiandata[19], h_found[0]);
				x17hash(vhash64, endiandata);

			} if(vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if(h_found[1] != 0xffffffff)
				{
					if(opt_verify)
					{
						be32enc(&endiandata[19], h_found[1]);
						x13hash(vhash64, endiandata);
					} if(vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{

						pdata[21] = h_found[1];
						res++;
						if(opt_benchmark)
							applog(LOG_INFO, "GPU #%d Found second nonce %08x", device_map[thr_id], h_found[1]);
					}
					else
					{
						if(vhash64[7] != Htarg)
						{
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", device_map[thr_id], h_found[1]);
						}
					}

				}
				pdata[19] = h_found[0];
				if(opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nonce %08x", device_map[thr_id], h_found[0]);
				return res;
			}
			else
			{
				if(vhash64[7] != Htarg)
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
