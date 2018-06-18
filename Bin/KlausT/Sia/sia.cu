/*-
* blake2b C code from https://github.com/SiaMining/sgminer/blob/master/algorithm/sia.c
*
* Copyright 2009 Colin Percival, 2014 savale
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
*
* This file was originally written by Colin Percival as part of the Tarsnap
* online backup system.
*/
#include "miner.h"
#include "cuda_helper.h"
#include <cstdio>
using namespace std;
#include <cuda_profiler_api.h>
#include "sia.h"

extern void applog_hex(void *data, int len);
extern bool fulltest_sia(const uint64_t *hash, const uint64_t *target);

#define B2B_GET64(p)                            \
    (((uint64_t) ((uint8_t *) (p))[0]) ^        \
    (((uint64_t) ((uint8_t *) (p))[1]) << 8) ^  \
    (((uint64_t) ((uint8_t *) (p))[2]) << 16) ^ \
    (((uint64_t) ((uint8_t *) (p))[3]) << 24) ^ \
    (((uint64_t) ((uint8_t *) (p))[4]) << 32) ^ \
    (((uint64_t) ((uint8_t *) (p))[5]) << 40) ^ \
    (((uint64_t) ((uint8_t *) (p))[6]) << 48) ^ \
    (((uint64_t) ((uint8_t *) (p))[7]) << 56))

#define B2B_G(a, b, c, d, x, y) {   \
    v[a] = v[a] + v[b] + x;         \
    v[d] = ROTR64(v[d] ^ v[a], 32); \
    v[c] = v[c] + v[d];             \
    v[b] = ROTR64(v[b] ^ v[c], 24); \
    v[a] = v[a] + v[b] + y;         \
    v[d] = ROTR64(v[d] ^ v[a], 16); \
    v[c] = v[c] + v[d];             \
    v[b] = ROTR64(v[b] ^ v[c], 63); }

static const uint64_t blake2b_iv[8] =
{
	0x6A09E667F3BCC908, 0xBB67AE8584CAA73B,
	0x3C6EF372FE94F82B, 0xA54FF53A5F1D36F1,
	0x510E527FADE682D1, 0x9B05688C2B3E6C1F,
	0x1F83D9ABFB41BD6B, 0x5BE0CD19137E2179
};

typedef struct
{
	uint8_t b[128];                     // input buffer
	uint64_t h[8];                      // chained state
	uint64_t t[2];                      // total number of bytes
	size_t c;                           // pointer for b[]
	size_t outlen;                      // digest size
} blake2b_ctx;

void blake2b_update(blake2b_ctx *ctx, const void *in, size_t inlen);

