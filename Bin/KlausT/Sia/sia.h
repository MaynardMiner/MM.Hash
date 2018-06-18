#pragma once

#define MAXRESULTS 8

#define npt 1
#define blocksize 512

void sia_gpu_init(int thr_id);
void sia_precalc(int thr_id, cudaStream_t cudastream, const uint64_t *blockHeader);
void sia_gpu_hash(cudaStream_t cudastream, int thr_id, uint32_t threads, uint32_t *nonceOut, uint64_t target, uint64_t startnonce);
