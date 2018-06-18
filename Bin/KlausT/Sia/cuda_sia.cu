/*
Copyright (c) 2015 KlausT and Vorksholk

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
*/


#include <stdint.h>
#include "cuda_helper.h"
#include "sia.h"

#ifdef _MSC_VER
#define THREAD __declspec(thread)
#else
#define THREAD __thread
#endif

#ifdef __INTELLISENSE__
#define __launch_bounds__(blocksize)
#endif

static THREAD uint64_t *vpre_h;
static THREAD uint32_t *nonceOut_d;
static THREAD uint64_t *hash_d;
__constant__ uint64_t vpre[16];
__constant__ uint64_t header[10];

__device__ __forceinline__
static uint64_t __byte_perm_64(const uint64_t source, const uint32_t grab1, const uint32_t grab2)
{
	uint64_t r;
	uint32_t r1;
	uint32_t r2;

	uint32_t i1;
	uint32_t i2;

	asm("mov.b64 {%0, %1}, %2;" : "=r"(i1), "=r"(i2) : "l"(source));
	asm("prmt.b32 %0, %1, %2, %3;" : "=r"(r1) : "r"(i1), "r"(i2), "r"(grab1));
	asm("prmt.b32 %0, %1, %2, %3;" : "=r"(r2) : "r"(i1), "r"(i2), "r"(grab2));
	asm("mov.b64 %0, {%1, %2};" : "=l"(r) : "r"(r1), "r"(r2));

	return r;
}

__device__ __forceinline__
static uint64_t __swap_hilo(const uint64_t source)
{
	uint64_t r;
	uint32_t s1;
	uint32_t s2;

	asm("mov.b64 {%0, %1}, %2;" : "=r"(s1), "=r"(s2) : "l"(source));
	asm("mov.b64 %0, {%1, %2};" : "=l"(r) : "r"(s2), "r"(s1));

	return r;
}

__device__ unsigned int numberofresults;

