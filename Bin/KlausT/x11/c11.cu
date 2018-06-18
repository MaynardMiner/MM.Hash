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
}

#include "miner.h"
//#include <cuda.h>
//#include <cuda_runtime.h>
#include "cuda_helper.h"

#include <stdio.h>
#include <memory.h>

extern void quark_blake512_cpu_init(int thr_id);
extern void quark_blake512_cpu_setBlock_80(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_setBlock_80_multi(int thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void quark_blake512_cpu_hash_80_multi(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void quark_bmw512_cpu_init(int thr_id, uint32_t threads);
extern void quark_bmw512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_groestl512_cpu_init(int thr_id, uint32_t threads);
extern void quark_groestl512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_skein512_cpu_init(int thr_id, uint32_t threads);
extern void quark_skein512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_keccak512_cpu_init(int thr_id, uint32_t threads);
extern void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void cuda_jh512Keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_luffaCubehash512_cpu_init(int thr_id, uint32_t threads);
extern void x11_luffaCubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_shavite512_cpu_init(int thr_id, uint32_t threads);
extern void x11_shavite512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *d_hash, uint32_t target, uint32_t *h_found);
extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, const uint32_t *inpHashes,
										  const uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

extern "C" void c11hash(void *output, const void *input)
{
			// blake1-bmw2-grs3-skein4-jh5-keccak6-luffa7-cubehash8-shavite9-simd10-echo11
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
		
		unsigned char hash[128];
		memset(hash, 0, sizeof hash);
		
		sph_blake512_init(&ctx_blake);
		sph_blake512(&ctx_blake, input, 80);
		sph_blake512_close(&ctx_blake, (void*)hash);
		
		sph_bmw512_init(&ctx_bmw);
		sph_bmw512(&ctx_bmw, (const void*)hash, 64);
		sph_bmw512_close(&ctx_bmw, (void*)hash);
		
		sph_groestl512_init(&ctx_groestl);
		sph_groestl512(&ctx_groestl, (const void*)hash, 64);
		sph_groestl512_close(&ctx_groestl, (void*)hash);
		
		sph_jh512_init(&ctx_jh);
		sph_jh512(&ctx_jh, (const void*)hash, 64);
		sph_jh512_close(&ctx_jh, (void*)hash);
		
		sph_keccak512_init(&ctx_keccak);
		sph_keccak512(&ctx_keccak, (const void*)hash, 64);
		sph_keccak512_close(&ctx_keccak, (void*)hash);
		
		sph_skein512_init(&ctx_skein);
		sph_skein512(&ctx_skein, (const void*)hash, 64);
		sph_skein512_close(&ctx_skein, (void*)hash);
		
		sph_luffa512_init(&ctx_luffa);
		sph_luffa512(&ctx_luffa, (const void*)hash, 64);
		sph_luffa512_close(&ctx_luffa, (void*)hash);
		
		sph_cubehash512_init(&ctx_cubehash);
		sph_cubehash512(&ctx_cubehash, (const void*)hash, 64);
		sph_cubehash512_close(&ctx_cubehash, (void*)hash);
		
		sph_shavite512_init(&ctx_shavite);
		sph_shavite512(&ctx_shavite, (const void*)hash, 64);
		sph_shavite512_close(&ctx_shavite, (void*)hash);
		
		sph_simd512_init(&ctx_simd);
		sph_simd512(&ctx_simd, (const void*)hash, 64);
		sph_simd512_close(&ctx_simd, (void*)hash);
		
		sph_echo512_init(&ctx_echo);
		sph_echo512(&ctx_echo, (const void*)hash, 64);
		sph_echo512_close(&ctx_echo, (void*)hash);
		
		memcpy(output, hash, 32);
}

static THREAD uint32_t *d_hash = nullptr;

int scanhash_c11(int thr_id, uint32_t *pdata,
				 uint32_t *ptarget, uint32_t max_nonce,
				 uint32_t *hashes_done)
{
	uint32_t foundnonces[2];
	const uint32_t first_nonce = pdata[19];

	cudaDeviceProp props;
	CUDA_SAFE_CALL(cudaGetDeviceProperties(&props, device_map[thr_id]));
	static THREAD uint32_t throughputmax;

	if(opt_benchmark)
		ptarget[7] = 0x4f;

	static THREAD bool init = false;
	if(!init)
	{
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));
		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));

		unsigned int intensity;
