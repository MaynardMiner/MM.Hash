/*
 * Haval-512 for X17
 *
 * Built on cbuchner1's implementation, actual hashing code
 * heavily based on phm's sgminer
 *
 */

/*
 * Haval-512 kernel implementation.
 *
 * ==========================(LICENSE BEGIN)============================
 *
 * Copyright (c) 2014  djm34
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * ===========================(LICENSE END)=============================
 *
 * @author   phm <phm@inbox.com>
 */
#include <stdio.h>
#include <memory.h>

#define USE_SHARED 1

#include "cuda_helper.h"

static uint32_t *d_nonce[MAX_GPUS];

#define SPH_ROTL32(x, n)   ROTL32(x, n)
#define SPH_ROTR32(x, n)   ROTR32(x, n)

#define F1(x6, x5, x4, x3, x2, x1, x0) \
	(((x1) & ((x0) ^ (x4))) ^ ((x2) & (x5)) ^ ((x3) & (x6)) ^ (x0))

#define F2(x6, x5, x4, x3, x2, x1, x0) \
	(((x2) & (((x1) & ~(x3)) ^ ((x4) & (x5)) ^ (x6) ^ (x0))) \
	^ ((x4) & ((x1) ^ (x5))) ^ ((x3 & (x5)) ^ (x0)))

#define F3(x6, x5, x4, x3, x2, x1, x0) \
	(((x3) & (((x1) & (x2)) ^ (x6) ^ (x0))) \
	^ ((x1) & (x4)) ^ ((x2) & (x5)) ^ (x0))

#define F4(x6, x5, x4, x3, x2, x1, x0) \
	(((x3) & (((x1) & (x2)) ^ ((x4) | (x6)) ^ (x5))) \
	^ ((x4) & ((~(x2) & (x5)) ^ (x1) ^ (x6) ^ (x0))) \
	^ ((x2) & (x6)) ^ (x0))

#define F5(x6, x5, x4, x3, x2, x1, x0) \
	(((x0) & ~(((x1) & (x2) & (x3)) ^ (x5))) \
	^ ((x1) & (x4)) ^ ((x2) & (x5)) ^ ((x3) & (x6)))

#define STEP1(x7, x6, x5, x4, x3, x2, x1, x0, w) { \
		uint32_t t = F1(x3, x4, x1, x0, x5, x2, x6); \
		(x7) =(SPH_ROTR32(t, 7) + SPH_ROTR32((x7), 11) \
			+ (w)); \
	}

#define STEP2(x7, x6, x5, x4, x3, x2, x1, x0, w, c) { \
		uint32_t t = F2(x6, x2, x1, x0, x3, x4, x5); \
		(x7) =(SPH_ROTR32(t, 7) + SPH_ROTR32((x7), 11) \
			+ (w) + (c)); \
	}

#define STEP3(x7, x6, x5, x4, x3, x2, x1, x0, w, c) { \
		uint32_t t = F3(x2, x6, x0, x4, x3, x1, x5); \
		(x7) =(SPH_ROTR32(t, 7) + SPH_ROTR32((x7), 11) \
			+ (w) + (c)); \
	}

#define STEP4(x7, x6, x5, x4, x3, x2, x1, x0, w, c) { \
		uint32_t t = F4(x1, x5, x3, x2, x0, x4, x6); \
		(x7) =(SPH_ROTR32(t, 7) + SPH_ROTR32((x7), 11) \
			+ (w) + (c)); \
	}

#define STEP5(x7, x6, x5, x4, x3, x2, x1, x0, w, c) { \
		uint32_t t = F5(x2, x5, x0, x6, x4, x3, x1); \
		(x7) =(SPH_ROTR32(t, 7) + SPH_ROTR32((x7), 11) \
			+ (w) + (c)); \
	}