__global__ void __launch_bounds__(blocksize, 3) siakernel(uint32_t * __restrict__ nonceOut, uint64_t target, uint64_t startnonce)
{
	uint64_t v[16];
	const uint64_t start = startnonce + (blockDim.x * blockIdx.x + threadIdx.x)*npt;
	const uint64_t end = start + npt;

	numberofresults = 0;

	for(uint64_t n = start; n < end; n++)
	{
		v[2] = 0x5BF2CD1EF9D6B596u + n; v[14] = __swap_hilo(~0x1f83d9abfb41bd6bu ^ v[2]); v[10] = 0x3c6ef372fe94f82bu + v[14]; v[6] = __byte_perm_64(0x1f83d9abfb41bd6bu ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[5]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = 0x130C253729B586Au + header[6]; v[15] = __swap_hilo(0x5be0cd19137e2179u ^ v[3]); v[11] = 0xa54ff53a5f1d36f1u + v[15]; v[7] = __byte_perm_64(0x5be0cd19137e2179u ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[7]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = vpre[0] + vpre[5] + header[8]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(vpre[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[9]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = vpre[1] + v[6];          v[12] = __swap_hilo(vpre[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6];             v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7];             v[13] = __swap_hilo(vpre[13] ^ v[2]); v[8] = vpre[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7];             v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + vpre[4];          v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = vpre[9] + v[14]; v[4] = __byte_perm_64(vpre[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4];             v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4];             v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + n;         v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[8]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[9]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6];             v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7];             v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[6]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[1]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5];             v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[0]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + header[2]; v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7];             v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[7]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[5]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + header[3]; v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[8]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5];             v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[0]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[5]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[2]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7];             v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7];             v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5];             v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5];             v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[3]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + header[6]; v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[7]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[1]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[9]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + n;         v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4] + header[7]; v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[9]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[3]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[1]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6];             v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6];             v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7];             v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7];             v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[2]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[6]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[5]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6];             v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + n;         v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[0]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4];             v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + header[8]; v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4] + header[9]; v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[0]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[5]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[7]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[2]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + n;         v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7];             v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7];             v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5];             v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[1]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6];             v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6];             v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[6]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[8]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[3]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4];             v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4] + header[2]; v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4];             v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[6]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5];             v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[0]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6];             v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + header[8]; v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[3]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + n;         v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5];             v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[7]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + header[5]; v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7];             v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7];             v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[1]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + header[9]; v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[5]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[1]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5];             v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6];             v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6];             v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + n;         v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7];             v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[0]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[7]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[6]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + header[3]; v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[9]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[2]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[8]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4];             v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4];             v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[7]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5];             v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6];             v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[1]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + header[3]; v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[9]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[5]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[0]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6];             v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + n;         v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[8]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + header[6]; v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4] + header[2]; v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4];             v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4] + header[6]; v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4];             v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5];             v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[9]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6];             v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[3]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + header[0]; v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[8]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5];             v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[2]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6];             v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6] + header[7]; v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[1]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7] + n;         v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4];             v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + header[5]; v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[2]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[8]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + n;         v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[7]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[6]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + header[1]; v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[5]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5];             v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5];             v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6] + header[9]; v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6];             v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7] + header[3]; v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7];             v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4];             v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4] + header[0]; v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4] + header[0]; v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4] + header[1]; v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + header[2]; v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[3]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + n;         v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6] + header[5]; v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7] + header[6]; v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[7]; v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[8]; v[15] = __swap_hilo(v[15] ^ v[0]); v[10] = v[10] + v[15]; v[5] = __byte_perm_64(v[5] ^ v[10], 0x6543, 0x2107);
		v[0] = v[0] + v[5] + header[9]; v[15] = __byte_perm_64(v[15] ^ v[0], 0x5432, 0x1076); v[10] = v[10] + v[15]; v[5] = ROTR64(v[5] ^ v[10], 63);
		v[1] = v[1] + v[6];             v[12] = __swap_hilo(v[12] ^ v[1]); v[11] = v[11] + v[12]; v[6] = __byte_perm_64(v[6] ^ v[11], 0x6543, 0x2107);
		v[1] = v[1] + v[6];             v[12] = __byte_perm_64(v[12] ^ v[1], 0x5432, 0x1076); v[11] = v[11] + v[12]; v[6] = ROTR64(v[6] ^ v[11], 63);
		v[2] = v[2] + v[7];             v[13] = __swap_hilo(v[13] ^ v[2]); v[8] = v[8] + v[13]; v[7] = __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107);
		v[2] = v[2] + v[7];             v[13] = __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076); v[8] = v[8] + v[13]; v[7] = ROTR64(v[7] ^ v[8], 63);
		v[3] = v[3] + v[4];             v[14] = __swap_hilo(v[14] ^ v[3]); v[9] = v[9] + v[14]; v[4] = __byte_perm_64(v[4] ^ v[9], 0x6543, 0x2107);
		v[3] = v[3] + v[4];             v[14] = __byte_perm_64(v[14] ^ v[3], 0x5432, 0x1076); v[9] = v[9] + v[14]; v[4] = ROTR64(v[4] ^ v[9], 63);

		v[0] = v[0] + v[4];             v[12] = __swap_hilo(v[12] ^ v[0]); v[8] = v[8] + v[12]; v[4] = __byte_perm_64(v[4] ^ v[8], 0x6543, 0x2107);
		v[0] = v[0] + v[4];             v[12] = __byte_perm_64(v[12] ^ v[0], 0x5432, 0x1076); v[8] = v[8] + v[12]; v[4] = ROTR64(v[4] ^ v[8], 63);
		v[1] = v[1] + v[5] + n;         v[13] = __swap_hilo(v[13] ^ v[1]); v[9] = v[9] + v[13]; v[5] = __byte_perm_64(v[5] ^ v[9], 0x6543, 0x2107);
		v[1] = v[1] + v[5] + header[8]; v[13] = __byte_perm_64(v[13] ^ v[1], 0x5432, 0x1076); v[9] = v[9] + v[13]; v[5] = ROTR64(v[5] ^ v[9], 63);
		v[2] = v[2] + v[6] + header[9]; v[14] = __swap_hilo(v[14] ^ v[2]); v[10] = v[10] + v[14]; v[6] = __byte_perm_64(v[6] ^ v[10], 0x6543, 0x2107);
		v[2] = v[2] + v[6];             v[14] = __byte_perm_64(v[14] ^ v[2], 0x5432, 0x1076); v[10] = v[10] + v[14]; v[6] = ROTR64(v[6] ^ v[10], 63);
		v[3] = v[3] + v[7];             v[15] = __swap_hilo(v[15] ^ v[3]); v[11] = v[11] + v[15]; v[7] = __byte_perm_64(v[7] ^ v[11], 0x6543, 0x2107);
		v[3] = v[3] + v[7] + header[6];	v[15] = __byte_perm_64(v[15] ^ v[3], 0x5432, 0x1076); v[11] = v[11] + v[15]; v[7] = ROTR64(v[7] ^ v[11], 63);
		v[0] = v[0] + v[5] + header[1];
		v[0] = v[0] + __byte_perm_64(v[5] ^ (v[10] + __swap_hilo(v[15] ^ v[0])), 0x6543, 0x2107);
		v[2] = v[2] + v[7];
		v[13] = __swap_hilo(v[13] ^ v[2]);
		v[8] = v[8] + v[13];
		v[2] = v[2] + __byte_perm_64(v[7] ^ v[8], 0x6543, 0x2107) + header[7];

		if(cuda_swab64(0x6A09E667F2BDC928 ^ v[0] ^ (v[8] + __byte_perm_64(v[13] ^ v[2], 0x5432, 0x1076))) < target)
		{
			int i = atomicAdd(&numberofresults, 1);
			if(i < MAXRESULTS)
				nonceOut[i] = n & 0xffffffff;
			return;
		}
	}
}