#if defined WIN32 && !defined _WIN64
		intensity = 256 * 256 * 16;
#else
		if(strstr(props.name, "Titan"))   intensity = (256 * 256 * 22);
		else if(strstr(props.name, "970"))		  intensity = (256 * 256 * 22);
		else if(strstr(props.name, "980"))    intensity = (256 * 256 * 22);
		else if(strstr(props.name, "1070"))   intensity = (256 * 256 * 22);
		else if(strstr(props.name, "1080"))   intensity = (256 * 256 * 22);
		else if(strstr(props.name, "750 Ti")) intensity = (256 * 256 * 20);
		else if(strstr(props.name, "750"))    intensity = (256 * 256 * 19);
		else if(strstr(props.name, "960"))    intensity = (256 * 256 * 19);
		else intensity = (256 * 256 * 19);
#endif
		throughputmax = device_intensity(device_map[thr_id], __func__, intensity);
		if(throughputmax == intensity)
			applog(LOG_INFO, "GPU #%d: using default intensity %.3f", device_map[thr_id], throughput2intensity(throughputmax));
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
		quark_bmw512_cpu_init(thr_id, throughputmax);
		x11_echo512_cpu_init(thr_id, throughputmax);
		x11_simd512_cpu_init(thr_id, throughputmax);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash, 16ULL * 4 * throughputmax));
		mining_has_stopped[thr_id] = false;
		init = true;
	}
	uint32_t throughput = min(throughputmax, max_nonce - first_nonce) & 0xfffffc00;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 256 : 32;

	uint32_t endiandata[20];
	for(int k = 0; k < 20; k++)
		be32enc(&endiandata[k], ((uint32_t*)pdata)[k]);

	quark_blake512_cpu_setBlock_80(thr_id, (uint64_t *)endiandata);

	do
	{

		quark_blake512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash);
		quark_bmw512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		quark_groestl512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		cuda_jh512Keccak512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		quark_skein512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash);
		x11_luffaCubehash512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash, simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash, ptarget[7], foundnonces);
		cudaStreamSynchronize(gpustream[thr_id]);
		if(stop_mining)
		{
			mining_has_stopped[thr_id] = true; cudaStreamDestroy(gpustream[thr_id]); pthread_exit(nullptr);
		}
		if (foundnonces[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8]={0};
			if(opt_verify)
			{
				be32enc(&endiandata[19], foundnonces[0]);
				c11hash(vhash64, endiandata);
			}
			if(vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if(foundnonces[1] != 0xffffffff)
				{
					if(opt_verify)
					{
						be32enc(&endiandata[19], foundnonces[1]);
						c11hash(vhash64, endiandata);
					}
					if(vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{
						pdata[21] = foundnonces[1];
						res++;
						if(opt_benchmark)
							applog(LOG_INFO, "GPU #%d: Found second nonce %08x", thr_id, foundnonces[1]);
					}
					else
					{
						if(vhash64[7] != Htarg)
						{
							applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundnonces[1]);
						}
					}
				}
				pdata[19] = foundnonces[0];
				if(opt_benchmark)
					applog(LOG_INFO, "GPU #%d: Found nonce %08x", thr_id, foundnonces[0]);
				return res;
			}
			else
			{
				if(vhash64[7] != Htarg)
				{
					applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundnonces[0]);
				}
			}
		}
		pdata[19] += throughput;
	} while(!work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce ;
	return 0;
}