__global__
void x17_haval256_gpu_hash_64(uint32_t threads, uint32_t startNounce, const uint64_t *const __restrict__ g_hash, uint32_t target, uint32_t *const __restrict__ ret)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		uint32_t *inpHash = (uint32_t*)&g_hash[8 * thread];
		uint32_t hash[16];

		uint32_t buf[32] = {0};

		uint32_t s0 = 0x243F6A88;
		uint32_t s1 = 0x85A308D3;
		uint32_t s2 = 0x13198A2E;
		uint32_t s3 = 0x03707344;
		uint32_t s4 = 0xA4093822;
		uint32_t s5 = 0x299F31D0;
		uint32_t s6 = 0x082EFA98;
		uint32_t s7 = 0xEC4E6C89;

#pragma unroll
		for(int i = 0; i<16; i++)
		{
			hash[i] = inpHash[i];
		}

		///////// input big /////////////////////

#pragma unroll
		for(int i = 0; i<16; i++)
		{
				buf[i] = hash[i];
		}

		buf[16] = 0x00000001;
		buf[29] = 0x40290000;
		buf[30] = 0x00000200;

		STEP1(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 0]); 
		STEP1(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 1]);
		STEP1(s5, s4, s3, s2, s1, s0, s7, s6, buf[ 2]);
		STEP1(s4, s3, s2, s1, s0, s7, s6, s5, buf[ 3]);
		STEP1(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 4]);
		STEP1(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 5]);
		STEP1(s1, s0, s7, s6, s5, s4, s3, s2, buf[ 6]);
		STEP1(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 7]);
		STEP1(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 8]);
		STEP1(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 9]);
		STEP1(s5, s4, s3, s2, s1, s0, s7, s6, buf[10]);
		STEP1(s4, s3, s2, s1, s0, s7, s6, s5, buf[11]);
		STEP1(s3, s2, s1, s0, s7, s6, s5, s4, buf[12]);
		STEP1(s2, s1, s0, s7, s6, s5, s4, s3, buf[13]);
		STEP1(s1, s0, s7, s6, s5, s4, s3, s2, buf[14]);
		STEP1(s0, s7, s6, s5, s4, s3, s2, s1, buf[15]);
		STEP1(s7, s6, s5, s4, s3, s2, s1, s0, buf[16]);
		STEP1(s6, s5, s4, s3, s2, s1, s0, s7, buf[17]);
		STEP1(s5, s4, s3, s2, s1, s0, s7, s6, buf[18]);
		STEP1(s4, s3, s2, s1, s0, s7, s6, s5, buf[19]);
		STEP1(s3, s2, s1, s0, s7, s6, s5, s4, buf[20]);
		STEP1(s2, s1, s0, s7, s6, s5, s4, s3, buf[21]);
		STEP1(s1, s0, s7, s6, s5, s4, s3, s2, buf[22]);
		STEP1(s0, s7, s6, s5, s4, s3, s2, s1, buf[23]);
		STEP1(s7, s6, s5, s4, s3, s2, s1, s0, buf[24]);
		STEP1(s6, s5, s4, s3, s2, s1, s0, s7, buf[25]);
		STEP1(s5, s4, s3, s2, s1, s0, s7, s6, buf[26]);
		STEP1(s4, s3, s2, s1, s0, s7, s6, s5, buf[27]);
		STEP1(s3, s2, s1, s0, s7, s6, s5, s4, buf[28]);
		STEP1(s2, s1, s0, s7, s6, s5, s4, s3, buf[29]);
		STEP1(s1, s0, s7, s6, s5, s4, s3, s2, buf[30]);
		STEP1(s0, s7, s6, s5, s4, s3, s2, s1, buf[31]);

		STEP2(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 5], SPH_C32(0x452821E6));
		STEP2(s6, s5, s4, s3, s2, s1, s0, s7, buf[14], SPH_C32(0x38D01377));
		STEP2(s5, s4, s3, s2, s1, s0, s7, s6, buf[26], SPH_C32(0xBE5466CF));
		STEP2(s4, s3, s2, s1, s0, s7, s6, s5, buf[18], SPH_C32(0x34E90C6C));
		STEP2(s3, s2, s1, s0, s7, s6, s5, s4, buf[11], SPH_C32(0xC0AC29B7));
		STEP2(s2, s1, s0, s7, s6, s5, s4, s3, buf[28], SPH_C32(0xC97C50DD));
		STEP2(s1, s0, s7, s6, s5, s4, s3, s2, buf[ 7], SPH_C32(0x3F84D5B5));
		STEP2(s0, s7, s6, s5, s4, s3, s2, s1, buf[16], SPH_C32(0xB5470917));
		STEP2(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 0], SPH_C32(0x9216D5D9));
		STEP2(s6, s5, s4, s3, s2, s1, s0, s7, buf[23], SPH_C32(0x8979FB1B));
		STEP2(s5, s4, s3, s2, s1, s0, s7, s6, buf[20], SPH_C32(0xD1310BA6));
		STEP2(s4, s3, s2, s1, s0, s7, s6, s5, buf[22], SPH_C32(0x98DFB5AC));
		STEP2(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 1], SPH_C32(0x2FFD72DB));
		STEP2(s2, s1, s0, s7, s6, s5, s4, s3, buf[10], SPH_C32(0xD01ADFB7));
		STEP2(s1, s0, s7, s6, s5, s4, s3, s2, buf[ 4], SPH_C32(0xB8E1AFED));
		STEP2(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 8], SPH_C32(0x6A267E96));
		STEP2(s7, s6, s5, s4, s3, s2, s1, s0, buf[30], SPH_C32(0xBA7C9045));
		STEP2(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 3], SPH_C32(0xF12C7F99));
		STEP2(s5, s4, s3, s2, s1, s0, s7, s6, buf[21], SPH_C32(0x24A19947));
		STEP2(s4, s3, s2, s1, s0, s7, s6, s5, buf[ 9], SPH_C32(0xB3916CF7));
		STEP2(s3, s2, s1, s0, s7, s6, s5, s4, buf[17], SPH_C32(0x0801F2E2));
		STEP2(s2, s1, s0, s7, s6, s5, s4, s3, buf[24], SPH_C32(0x858EFC16));
		STEP2(s1, s0, s7, s6, s5, s4, s3, s2, buf[29], SPH_C32(0x636920D8));
		STEP2(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 6], SPH_C32(0x71574E69));
		STEP2(s7, s6, s5, s4, s3, s2, s1, s0, buf[19], SPH_C32(0xA458FEA3));
		STEP2(s6, s5, s4, s3, s2, s1, s0, s7, buf[12], SPH_C32(0xF4933D7E));
		STEP2(s5, s4, s3, s2, s1, s0, s7, s6, buf[15], SPH_C32(0x0D95748F));
		STEP2(s4, s3, s2, s1, s0, s7, s6, s5, buf[13], SPH_C32(0x728EB658));
		STEP2(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 2], SPH_C32(0x718BCD58));
		STEP2(s2, s1, s0, s7, s6, s5, s4, s3, buf[25], SPH_C32(0x82154AEE));
		STEP2(s1, s0, s7, s6, s5, s4, s3, s2, buf[31], SPH_C32(0x7B54A41D));
		STEP2(s0, s7, s6, s5, s4, s3, s2, s1, buf[27], SPH_C32(0xC25A59B5));
		STEP3(s7, s6, s5, s4, s3, s2, s1, s0, buf[19], SPH_C32(0x9C30D539));
		STEP3(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 9], SPH_C32(0x2AF26013));
		STEP3(s5, s4, s3, s2, s1, s0, s7, s6, buf[ 4], SPH_C32(0xC5D1B023));
		STEP3(s4, s3, s2, s1, s0, s7, s6, s5, buf[20], SPH_C32(0x286085F0));
		STEP3(s3, s2, s1, s0, s7, s6, s5, s4, buf[28], SPH_C32(0xCA417918));
		STEP3(s2, s1, s0, s7, s6, s5, s4, s3, buf[17], SPH_C32(0xB8DB38EF));
		STEP3(s1, s0, s7, s6, s5, s4, s3, s2, buf[ 8], SPH_C32(0x8E79DCB0));
		STEP3(s0, s7, s6, s5, s4, s3, s2, s1, buf[22], SPH_C32(0x603A180E));
		STEP3(s7, s6, s5, s4, s3, s2, s1, s0, buf[29], SPH_C32(0x6C9E0E8B));
		STEP3(s6, s5, s4, s3, s2, s1, s0, s7, buf[14], SPH_C32(0xB01E8A3E));
		STEP3(s5, s4, s3, s2, s1, s0, s7, s6, buf[25], SPH_C32(0xD71577C1));
		STEP3(s4, s3, s2, s1, s0, s7, s6, s5, buf[12], SPH_C32(0xBD314B27));
		STEP3(s3, s2, s1, s0, s7, s6, s5, s4, buf[24], SPH_C32(0x78AF2FDA));
		STEP3(s2, s1, s0, s7, s6, s5, s4, s3, buf[30], SPH_C32(0x55605C60));
		STEP3(s1, s0, s7, s6, s5, s4, s3, s2, buf[16], SPH_C32(0xE65525F3));
		STEP3(s0, s7, s6, s5, s4, s3, s2, s1, buf[26], SPH_C32(0xAA55AB94));
		STEP3(s7, s6, s5, s4, s3, s2, s1, s0, buf[31], SPH_C32(0x57489862));
		STEP3(s6, s5, s4, s3, s2, s1, s0, s7, buf[15], SPH_C32(0x63E81440));
		STEP3(s5, s4, s3, s2, s1, s0, s7, s6, buf[ 7], SPH_C32(0x55CA396A));
		STEP3(s4, s3, s2, s1, s0, s7, s6, s5, buf[ 3], SPH_C32(0x2AAB10B6));
		STEP3(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 1], SPH_C32(0xB4CC5C34));
		STEP3(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 0], SPH_C32(0x1141E8CE));
		STEP3(s1, s0, s7, s6, s5, s4, s3, s2, buf[18], SPH_C32(0xA15486AF));
		STEP3(s0, s7, s6, s5, s4, s3, s2, s1, buf[27], SPH_C32(0x7C72E993));
		STEP3(s7, s6, s5, s4, s3, s2, s1, s0, buf[13], SPH_C32(0xB3EE1411));
		STEP3(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 6], SPH_C32(0x636FBC2A));
		STEP3(s5, s4, s3, s2, s1, s0, s7, s6, buf[21], SPH_C32(0x2BA9C55D));
		STEP3(s4, s3, s2, s1, s0, s7, s6, s5, buf[10], SPH_C32(0x741831F6));
		STEP3(s3, s2, s1, s0, s7, s6, s5, s4, buf[23], SPH_C32(0xCE5C3E16));
		STEP3(s2, s1, s0, s7, s6, s5, s4, s3, buf[11], SPH_C32(0x9B87931E));
		STEP3(s1, s0, s7, s6, s5, s4, s3, s2, buf[ 5], SPH_C32(0xAFD6BA33));
		STEP3(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 2], SPH_C32(0x6C24CF5C));

		STEP4(s7, s6, s5, s4, s3, s2, s1, s0, buf[24], SPH_C32(0x7A325381));
		STEP4(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 4], SPH_C32(0x28958677));
		STEP4(s5, s4, s3, s2, s1, s0, s7, s6, buf[ 0], SPH_C32(0x3B8F4898));
		STEP4(s4, s3, s2, s1, s0, s7, s6, s5, buf[14], SPH_C32(0x6B4BB9AF));
		STEP4(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 2], SPH_C32(0xC4BFE81B));
		STEP4(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 7], SPH_C32(0x66282193));
		STEP4(s1, s0, s7, s6, s5, s4, s3, s2, buf[28], SPH_C32(0x61D809CC));
		STEP4(s0, s7, s6, s5, s4, s3, s2, s1, buf[23], SPH_C32(0xFB21A991));
		STEP4(s7, s6, s5, s4, s3, s2, s1, s0, buf[26], SPH_C32(0x487CAC60));
		STEP4(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 6], SPH_C32(0x5DEC8032));
		STEP4(s5, s4, s3, s2, s1, s0, s7, s6, buf[30], SPH_C32(0xEF845D5D));
		STEP4(s4, s3, s2, s1, s0, s7, s6, s5, buf[20], SPH_C32(0xE98575B1));
		STEP4(s3, s2, s1, s0, s7, s6, s5, s4, buf[18], SPH_C32(0xDC262302));
		STEP4(s2, s1, s0, s7, s6, s5, s4, s3, buf[25], SPH_C32(0xEB651B88));
		STEP4(s1, s0, s7, s6, s5, s4, s3, s2, buf[19], SPH_C32(0x23893E81));
		STEP4(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 3], SPH_C32(0xD396ACC5));
		STEP4(s7, s6, s5, s4, s3, s2, s1, s0, buf[22], SPH_C32(0x0F6D6FF3));
		STEP4(s6, s5, s4, s3, s2, s1, s0, s7, buf[11], SPH_C32(0x83F44239));
		STEP4(s5, s4, s3, s2, s1, s0, s7, s6, buf[31], SPH_C32(0x2E0B4482));
		STEP4(s4, s3, s2, s1, s0, s7, s6, s5, buf[21], SPH_C32(0xA4842004));
		STEP4(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 8], SPH_C32(0x69C8F04A));
		STEP4(s2, s1, s0, s7, s6, s5, s4, s3, buf[27], SPH_C32(0x9E1F9B5E));
		STEP4(s1, s0, s7, s6, s5, s4, s3, s2, buf[12], SPH_C32(0x21C66842));
		STEP4(s0, s7, s6, s5, s4, s3, s2, s1, buf[ 9], SPH_C32(0xF6E96C9A));
		STEP4(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 1], SPH_C32(0x670C9C61));
		STEP4(s6, s5, s4, s3, s2, s1, s0, s7, buf[29], SPH_C32(0xABD388F0));
		STEP4(s5, s4, s3, s2, s1, s0, s7, s6, buf[ 5], SPH_C32(0x6A51A0D2));
		STEP4(s4, s3, s2, s1, s0, s7, s6, s5, buf[15], SPH_C32(0xD8542F68));
		STEP4(s3, s2, s1, s0, s7, s6, s5, s4, buf[17], SPH_C32(0x960FA728));
		STEP4(s2, s1, s0, s7, s6, s5, s4, s3, buf[10], SPH_C32(0xAB5133A3));
		STEP4(s1, s0, s7, s6, s5, s4, s3, s2, buf[16], SPH_C32(0x6EEF0B6C));
		STEP4(s0, s7, s6, s5, s4, s3, s2, s1, buf[13], SPH_C32(0x137A3BE4));

		STEP5(s7, s6, s5, s4, s3, s2, s1, s0, buf[27], SPH_C32(0xBA3BF050));
		STEP5(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 3], SPH_C32(0x7EFB2A98));
		STEP5(s5, s4, s3, s2, s1, s0, s7, s6, buf[21], SPH_C32(0xA1F1651D));
		STEP5(s4, s3, s2, s1, s0, s7, s6, s5, buf[26], SPH_C32(0x39AF0176));
		STEP5(s3, s2, s1, s0, s7, s6, s5, s4, buf[17], SPH_C32(0x66CA593E));
		STEP5(s2, s1, s0, s7, s6, s5, s4, s3, buf[11], SPH_C32(0x82430E88));
		STEP5(s1, s0, s7, s6, s5, s4, s3, s2, buf[20], SPH_C32(0x8CEE8619));
		STEP5(s0, s7, s6, s5, s4, s3, s2, s1, buf[29], SPH_C32(0x456F9FB4));
			
		STEP5(s7, s6, s5, s4, s3, s2, s1, s0, buf[19], SPH_C32(0x7D84A5C3));
		STEP5(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 0], SPH_C32(0x3B8B5EBE));
		STEP5(s5, s4, s3, s2, s1, s0, s7, s6, buf[12], SPH_C32(0xE06F75D8));
		STEP5(s4, s3, s2, s1, s0, s7, s6, s5, buf[ 7], SPH_C32(0x85C12073));
		STEP5(s3, s2, s1, s0, s7, s6, s5, s4, buf[13], SPH_C32(0x401A449F));
		STEP5(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 8], SPH_C32(0x56C16AA6));
		STEP5(s1, s0, s7, s6, s5, s4, s3, s2, buf[31], SPH_C32(0x4ED3AA62));
		STEP5(s0, s7, s6, s5, s4, s3, s2, s1, buf[10], SPH_C32(0x363F7706));
			
		STEP5(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 5], SPH_C32(0x1BFEDF72));
		STEP5(s6, s5, s4, s3, s2, s1, s0, s7, buf[ 9], SPH_C32(0x429B023D));
		STEP5(s5, s4, s3, s2, s1, s0, s7, s6, buf[14], SPH_C32(0x37D0D724));
		STEP5(s4, s3, s2, s1, s0, s7, s6, s5, buf[30], SPH_C32(0xD00A1248));
		STEP5(s3, s2, s1, s0, s7, s6, s5, s4, buf[18], SPH_C32(0xDB0FEAD3));
		STEP5(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 6], SPH_C32(0x49F1C09B));
		STEP5(s1, s0, s7, s6, s5, s4, s3, s2, buf[28], SPH_C32(0x075372C9));
		STEP5(s0, s7, s6, s5, s4, s3, s2, s1, buf[24], SPH_C32(0x80991B7B));
			
		STEP5(s7, s6, s5, s4, s3, s2, s1, s0, buf[ 2], SPH_C32(0x25D479D8));
		/*
		STEP5(s6, s5, s4, s3, s2, s1, s0, s7, buf[23], SPH_C32(0xF6E8DEF7));
		STEP5(s5, s4, s3, s2, s1, s0, s7, s6, buf[16], SPH_C32(0xE3FE501A));
		STEP5(s4, s3, s2, s1, s0, s7, s6, s5, buf[22], SPH_C32(0xB6794C3B));
		STEP5(s3, s2, s1, s0, s7, s6, s5, s4, buf[ 4], SPH_C32(0x976CE0BD));
		STEP5(s2, s1, s0, s7, s6, s5, s4, s3, buf[ 1], SPH_C32(0x04C006BA));
		STEP5(s1, s0, s7, s6, s5, s4, s3, s2, buf[25], SPH_C32(0xC1A94FB6));
		STEP5(s0, s7, s6, s5, s4, s3, s2, s1, buf[15], SPH_C32(0x409F60C4));

		inpHash[0] = s0 + 0x243F6A88;
		inpHash[1] = s1 + 0x85A308D3;
		inpHash[2] = s2 + 0x13198A2E;
		inpHash[3] = s3 + 0x03707344;
		inpHash[4] = s4 + 0xA4093822;
		inpHash[5] = s5 + 0x299F31D0;
		inpHash[6] = s6 + 0x082EFA98;
		inpHash[7] = s7 + 0xEC4E6C89;
		*/
		if(s7 + 0xEC4E6C89 <= target)
		{
			uint32_t tmp = atomicExch(ret, startNounce + thread);
			if(tmp != 0xffffffff)
				ret[1] = tmp;
		}

	} // threads
}

__host__
void x17_haval256_cpu_init(int thr_id, uint32_t threads)
{
	cudaMalloc(&d_nonce[thr_id], 2 * sizeof(uint32_t));
}

__host__
void x17_haval256_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce,  uint32_t *d_hash, uint32_t target, uint32_t *result)
{
	const uint32_t threadsperblock = 512;

	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);
	CUDA_SAFE_CALL(cudaMemsetAsync(d_nonce[thr_id], 0xff, 2 * sizeof(uint32_t), gpustream[thr_id]));

	x17_haval256_gpu_hash_64 <<<grid, block, 0, gpustream[thr_id] >>>(threads, startNounce, (uint64_t*)d_hash, target, d_nonce[thr_id]);
	CUDA_SAFE_CALL(cudaMemcpyAsync(result, d_nonce[thr_id], 2 * sizeof(uint32_t), cudaMemcpyDeviceToHost, gpustream[thr_id]));
	CUDA_SAFE_CALL(cudaStreamSynchronize(gpustream[thr_id]));

}