static void blake2b_compress(blake2b_ctx *ctx, int last)
{
	const uint8_t sigma[12][16] =
	{
		{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		{14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3},
		{11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4},
		{7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8},
		{9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13},
		{2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9},
		{12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11},
		{13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10},
		{6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5},
		{10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0},
		{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		{14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3}
	};
	int i;
	uint64_t v[16], m[16];

	for(i = 0; i < 8; i++)
	{           // init work variables
		v[i] = ctx->h[i];
		v[i + 8] = blake2b_iv[i];
	}

	v[12] ^= ctx->t[0];                 // low 64 bits of offset
	v[13] ^= ctx->t[1];                 // high 64 bits
	if(last)                           // last block flag set ?
		v[14] = ~v[14];

	for(i = 0; i < 16; i++)            // get little-endian words
		m[i] = B2B_GET64(&ctx->b[8 * i]);

	for(i = 0; i < 12; i++)
	{          // twelve rounds
		B2B_G(0, 4, 8, 12, m[sigma[i][0]], m[sigma[i][1]]);
		B2B_G(1, 5, 9, 13, m[sigma[i][2]], m[sigma[i][3]]);
		B2B_G(2, 6, 10, 14, m[sigma[i][4]], m[sigma[i][5]]);
		B2B_G(3, 7, 11, 15, m[sigma[i][6]], m[sigma[i][7]]);
		B2B_G(0, 5, 10, 15, m[sigma[i][8]], m[sigma[i][9]]);
		B2B_G(1, 6, 11, 12, m[sigma[i][10]], m[sigma[i][11]]);
		B2B_G(2, 7, 8, 13, m[sigma[i][12]], m[sigma[i][13]]);
		B2B_G(3, 4, 9, 14, m[sigma[i][14]], m[sigma[i][15]]);
	}

	for(i = 0; i < 8; ++i)
		ctx->h[i] ^= v[i] ^ v[i + 8];
}

// Initialize the hashing context "ctx" with optional key "key".
//      1 <= outlen <= 64 gives the digest size in bytes.
//      Secret key (also <= 64 bytes) is optional (keylen = 0).
int blake2b_init(blake2b_ctx *ctx, size_t outlen, const void *key, size_t keylen)        // (keylen=0: no key)
{
	size_t i;

	if(outlen == 0 || outlen > 64 || keylen > 64)
		return -1;                      // illegal parameters

	for(i = 0; i < 8; i++)             // state, "param block"
		ctx->h[i] = blake2b_iv[i];
	ctx->h[0] ^= 0x01010000 ^ (keylen << 8) ^ outlen;

	ctx->t[0] = 0;                      // input count low word
	ctx->t[1] = 0;                      // input count high word
	ctx->c = 0;                         // pointer within buffer
	ctx->outlen = outlen;

	for(i = keylen; i < 128; i++)      // zero input block
		ctx->b[i] = 0;
	if(keylen > 0)
	{
		blake2b_update(ctx, key, keylen);
		ctx->c = 128;                   // at the end
	}

	return 0;
}

// Add "inlen" bytes from "in" into the hash.
void blake2b_update(blake2b_ctx *ctx,	const void *in, size_t inlen)
{
	size_t i;

	for(i = 0; i < inlen; i++)
	{
		if(ctx->c == 128)
		{            // buffer full ?
			ctx->t[0] += ctx->c;        // add counters
			if(ctx->t[0] < ctx->c)     // carry overflow ?
				ctx->t[1]++;            // high word
			blake2b_compress(ctx, 0);   // compress (not last)
			ctx->c = 0;                 // counter to zero
		}
		ctx->b[ctx->c++] = ((const uint8_t *)in)[i];
	}
}

// Generate the message digest (size given in init).
//      Result placed in "out".
void blake2b_final(blake2b_ctx *ctx, void *out)
{
	size_t i;

	ctx->t[0] += ctx->c;                // mark last block offset
	if(ctx->t[0] < ctx->c)             // carry overflow
		ctx->t[1]++;                    // high word

	while(ctx->c < 128)                // fill up with zeros
		ctx->b[ctx->c++] = 0;
	blake2b_compress(ctx, 1);           // final block flag = 1

	// little endian convert and store
	for(i = 0; i < ctx->outlen; i++)
	{
		((uint8_t *)out)[i] =
			(ctx->h[i >> 3] >> (8 * (i & 7))) & 0xFF;
	}
}

void siahash(const void *data, unsigned int len, void *hash)
{
	blake2b_ctx ctx;
	blake2b_init(&ctx, 32, NULL, 0);
	blake2b_update(&ctx, data, len);
	blake2b_final(&ctx, hash);
}

/***************************************************************************/

int scanhash_sia(int thr_id, uint32_t *pdata, uint32_t *ptarget, uint32_t max_nonce, uint32_t *hashes_done)
{
	static THREAD uint32_t *h_nounce = nullptr;
	const uint32_t first_nonce = pdata[8];
	static THREAD uint32_t throughputmax;

	if(opt_benchmark)
		ptarget[7] = 0x00000001;

	static THREAD volatile bool init = false;
	if(!init)
	{
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		CUDA_SAFE_CALL(cudaDeviceReset());
		CUDA_SAFE_CALL(cudaSetDeviceFlags(cudaschedule));
		CUDA_SAFE_CALL(cudaDeviceSetCacheConfig(cudaFuncCachePreferL1));

		CUDA_SAFE_CALL(cudaStreamCreate(&gpustream[thr_id]));
		CUDA_SAFE_CALL(cudaMallocHost(&h_nounce, MAXRESULTS * sizeof(uint32_t)));
		sia_gpu_init(thr_id);

		throughputmax = device_intensity(device_map[thr_id], __func__, 1U << 28);
		if(throughputmax == 1<<28)
			applog(LOG_INFO, "GPU #%d: using default intensity 28", device_map[thr_id]);
		mining_has_stopped[thr_id] = false;
		init = true;
	}
	uint32_t throughput = min(throughputmax, (max_nonce - first_nonce));
	throughput -= throughput % (blocksize*npt);

	sia_precalc(thr_id, gpustream[thr_id], (uint64_t *)pdata);

	uint32_t endiandata[20];
	for(int k = 0; k < 20; k++)
		le32enc(&endiandata[k], pdata[k]);

	do
	{
		sia_gpu_hash(gpustream[thr_id], thr_id, throughput, h_nounce, ((uint64_t*)ptarget)[3], ((uint64_t*)pdata)[4]);
		if(stop_mining)
		{
			cudaDeviceSynchronize();
			cudaStreamDestroy(gpustream[thr_id]);
			cudaProfilerStop();
			mining_has_stopped[thr_id] = true;
			pthread_exit(nullptr);
		}
		if(h_nounce[0] != 0)
		{
			const uint64_t Htarg = ((uint64_t*)ptarget)[3];
			uint64_t vhash64[4] = {0};
			if(opt_verify)
			{
				le32enc(&endiandata[8], h_nounce[0]);
				siahash(endiandata, 80, vhash64);
			}
			if(swab64(vhash64[0]) <= Htarg && fulltest_sia(vhash64, (uint64_t*)ptarget))
			{
				int res = 1;
				*hashes_done = pdata[8] - first_nonce + throughput;
				if(opt_benchmark || opt_debug)  applog(LOG_INFO, "GPU #%d: Found nonce %08x", device_map[thr_id], h_nounce[0]);
				// check if there was some other ones...
				if(h_nounce[1] != 0)
				{
					if(opt_verify)
					{
						le32enc(&endiandata[8], h_nounce[1]);
						siahash(vhash64, 80, endiandata);

					}
					if(swab64(vhash64[0]) <= Htarg && fulltest_sia(vhash64, (uint64_t*)ptarget))
					{
						pdata[20] = h_nounce[1];
						res++;
						if(opt_benchmark || opt_debug)  applog(LOG_INFO, "GPU #%d: Found second nonce", device_map[thr_id]);
					}
					else
					{
						if(vhash64[0] != Htarg) // don't show message if it is equal but fails fulltest
							applog(LOG_INFO, "GPU #%d: result does not validate on CPU!", device_map[thr_id]);
					}
				}
				pdata[8] = h_nounce[0];
//				applog(LOG_INFO, "hashes done = %08x", *hashes_done);
				return res;
			}
			else
			{
				if(vhash64[0] != Htarg) // don't show message if it is equal but fails fulltest
					applog(LOG_INFO, "GPU #%d: result does not validate on CPU!", device_map[thr_id]);
			}
		}
		pdata[8] += throughput;
		CUDA_SAFE_CALL(cudaGetLastError());

	} while(!work_restart[thr_id].restart && ((uint64_t)max_nonce >((uint64_t)pdata[8] + (uint64_t)throughput)));
	*hashes_done = pdata[8] - first_nonce;
	return 0;
}