void sia_gpu_hash(cudaStream_t cudastream, int thr_id, uint32_t threads, uint32_t *nonceOut, uint64_t target, uint64_t startnonce)
{
	siakernel << <threads / blocksize / npt, blocksize, 0, cudastream >> >(nonceOut_d, target, startnonce);
	CUDA_SAFE_CALL(cudaGetLastError());
	CUDA_SAFE_CALL(cudaMemcpyAsync(nonceOut, nonceOut_d, 4 * MAXRESULTS, cudaMemcpyDeviceToHost, cudastream));
	CUDA_SAFE_CALL(cudaStreamSynchronize(cudastream));
}

void sia_gpu_init(int thr_id)
{
	CUDA_SAFE_CALL(cudaMallocHost(&vpre_h, 16 * 8));
	CUDA_SAFE_CALL(cudaMalloc(&nonceOut_d, MAXRESULTS * 4));
	CUDA_SAFE_CALL(cudaMalloc(&hash_d, 4 * 8));
}

void sia_precalc(int thr_id, cudaStream_t cudastream, const uint64_t *blockHeader)
{
	vpre_h[0] = 0xBB1838E7A0A44BF9u + blockHeader[0]; vpre_h[12] = ROTR64(0x510E527FADE68281u ^ vpre_h[0], 32); vpre_h[8] = 0x6a09e667f3bcc908u + vpre_h[12]; vpre_h[4] = ROTR64(0x510e527fade682d1u ^ vpre_h[8], 24);
	vpre_h[0] = vpre_h[0] + vpre_h[4] + blockHeader[1];       vpre_h[12] = ROTR64(vpre_h[12] ^ vpre_h[0], 16);              vpre_h[8] = vpre_h[8] + vpre_h[12];               vpre_h[4] = ROTR64(vpre_h[4] ^ vpre_h[8], 63);
	vpre_h[1] = 0x566D1711B009135Au + blockHeader[2]; vpre_h[13] = ROTR64(0x9b05688c2b3e6c1fu ^ vpre_h[1], 32); vpre_h[9] = 0xbb67ae8584caa73bu + vpre_h[13]; vpre_h[5] = ROTR64(0x9b05688c2b3e6c1fu ^ vpre_h[9], 24);
	vpre_h[1] = vpre_h[1] + vpre_h[5] + blockHeader[3];       vpre_h[13] = ROTR64(vpre_h[13] ^ vpre_h[1], 16);              vpre_h[9] = vpre_h[9] + vpre_h[13];               vpre_h[5] = ROTR64(vpre_h[5] ^ vpre_h[9], 63);

	CUDA_SAFE_CALL(cudaMemcpyToSymbolAsync(vpre, vpre_h, 16 * 8, 0, cudaMemcpyHostToDevice, cudastream));
	CUDA_SAFE_CALL(cudaMemcpyToSymbolAsync(header, blockHeader, 10 * 8, 0, cudaMemcpyHostToDevice, cudastream));
	CUDA_SAFE_CALL(cudaMemsetAsync(nonceOut_d, 0, 4 * MAXRESULTS, cudastream));
}