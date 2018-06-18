/*
* Lyra2 (v2) CUDA Implementation
*
* Based on tpruvot/djm34/VTC sources and incredible 2x boost by Nanashi Meiyo-Meijin (May 2016)
*/

#include <cstdio>
#include <memory.h>
#include "cuda_helper.h"
#include "cuda_lyra2v2_sm3.cuh"

#ifdef __INTELLISENSE__
/* just for vstudio code colors */
#define __CUDA_ARCH__ 500
#endif

#define TPB5x 128
#define TPB5x2 32

#if __CUDA_ARCH__ >= 500

#include "cuda_lyra2_vectors.h"

#define Nrow 4
#define Ncol 4
#define memshift 3

__device__ uint2x4 *DMatrix;

static __device__ __forceinline__ uint2 LD4S(uint2 *shared_mem, const int index)
{
	return shared_mem[(index * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x];
}

static __device__ __forceinline__ void ST4S(uint2 *shared_mem, const int index, const uint2 data)
{
	shared_mem[(index * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x] = data;
}

static __device__ __forceinline__ uint2 shuffle2(uint2 a, uint32_t b, uint32_t c)
{
	return make_uint2(__shfl_sync(0xffffffff, a.x, b, c), __shfl_sync(0xffffffff, a.y, b, c));
}

static __device__ __forceinline__
void Gfunc_v5(uint2 &a, uint2 &b, uint2 &c, uint2 &d)
{
	a += b; d = eorswap32(a, d);
	c += d; b ^= c; b = ROR24(b);
	a += b; d ^= a; d = ROR16(d);
	c += d; b ^= c; b = ROR2(b, 63);
}

static __device__ __forceinline__
void round_lyra_v5(uint2x4 s[4])
{
	Gfunc_v5(s[0].x, s[1].x, s[2].x, s[3].x);
	Gfunc_v5(s[0].y, s[1].y, s[2].y, s[3].y);
	Gfunc_v5(s[0].z, s[1].z, s[2].z, s[3].z);
	Gfunc_v5(s[0].w, s[1].w, s[2].w, s[3].w);

	Gfunc_v5(s[0].x, s[1].y, s[2].z, s[3].w);
	Gfunc_v5(s[0].y, s[1].z, s[2].w, s[3].x);
	Gfunc_v5(s[0].z, s[1].w, s[2].x, s[3].y);
	Gfunc_v5(s[0].w, s[1].x, s[2].y, s[3].z);
}

static __device__ __forceinline__
void round_lyra_v5(uint2 s[4])
{
	Gfunc_v5(s[0], s[1], s[2], s[3]);
	s[1] = shuffle2(s[1], threadIdx.x + 1, 4);
	s[2] = shuffle2(s[2], threadIdx.x + 2, 4);
	s[3] = shuffle2(s[3], threadIdx.x + 3, 4);
	Gfunc_v5(s[0], s[1], s[2], s[3]);
	s[1] = shuffle2(s[1], threadIdx.x + 3, 4);
	s[2] = shuffle2(s[2], threadIdx.x + 2, 4);
	s[3] = shuffle2(s[3], threadIdx.x + 1, 4);
}

static __device__ __forceinline__
void reduceDuplexRowSetup2(uint2 *shared_mem, uint2 state[4])
{
	uint2 state1[Ncol][3], state0[Ncol][3], state2[3];
	int i, j;

#pragma unroll
	for(int i = 0; i < Ncol; i++)
	{
#pragma unroll
		for(j = 0; j < 3; j++)
			state0[Ncol - i - 1][j] = state[j];
		round_lyra_v5(state);
	}

	//#pragma unroll 4
	for(i = 0; i < Ncol; i++)
	{
#pragma unroll
		for(j = 0; j < 3; j++)
			state[j] ^= state0[i][j];

		round_lyra_v5(state);

#pragma unroll
		for(j = 0; j < 3; j++)
			state1[Ncol - i - 1][j] = state0[i][j];

#pragma unroll
		for(j = 0; j < 3; j++)
			state1[Ncol - i - 1][j] ^= state[j];
	}

	for(i = 0; i < Ncol; i++)
	{
		const uint32_t s0 = memshift * Ncol * 0 + i * memshift;
		const uint32_t s2 = memshift * Ncol * 2 + memshift * (Ncol - 1) - i*memshift;

#pragma unroll
		for(j = 0; j < 3; j++)
			state[j] ^= state1[i][j] + state0[i][j];

		round_lyra_v5(state);

#pragma unroll
		for(j = 0; j < 3; j++)
			state2[j] = state1[i][j];

#pragma unroll
		for(j = 0; j < 3; j++)
			state2[j] ^= state[j];

#pragma unroll
		for(j = 0; j < 3; j++)
			ST4S(shared_mem, s2 + j, state2[j]);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if(threadIdx.x == 0)
		{
			state0[i][0] ^= Data2;
			state0[i][1] ^= Data0;
			state0[i][2] ^= Data1;
		}
		else
		{
			state0[i][0] ^= Data0;
			state0[i][1] ^= Data1;
			state0[i][2] ^= Data2;
		}

#pragma unroll
		for(j = 0; j < 3; j++)
			ST4S(shared_mem, s0 + j, state0[i][j]);

#pragma unroll
		for(j = 0; j < 3; j++)
			state0[i][j] = state2[j];

	}

	for(i = 0; i < Ncol; i++)
	{
		const uint32_t s1 = memshift * Ncol * 1 + i*memshift;
		const uint32_t s3 = memshift * Ncol * 3 + memshift * (Ncol - 1) - i*memshift;

#pragma unroll
		for(j = 0; j < 3; j++)
			state[j] ^= state1[i][j] + state0[Ncol - i - 1][j];

		round_lyra_v5(state);

#pragma unroll
		for(j = 0; j < 3; j++)
			state0[Ncol - i - 1][j] ^= state[j];

#pragma unroll
		for(j = 0; j < 3; j++)
			ST4S(shared_mem, s3 + j, state0[Ncol - i - 1][j]);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if(threadIdx.x == 0)
		{
			state1[i][0] ^= Data2;
			state1[i][1] ^= Data0;
			state1[i][2] ^= Data1;
		}
		else
		{
			state1[i][0] ^= Data0;
			state1[i][1] ^= Data1;
			state1[i][2] ^= Data2;
		}

#pragma unroll
		for(j = 0; j < 3; j++)
			ST4S(shared_mem, s1 + j, state1[i][j]);
	}
	__syncthreads();
}

static __device__
void reduceDuplexRowt2(uint2 *shared_mem, const int rowIn, const int rowInOut, const int rowOut, uint2 state[4])
{
	uint2 state1[3], state2[3];
	const uint32_t ps1 = memshift * Ncol * rowIn;
	const uint32_t ps2 = memshift * Ncol * rowInOut;
	const uint32_t ps3 = memshift * Ncol * rowOut;

	for(int i = 0; i < Ncol; i++)
	{
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 + i*memshift;
		const uint32_t s3 = ps3 + i*memshift;

#pragma unroll
		for(int j = 0; j < 3; j++)
			state1[j] = LD4S(shared_mem, s1 + j);

#pragma unroll
		for(int j = 0; j < 3; j++)
			state2[j] = LD4S(shared_mem, s2 + j);

#pragma unroll
		for(int j = 0; j < 3; j++)
			state[j] ^= state1[j] + state2[j];

		round_lyra_v5(state);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if(threadIdx.x == 0)
		{
			state2[0] ^= Data2;
			state2[1] ^= Data0;
			state2[2] ^= Data1;
		}
		else
		{
			state2[0] ^= Data0;
			state2[1] ^= Data1;
			state2[2] ^= Data2;
		}

#pragma unroll
		for(int j = 0; j < 3; j++)
			ST4S(shared_mem, s2 + j, state2[j]);
		__syncthreads();

#pragma unroll
		for(int j = 0; j < 3; j++)
			ST4S(shared_mem, s3 + j, LD4S(shared_mem, s3 + j) ^ state[j]);
		__syncthreads();
	}
}

static __device__
void reduceDuplexRowt2x4(uint2 *shared_mem, const int rowInOut, uint2 state[4])
{
	const int rowIn = 2;
	const int rowOut = 3;

	int i, j;
	uint2 last[3];
	const uint32_t ps1 = memshift * Ncol * rowIn;
	const uint32_t ps2 = memshift * Ncol * rowInOut;

#pragma unroll
	for(int j = 0; j < 3; j++)
		last[j] = LD4S(shared_mem, ps2 + j);

#pragma unroll
	for(int j = 0; j < 3; j++)
		state[j] ^= LD4S(shared_mem, ps1 + j) + last[j];

	round_lyra_v5(state);

	uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
	uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
	uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

	if(threadIdx.x == 0)
	{
		last[0] ^= Data2;
		last[1] ^= Data0;
		last[2] ^= Data1;
	}
	else
	{
		last[0] ^= Data0;
		last[1] ^= Data1;
		last[2] ^= Data2;
	}

	if(rowInOut == rowOut)
	{
#pragma unroll
		for(j = 0; j < 3; j++)
			last[j] ^= state[j];
	}

	for(i = 1; i < Ncol; i++)
	{
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 + i*memshift;

#pragma unroll
		for(j = 0; j < 3; j++)
			state[j] ^= LD4S(shared_mem, s1 + j) + LD4S(shared_mem, s2 + j);

		round_lyra_v5(state);
	}

#pragma unroll
	for(int j = 0; j < 3; j++)
		state[j] ^= last[j];
}

__global__
__launch_bounds__(TPB5x, 1)
void lyra2v2_gpu_hash_32_1(uint32_t threads, uint2 *inputHash)
{
	const uint32_t thread = blockDim.x * blockIdx.x + threadIdx.x;

	const uint2x4 blake2b_IV[2] = {
		0xf3bcc908UL, 0x6a09e667UL, 0x84caa73bUL, 0xbb67ae85UL,
		0xfe94f82bUL, 0x3c6ef372UL, 0x5f1d36f1UL, 0xa54ff53aUL,
		0xade682d1UL, 0x510e527fUL, 0x2b3e6c1fUL, 0x9b05688cUL,
		0xfb41bd6bUL, 0x1f83d9abUL, 0x137e2179UL, 0x5be0cd19UL
	};

	const uint2x4 Mask[2] = {
		0x00000020UL, 0x00000000UL, 0x00000020UL, 0x00000000UL,
		0x00000020UL, 0x00000000UL, 0x00000001UL, 0x00000000UL,
		0x00000004UL, 0x00000000UL, 0x00000004UL, 0x00000000UL,
		0x00000080UL, 0x00000000UL, 0x00000000UL, 0x01000000UL
	};

	uint2x4 state[4];

	if(thread < threads)
	{
		state[0].x = state[1].x = __ldg(&inputHash[thread + threads * 0]);
		state[0].y = state[1].y = __ldg(&inputHash[thread + threads * 1]);
		state[0].z = state[1].z = __ldg(&inputHash[thread + threads * 2]);
		state[0].w = state[1].w = __ldg(&inputHash[thread + threads * 3]);
		state[2] = blake2b_IV[0];
		state[3] = blake2b_IV[1];

		for(int i = 0; i<12; i++)
			round_lyra_v5(state);

		state[0] ^= Mask[0];
		state[1] ^= Mask[1];

		for(int i = 0; i<12; i++)
			round_lyra_v5(state);

		DMatrix[blockDim.x * gridDim.x * 0 + thread] = state[0];
		DMatrix[blockDim.x * gridDim.x * 1 + thread] = state[1];
		DMatrix[blockDim.x * gridDim.x * 2 + thread] = state[2];
		DMatrix[blockDim.x * gridDim.x * 3 + thread] = state[3];
	}
}

__global__
__launch_bounds__(TPB5x2, 1)
void lyra2v2_gpu_hash_32_2(uint32_t threads)
{
	const uint32_t thread = blockDim.y * blockIdx.x + threadIdx.y;
	extern __shared__ uint2 shared_mem[];
	if(thread < threads)
	{
		uint2 state[4];
		state[0] = ((uint2*)DMatrix)[(0 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[1] = ((uint2*)DMatrix)[(1 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[2] = ((uint2*)DMatrix)[(2 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[3] = ((uint2*)DMatrix)[(3 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];

		reduceDuplexRowSetup2(shared_mem, state);

		uint32_t rowa;
		int prev = 3;

		for(int i = 0; i < 3; i++)
		{
			rowa = __shfl_sync(0xffffffff, state[0].x, 0, 4) & 3;
			reduceDuplexRowt2(shared_mem, prev, rowa, i, state);
			prev = i;
		}

		rowa = __shfl_sync(0xffffffff, state[0].x, 0, 4) & 3;
		reduceDuplexRowt2x4(shared_mem, rowa, state);

		((uint2*)DMatrix)[(0 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[0];
		((uint2*)DMatrix)[(1 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[1];
		((uint2*)DMatrix)[(2 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[2];
		((uint2*)DMatrix)[(3 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[3];
	}
}

__global__
__launch_bounds__(TPB5x, 1)
void lyra2v2_gpu_hash_32_3(uint32_t threads, uint2 *outputHash)
{
	const uint32_t thread = blockDim.x * blockIdx.x + threadIdx.x;

	uint2x4 state[4];

	if(thread < threads)
	{
		state[0] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 0 + thread]);
		state[1] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 1 + thread]);
		state[2] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 2 + thread]);
		state[3] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 3 + thread]);

		for(int i = 0; i < 12; i++)
			round_lyra_v5(state);

		outputHash[thread + threads * 0] = state[0].x;
		outputHash[thread + threads * 1] = state[0].y;
		outputHash[thread + threads * 2] = state[0].z;
		outputHash[thread + threads * 3] = state[0].w;
	}
}

#else
#include "cuda_helper.h"
__global__ void lyra2v2_gpu_hash_32_1(uint32_t threads, uint2 *inputHash)
{}
__global__ void lyra2v2_gpu_hash_32_2(uint32_t threads)
{}
__global__ void lyra2v2_gpu_hash_32_3(uint32_t threads, uint2 *outputHash)
{}
#endif


__host__
void lyra2v2_cpu_init(int thr_id, uint64_t *d_matrix)
{
	// just assign the device pointer allocated in main loop
	CUDA_SAFE_CALL(cudaFuncSetAttribute(lyra2v2_gpu_hash_32_2, cudaFuncAttributePreferredSharedMemoryCarveout, 100)); // make Titan V faster
	CUDA_SAFE_CALL(cudaMemcpyToSymbolAsync(DMatrix, &d_matrix, sizeof(uint64_t*), 0, cudaMemcpyHostToDevice, gpustream[thr_id]));
	if(opt_debug)
		CUDA_SAFE_CALL(cudaDeviceSynchronize());
}

__host__
void lyra2v2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *g_hash)
{
	if(cuda_arch[thr_id] >= 500)
	{

		const uint32_t tpb = TPB5x;

		dim3 grid2((threads + tpb - 1) / tpb);
		dim3 block2(tpb);

		dim3 grid4((threads * 4 + TPB5x2 - 1) / TPB5x2);
		dim3 block4(4, TPB5x2 / 4);

		lyra2v2_gpu_hash_32_1 << < grid2, block2, 0, gpustream[thr_id] >> > (threads, (uint2*)g_hash);
		if(opt_debug)
			CUDA_SAFE_CALL(cudaDeviceSynchronize());
		lyra2v2_gpu_hash_32_2 << < grid4, block4, 384 * TPB5x2, gpustream[thr_id] >> > (threads);
		if(opt_debug)
			CUDA_SAFE_CALL(cudaDeviceSynchronize());
		lyra2v2_gpu_hash_32_3 << < grid2, block2, 0, gpustream[thr_id] >> > (threads, (uint2*)g_hash);
		if(opt_debug)
			CUDA_SAFE_CALL(cudaDeviceSynchronize());

	}
	else
	{

		uint32_t tpb = 16;
		if(cuda_arch[thr_id] >= 350) tpb = TPB35;
		else if(cuda_arch[thr_id] >= 300) tpb = TPB30;
		else if(cuda_arch[thr_id] >= 200) tpb = TPB20;

		dim3 grid((threads + tpb - 1) / tpb);
		dim3 block(tpb);
		lyra2v2_gpu_hash_32_v3 << < grid, block, 0, gpustream[thr_id] >> > (threads, startNounce, (uint2*)g_hash);
		if(opt_debug)
			CUDA_SAFE_CALL(cudaDeviceSynchronize());

	}
	CUDA_SAFE_CALL(cudaGetLastError());
}