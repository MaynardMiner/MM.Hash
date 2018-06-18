#include <string.h>
#ifdef __cplusplus
#include <cstdint>
#else
#include <stdint.h>
#endif

#include "sph/sph_fugue.h"

#include "miner.h"
#include "cuda_fugue256.h"
#include <cuda_runtime.h>
extern bool stop_mining;
extern volatile bool mining_has_stopped[MAX_GPUS];

extern "C" void my_fugue256_init(void *cc);
extern "C" void my_fugue256(void *cc, const void *data, size_t len);
extern "C" void my_fugue256_close(void *cc, void *dst);
extern "C" void my_fugue256_addbits_and_close(void *cc, unsigned ub, unsigned n, void *dst);

// vorbereitete Kontexte nach den ersten 80 Bytes
// sph_fugue256_context  ctx_fugue_const[MAX_GPUS];

#define SWAP32(x) swab32(x)

extern int scanhash_fugue256(int thr_id, uint32_t *pdata, uint32_t *ptarget,
	uint32_t max_nonce, uint32_t *hashes_done)
{
	uint32_t start_nonce = pdata[19];
	unsigned int intensity = (device_sm[device_map[thr_id]] > 500) ? 22 : 19;
	uint32_t throughputmax = device_intensity(device_map[thr_id], __func__, 1 << intensity); // 256*256*8
	uint32_t throughput = min(throughputmax, max_nonce - start_nonce) & 0xfffffc00;

	if (opt_benchmark)
		ptarget[7] = 0xf;

	// init
	static THREAD volatile bool init = false;
	if(!init)
	{
		if(throughputmax == intensity)
			applog(LOG_INFO, "GPU #%d: using default intensity %.3f", device_map[thr_id], throughput2intensity(throughputmax));
#if defined WIN32 && !defined _WIN64
		// 2GB limit for cudaMalloc
		if(throughputmax > 0x7fffffffULL / (8 * sizeof(uint32_t)))
		{
			applog(LOG_ERR, "intensity too high");
			mining_has_stopped[thr_id] = true;
			proper_exit(2);
		}
#endif
		fugue256_cpu_init(thr_id, throughputmax);
		mining_has_stopped[thr_id] = false;
		init = true;
	}

	// Endian Drehung ist notwendig
	uint32_t endiandata[20];
	for (int kk=0; kk < 20; kk++)
		be32enc(&endiandata[kk], pdata[kk]);

	// Context mit dem Endian gedrehten Blockheader vorbereiten (Nonce wird später ersetzt)
	fugue256_cpu_setBlock(thr_id, endiandata, (void*)ptarget);

	do {
		// GPU
		uint32_t foundNounce = 0xFFFFFFFF;
		fugue256_cpu_hash(thr_id, throughput, pdata[19], NULL, &foundNounce);

		if(stop_mining) {mining_has_stopped[thr_id] = true; pthread_exit(nullptr);}
		if(foundNounce < 0xffffffff)
		{
			uint32_t hash[8];
			const uint32_t Htarg = ptarget[7];

			endiandata[19] = SWAP32(foundNounce);
			sph_fugue256_context ctx_fugue;
			sph_fugue256_init(&ctx_fugue);
			sph_fugue256 (&ctx_fugue, endiandata, 80);
			sph_fugue256_close(&ctx_fugue, &hash);

			if (hash[7] <= Htarg && fulltest(hash, ptarget))
			{
				*hashes_done = pdata[19] - start_nonce + throughput;
				pdata[19] = foundNounce;
				return 1;
			} else {
				applog(LOG_INFO, "GPU #%d: result for nonce $%08X does not validate on CPU!", device_map[thr_id], foundNounce);
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

void fugue256_hash(unsigned char* output, const unsigned char* input, int len)
{
	sph_fugue256_context ctx;

	sph_fugue256_init(&ctx);
	sph_fugue256(&ctx, input, len);
	sph_fugue256_close(&ctx, (void *)output);
}
