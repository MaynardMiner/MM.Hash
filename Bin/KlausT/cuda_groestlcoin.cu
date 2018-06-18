// Auf Groestlcoin spezialisierte Version von Groestl inkl. Bitslice

#include <stdio.h>
#include <memory.h>

#include "cuda_helper.h"
#include <host_defines.h>


// globaler Speicher für alle HeftyHashes aller Threads
static uint32_t *d_resultNonce[MAX_GPUS];

__constant__ uint32_t groestlcoin_gpu_msg[20];

// 64 Register Variante für Compute 3.0
#include "groestl_functions_quad.cu"
#include "bitslice_transformations_quad.cu"

#define SWAB32(x) cuda_swab32(x)

__global__ __launch_bounds__(512, 2)
void groestlcoin_gpu_hash_quad(uint32_t threads, uint32_t startNounce, uint32_t *resNounce, int thr_id, uint32_t target)
{
    // durch 4 dividieren, weil jeweils 4 Threads zusammen ein Hash berechnen
    uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x) >> 2;
//    if (thread < threads)
    {
        // GROESTL
		uint32_t paddedInput[8] = { 0 };
        const uint32_t nounce = startNounce + thread;
		paddedInput[0] = groestlcoin_gpu_msg[(threadIdx.x & 3)];
		paddedInput[1] = groestlcoin_gpu_msg[4 + (threadIdx.x & 3)];
		paddedInput[2] = groestlcoin_gpu_msg[8 + (threadIdx.x & 3)];
		paddedInput[3] = groestlcoin_gpu_msg[12 + (threadIdx.x & 3)];
		paddedInput[4] = groestlcoin_gpu_msg[16 + (threadIdx.x & 3)];
		if ((threadIdx.x & 3) == 3) paddedInput[4] = SWAB32(nounce);
		if ((threadIdx.x & 3) == 0) paddedInput[5] = 0x80;
		if ((threadIdx.x & 3)==3) paddedInput[7] = 0x01000000;

        uint32_t msgBitsliced[8];
        myr_to_bitslice_quad(paddedInput, msgBitsliced);

        uint32_t state[8];

		groestl512_progressMessage_quad(state, msgBitsliced);

		msgBitsliced[ 0] = __byte_perm(state[ 0], 0x00800100, 0x4341 + ((threadIdx.x & 3)==3)*0x2000);
		msgBitsliced[ 1] = __byte_perm(state[ 1], 0x00800100, 0x4341);
		msgBitsliced[ 2] = __byte_perm(state[ 2], 0x00800100, 0x4341);
		msgBitsliced[ 3] = __byte_perm(state[ 3], 0x00800100, 0x4341);
		msgBitsliced[ 4] = __byte_perm(state[ 4], 0x00800100, 0x4341);
		msgBitsliced[ 5] = __byte_perm(state[ 5], 0x00800100, 0x4341);
		msgBitsliced[ 6] = __byte_perm(state[ 6], 0x00800100, 0x4341);
		msgBitsliced[7] = __byte_perm(state[7], 0x00800100, 0x4341 + ((threadIdx.x & 3) == 0) * 0x0010);
		
		groestl512_progressMessage_quad(state, msgBitsliced);

		uint32_t out_state[16];
        from_bitslice_quad_final(state, out_state);
        
		if ((threadIdx.x & 3) == 0)
        {
			if (out_state[7] <= target) 
			{
				uint32_t tmp = atomicExch(resNounce, nounce);
				if (tmp != 0xffffffff)
					resNounce[1] = tmp;
			}
        }
    }
}

// Setup-Funktionen
__host__ void groestlcoin_cpu_init(int thr_id, uint32_t threads)
{
    cudaMalloc(&d_resultNonce[thr_id], 2 * sizeof(uint32_t)); 
}

__host__ void groestlcoin_cpu_setBlock(int thr_id, void *data )
{
    uint32_t msgBlock[20];
    memcpy(&msgBlock[0], data, 80);
	cudaMemcpyToSymbolAsync(groestlcoin_gpu_msg, msgBlock, 80, 0, cudaMemcpyHostToDevice, gpustream[thr_id]);

	cudaMemsetAsync(d_resultNonce[thr_id], 0xFF, 2 * sizeof(uint32_t), gpustream[thr_id]);
}

__host__ void groestlcoin_cpu_hash(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *nounce, uint32_t target)
{
    uint32_t threadsperblock = 512;

    // Compute 3.0 benutzt die registeroptimierte Quad Variante mit Warp Shuffle
    // mit den Quad Funktionen brauchen wir jetzt 4 threads pro Hash, daher Faktor 4 bei der Blockzahl
    int factor = 4;

     // berechne wie viele Thread Blocks wir brauchen
    dim3 grid(factor*((threads + threadsperblock-1)/threadsperblock));
    dim3 block(threadsperblock);

    groestlcoin_gpu_hash_quad<<<grid, block, 0, gpustream[thr_id]>>>(threads, startNounce, d_resultNonce[thr_id], thr_id, target);

    CUDA_SAFE_CALL(cudaMemcpyAsync(nounce, d_resultNonce[thr_id], 2 * sizeof(uint32_t), cudaMemcpyDeviceToHost, gpustream[thr_id])); cudaStreamSynchronize(gpustream[thr_id]);
}
