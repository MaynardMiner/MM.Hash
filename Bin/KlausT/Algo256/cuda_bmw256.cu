#include <stdio.h>
#include <memory.h>

#include "cuda_helper.h"

static uint32_t *h_nonce[MAX_GPUS];
static uint32_t *d_nonce[MAX_GPUS];

#define shl(x, n)            ((x) << (n))
#define shr(x, n)            ((x) >> (n))
//#define SHR(x, n) SHR2(x, n) 
//#define SHL(x, n) SHL2(x, n) 

#undef SPH_ROTL32
#define SPH_ROTL32 ROTL32


#define ROTL32host(x, n) ROTL32(x,n)
// #define SPH_ROTL32 SPH_ROTL32
#define ss0(x)  (shr((x), 1) ^ shl((x), 3) ^ SPH_ROTL32((x),  4) ^ SPH_ROTL32((x), 19))
#define ss1(x)  (shr((x), 1) ^ shl((x), 2) ^ __byte_perm(x,0,0x2103) ^ SPH_ROTL32((x), 23))
#define ss2(x)  (shr((x), 2) ^ shl((x), 1) ^ SPH_ROTL32((x), 12) ^ SPH_ROTL32((x), 25))
#define ss3(x)  (shr((x), 2) ^ shl((x), 2) ^ SPH_ROTL32((x), 15) ^ SPH_ROTL32((x), 29))
#define ss4(x)  (shr((x), 1) ^ (x))
#define ss5(x)  (shr((x), 2) ^ (x))
#define rs1(x) SPH_ROTL32((x),  3)
#define rs2(x) SPH_ROTL32((x),  7)
#define rs3(x) SPH_ROTL32((x), 13)
#define rs4(x) __byte_perm(x,0,0x1032)
#define rs5(x) SPH_ROTL32((x), 19)
#define rs6(x) SPH_ROTL32((x), 23)
#define rs7(x) SPH_ROTL32((x), 27)


/* Message expansion function 1 */
static __forceinline__ __device__ uint32_t expand32_1(int i, const uint32_t *message, const uint32_t *H, const uint32_t *Q)
{
	return (ss1(Q[i - 16]) + ss2(Q[i - 15]) + ss3(Q[i - 14]) + ss0(Q[i - 13])
					+ ss1(Q[i - 12]) + ss2(Q[i - 11]) + ss3(Q[i - 10]) + ss0(Q[i - 9])
					+ ss1(Q[i - 8]) + ss2(Q[i - 7]) + ss3(Q[i - 6]) + ss0(Q[i - 5])
					+ ss1(Q[i - 4]) + ss2(Q[i - 3]) + ss3(Q[i - 2]) + ss0(Q[i - 1])
					+ ((i*(0x05555555ul) + SPH_ROTL32(message[(i - 16) % 16], ((i - 16) % 16) + 1) + SPH_ROTL32(message[(i - 13) % 16], ((i - 13) % 16) + 1) - SPH_ROTL32(message[(i - 6) % 16], ((i - 6) % 16) + 1)) ^ H[(i - 16 + 7) % 16]));
}

/* Message expansion function 2 */
static __forceinline__ __device__ uint32_t expand32_2(const int i, const uint32_t *message, const uint32_t *H, const uint32_t *Q)
{
	return (
		rs2(Q[i - 13]) + rs3(Q[i - 11]) + rs4(Q[i - 9]) + rs1(Q[i - 15]) +
		+rs5(Q[i - 7]) + rs6(Q[i - 5]) + rs7(Q[i - 3]) + ss4(Q[i - 2]) + ss5(Q[i - 1]));
}

#define TPB 512
__global__	__launch_bounds__(TPB, 2)
void bmw256_gpu_hash_32(uint32_t threads, uint32_t startNounce, uint2 *g_hash, uint32_t *const __restrict__ nonceVector, uint32_t Target)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		uint32_t backup = Target;
		uint32_t message[16] = {0};

		((uint2*)message)[0] = __ldg(&g_hash[thread]);
		((uint2*)message)[1] = __ldg(&g_hash[thread + 1 * threads]);
		((uint2*)message)[2] = __ldg(&g_hash[thread + 2 * threads]);
		((uint2*)message)[3] = __ldg(&g_hash[thread + 3 * threads]);


		const uint32_t h1[16] = {
			(0x40414243), (0x44454647),
			(0x48494A4B), (0x4C4D4E4F),
			(0x50515253), (0x54555657),
			(0x58595A5B), (0x5C5D5E5F),
			(0x60616263), (0x64656667),
			(0x68696A6B), (0x6C6D6E6F),
			(0x70717273), (0x74757677),
			(0x78797A7B), (0x7C7D7E7F)
		};

		message[8] = 0x80;
		message[14] = 0x100;

		uint32_t XL32, XH32, Q[32];

		Q[0] = (message[5] ^ h1[5]) - (message[7] ^ h1[7]) + (message[10] ^ h1[10]) + (message[13] ^ h1[13]) + (message[14] ^ h1[14]);
		Q[1] = (message[6] ^ h1[6]) - (message[8] ^ h1[8]) + (message[11] ^ h1[11]) + (message[14] ^ h1[14]) - (message[15] ^ h1[15]);
		Q[2] = (message[0] ^ h1[0]) + (message[7] ^ h1[7]) + (message[9] ^ h1[9]) - (message[12] ^ h1[12]) + (message[15] ^ h1[15]);
		Q[3] = (message[0] ^ h1[0]) - (message[1] ^ h1[1]) + (message[8] ^ h1[8]) - (message[10] ^ h1[10]) + (message[13] ^ h1[13]);
		Q[4] = (message[1] ^ h1[1]) + (message[2] ^ h1[2]) + (message[9] ^ h1[9]) - (message[11] ^ h1[11]) - (message[14] ^ h1[14]);
		Q[5] = (message[3] ^ h1[3]) - (message[2] ^ h1[2]) + (message[10] ^ h1[10]) - (message[12] ^ h1[12]) + (message[15] ^ h1[15]);
		Q[6] = (message[4] ^ h1[4]) - (message[0] ^ h1[0]) - (message[3] ^ h1[3]) - (message[11] ^ h1[11]) + (message[13] ^ h1[13]);
		Q[7] = (message[1] ^ h1[1]) - (message[4] ^ h1[4]) - (message[5] ^ h1[5]) - (message[12] ^ h1[12]) - (message[14] ^ h1[14]);
		Q[8] = (message[2] ^ h1[2]) - (message[5] ^ h1[5]) - (message[6] ^ h1[6]) + (message[13] ^ h1[13]) - (message[15] ^ h1[15]);
		Q[9] = (message[0] ^ h1[0]) - (message[3] ^ h1[3]) + (message[6] ^ h1[6]) - (message[7] ^ h1[7]) + (message[14] ^ h1[14]);
		Q[10] = (message[8] ^ h1[8]) - (message[1] ^ h1[1]) - (message[4] ^ h1[4]) - (message[7] ^ h1[7]) + (message[15] ^ h1[15]);
		Q[11] = (message[8] ^ h1[8]) - (message[0] ^ h1[0]) - (message[2] ^ h1[2]) - (message[5] ^ h1[5]) + (message[9] ^ h1[9]);
		Q[12] = (message[1] ^ h1[1]) + (message[3] ^ h1[3]) - (message[6] ^ h1[6]) - (message[9] ^ h1[9]) + (message[10] ^ h1[10]);
		Q[13] = (message[2] ^ h1[2]) + (message[4] ^ h1[4]) + (message[7] ^ h1[7]) + (message[10] ^ h1[10]) + (message[11] ^ h1[11]);
		Q[14] = (message[3] ^ h1[3]) - (message[5] ^ h1[5]) + (message[8] ^ h1[8]) - (message[11] ^ h1[11]) - (message[12] ^ h1[12]);
		Q[15] = (message[12] ^ h1[12]) - (message[4] ^ h1[4]) - (message[6] ^ h1[6]) - (message[9] ^ h1[9]) + (message[13] ^ h1[13]);

		Q[0] = ss0(Q[0]) + h1[1];
		Q[1] = ss1(Q[1]) + h1[2];
		Q[2] = ss2(Q[2]) + h1[3];
		Q[3] = ss3(Q[3]) + h1[4];
		Q[4] = ss4(Q[4]) + h1[5];
		Q[5] = ss0(Q[5]) + h1[6];
		Q[6] = ss1(Q[6]) + h1[7];
		Q[7] = ss2(Q[7]) + h1[8];
		Q[8] = ss3(Q[8]) + h1[9];
		Q[9] = ss4(Q[9]) + h1[10];
		Q[10] = ss0(Q[10]) + h1[11];
		Q[11] = ss1(Q[11]) + h1[12];
		Q[12] = ss2(Q[12]) + h1[13];
		Q[13] = ss3(Q[13]) + h1[14];
		Q[14] = ss4(Q[14]) + h1[15];
		Q[15] = ss0(Q[15]) + h1[0];

		Q[16] = ss1(Q[16 - 16]) + ss2(Q[16 - 15]) + ss3(Q[16 - 14]) + ss0(Q[16 - 13])
			+ ss1(Q[16 - 12]) + ss2(Q[16 - 11]) + ss3(Q[16 - 10]) + ss0(Q[16 - 9])
			+ ss1(Q[16 - 8]) + ss2(Q[16 - 7]) + ss3(Q[16 - 6]) + ss0(Q[16 - 5])
			+ ss1(Q[16 - 4]) + ss2(Q[16 - 3]) + ss3(Q[16 - 2]) + ss0(Q[16 - 1])
			+ ((16 * (0x05555555ul) + SPH_ROTL32(message[0], ((16 - 16) % 16) + 1) + SPH_ROTL32(message[3], ((16 - 13) % 16) + 1)) ^ h1[(16 - 16 + 7) % 16]);

		Q[17] = ss1(Q[17 - 16]) + ss2(Q[17 - 15]) + ss3(Q[17 - 14]) + ss0(Q[17 - 13])
			+ ss1(Q[17 - 12]) + ss2(Q[17 - 11]) + ss3(Q[17 - 10]) + ss0(Q[17 - 9])
			+ ss1(Q[17 - 8]) + ss2(Q[17 - 7]) + ss3(Q[17 - 6]) + ss0(Q[17 - 5])
			+ ss1(Q[17 - 4]) + ss2(Q[17 - 3]) + ss3(Q[17 - 2]) + ss0(Q[17 - 1])
			+ ((17 * (0x05555555ul) + SPH_ROTL32(message[(17 - 16) % 16], ((17 - 16) % 16) + 1) + SPH_ROTL32(message[(17 - 13) % 16], ((17 - 13) % 16) + 1)) ^ h1[(17 - 16 + 7) % 16]);

		uint32_t precalc = Q[18 - 16] + Q[18 - 14] + Q[18 - 12] + Q[18 - 10] + Q[18 - 8] + Q[18 - 6]; //+ Q[18 - 4]
		uint32_t precalc2 = Q[19 - 16] + Q[19 - 14] + Q[19 - 12] + Q[19 - 10] + Q[19 - 8] + Q[19 - 6];//+ Q[19 - 4]

		precalc = precalc + Q[18 - 4];
		precalc2 = precalc2 + Q[18 + 1 - 4];
		uint32_t p1 = ((18 * (0x05555555ul) + SPH_ROTL32(message[2], ((18 - 16) % 16) + 1) + SPH_ROTL32(message[5], ((18 - 13) % 16) + 1)) ^ h1[(18 - 16 + 7) % 16]);
		uint32_t p2 = (((18 + 1)*(0x05555555ul) + SPH_ROTL32(message[3], (((18 + 1) - 16) % 16) + 1) + SPH_ROTL32(message[6], (((18 + 1) - 13) % 16) + 1)) ^ h1[((18 + 1) - 16 + 7) % 16]);
		Q[18] = precalc + expand32_2(18, message, h1, Q) + p1;
		Q[18 + 1] = precalc2 + expand32_2(18 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[18 - 16];
		precalc2 = precalc2 - Q[18 + 1 - 16];

		precalc = precalc + Q[20 - 4];
		precalc2 = precalc2 + Q[20 + 1 - 4];
		p1 = ((20 * (0x05555555ul) + SPH_ROTL32(message[4], ((20 - 16) % 16) + 1) + SPH_ROTL32(message[7], ((20 - 13) % 16) + 1) - (0x100 << 15)) ^ h1[(20 - 16 + 7) % 16]);
		p2 = (((20 + 1)*(0x05555555ul) + SPH_ROTL32(message[5], (((20 + 1) - 16) % 16) + 1) + (0x80 << 9)) ^ h1[((20 + 1) - 16 + 7) % 16]);
		Q[20] = precalc + expand32_2(20, message, h1, Q) + p1;
		Q[20 + 1] = precalc2 + expand32_2(20 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[20 - 16];
		precalc2 = precalc2 - Q[20 + 1 - 16];

		precalc = precalc + Q[22 - 4];
		precalc2 = precalc2 + Q[22 + 1 - 4];
		p1 = ((22 * (0x05555555ul) + SPH_ROTL32(message[6], ((22 - 16) % 16) + 1) - SPH_ROTL32(message[0], ((22 - 6) % 16) + 1)) ^ h1[(22 - 16 + 7) % 16]);
		p2 = (((22 + 1)*(0x05555555ul) + SPH_ROTL32(message[7], (((22 + 1) - 16) % 16) + 1) - SPH_ROTL32(message[1], (((22 + 1) - 6) % 16) + 1)) ^ h1[((22 + 1) - 16 + 7) % 16]);
		Q[22] = precalc + expand32_2(22, message, h1, Q) + p1;
		Q[22 + 1] = precalc2 + expand32_2(22 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[22 - 16];
		precalc2 = precalc2 - Q[22 + 1 - 16];

		precalc = precalc + Q[24 - 4];
		precalc2 = precalc2 + Q[24 + 1 - 4];
		p1 = ((24 * (0x05555555ul) + (0x80 << 9) - SPH_ROTL32(message[2], ((24 - 6) % 16) + 1)) ^ h1[(24 - 16 + 7) % 16]);
		p2 = (((24 + 1)*(0x05555555ul) - SPH_ROTL32(message[3], (((24 + 1) - 6) % 16) + 1)) ^ h1[((24 + 1) - 16 + 7) % 16]);
		Q[24] = precalc + expand32_2(24, message, h1, Q) + p1;
		Q[24 + 1] = precalc2 + expand32_2(24 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[24 - 16];
		precalc2 = precalc2 - Q[24 + 1 - 16];

		precalc = precalc + Q[26 - 4];
		precalc2 = precalc2 + Q[26 + 1 - 4];
		p1 = ((26 * (0x05555555ul) - SPH_ROTL32(message[4], ((26 - 6) % 16) + 1)) ^ h1[(26 - 16 + 7) % 16]);
		p2 = (((26 + 1)*(0x05555555ul) + (0x100 << 15) - SPH_ROTL32(message[5], (((26 + 1) - 6) % 16) + 1)) ^ h1[((26 + 1) - 16 + 7) % 16]);
		Q[26] = precalc + expand32_2(26, message, h1, Q) + p1;
		Q[26 + 1] = precalc2 + expand32_2(26 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[26 - 16];
		precalc2 = precalc2 - Q[26 + 1 - 16];

		precalc = precalc + Q[28 - 4];
		precalc2 = precalc2 + Q[28 + 1 - 4];
		p1 = ((28 * (0x05555555ul) - SPH_ROTL32(message[6], ((28 - 6) % 16) + 1)) ^ h1[(28 - 16 + 7) % 16]);
		p2 = (((28 + 1)*(0x05555555ul) + SPH_ROTL32(message[0], (((28 + 1) - 13) % 16) + 1) - SPH_ROTL32(message[7], (((28 + 1) - 6) % 16) + 1)) ^ h1[((28 + 1) - 16 + 7) % 16]);
		Q[28] = precalc + expand32_2(28, message, h1, Q) + p1;
		Q[28 + 1] = precalc2 + expand32_2(28 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[28 - 16];
		precalc2 = precalc2 - Q[28 + 1 - 16];

		precalc = precalc + Q[30 - 4];
		precalc2 = precalc2 + Q[30 + 1 - 4];
		p1 = ((30 * (0x05555555ul) + (0x100 << 15) + SPH_ROTL32(message[1], ((30 - 13) % 16) + 1) - (0x80 << 9)) ^ h1[(30 - 16 + 7) % 16]);
		p2 = (((30 + 1)*(0x05555555ul) + SPH_ROTL32(message[2], (((30 + 1) - 13) % 16) + 1)) ^ h1[((30 + 1) - 16 + 7) % 16]);
		Q[30] = precalc + expand32_2(30, message, h1, Q) + p1;
		Q[30 + 1] = precalc2 + expand32_2(30 + 1, message, h1, Q) + p2;
		precalc = precalc - Q[30 - 16];
		precalc2 = precalc2 - Q[30 + 1 - 16];

		XL32 = Q[16] ^ Q[17] ^ Q[18] ^ Q[19] ^ Q[20] ^ Q[21] ^ Q[22] ^ Q[23];
		XH32 = XL32^Q[24] ^ Q[25] ^ Q[26] ^ Q[27] ^ Q[28] ^ Q[29] ^ Q[30] ^ Q[31];

		message[0] = (shl(XH32, 5) ^ shr(Q[16], 5) ^ message[0]) + (XL32    ^ Q[24] ^ Q[0]);
		message[1] = (shr(XH32, 7) ^ shl(Q[17], 8) ^ message[1]) + (XL32    ^ Q[25] ^ Q[1]);
		message[2] = (shr(XH32, 5) ^ shl(Q[18], 5) ^ message[2]) + (XL32    ^ Q[26] ^ Q[2]);
		message[3] = (shr(XH32, 1) ^ shl(Q[19], 5) ^ message[3]) + (XL32    ^ Q[27] ^ Q[3]);
		message[4] = (shr(XH32, 3) ^ Q[20] ^ message[4]) + (XL32    ^ Q[28] ^ Q[4]);
		message[5] = (shl(XH32, 6) ^ shr(Q[21], 6) ^ message[5]) + (XL32    ^ Q[29] ^ Q[5]);
		message[6] = (shr(XH32, 4) ^ shl(Q[22], 6) ^ message[6]) + (XL32    ^ Q[30] ^ Q[6]);
		message[7] = (shr(XH32, 11) ^ shl(Q[23], 2) ^ message[7]) + (XL32    ^ Q[31] ^ Q[7]);

		message[8] = SPH_ROTL32(message[4], 9) + (XH32     ^     Q[24] ^ message[8]) + (shl(XL32, 8) ^ Q[23] ^ Q[8]);
		message[9] = SPH_ROTL32(message[5], 10) + (XH32     ^     Q[25] ^ message[9]) + (shr(XL32, 6) ^ Q[16] ^ Q[9]);
		message[10] = SPH_ROTL32(message[6], 11) + (XH32     ^     Q[26] ^ message[10]) + (shl(XL32, 6) ^ Q[17] ^ Q[10]);
		message[11] = SPH_ROTL32(message[7], 12) + (XH32     ^     Q[27] ^ message[11]) + (shl(XL32, 4) ^ Q[18] ^ Q[11]);
		message[12] = SPH_ROTL32(message[0], 13) + (XH32     ^     Q[28] ^ message[12]) + (shr(XL32, 3) ^ Q[19] ^ Q[12]);
		message[13] = SPH_ROTL32(message[1], 14) + (XH32     ^     Q[29] ^ message[13]) + (shr(XL32, 4) ^ Q[20] ^ Q[13]);
		message[14] = SPH_ROTL32(message[2], 15) + (XH32     ^     Q[30] ^ message[14]) + (shr(XL32, 7) ^ Q[21] ^ Q[14]);
		message[15] = SPH_ROTL32(message[3], 16) + (XH32     ^     Q[31] ^ message[15]) + (shr(XL32, 2) ^ Q[22] ^ Q[15]);

		const uint32_t h2[16] = {
			(0xaaaaaaa0), (0xaaaaaaa1), (0xaaaaaaa2),
			(0xaaaaaaa3), (0xaaaaaaa4), (0xaaaaaaa5),
			(0xaaaaaaa6), (0xaaaaaaa7), (0xaaaaaaa8),
			(0xaaaaaaa9), (0xaaaaaaaa), (0xaaaaaaab),
			(0xaaaaaaac), (0xaaaaaaad), (0xaaaaaaae),
			(0xaaaaaaaf)
		};

		Q[0] = (message[5] ^ h2[5]) - (message[7] ^ h2[7]) + (message[10] ^ h2[10]) + (message[13] ^ h2[13]) + (message[14] ^ h2[14]);
		Q[1] = (message[6] ^ h2[6]) - (message[8] ^ h2[8]) + (message[11] ^ h2[11]) + (message[14] ^ h2[14]) - (message[15] ^ h2[15]);
		Q[2] = (message[0] ^ h2[0]) + (message[7] ^ h2[7]) + (message[9] ^ h2[9]) - (message[12] ^ h2[12]) + (message[15] ^ h2[15]);
		Q[3] = (message[0] ^ h2[0]) - (message[1] ^ h2[1]) + (message[8] ^ h2[8]) - (message[10] ^ h2[10]) + (message[13] ^ h2[13]);
		Q[4] = (message[1] ^ h2[1]) + (message[2] ^ h2[2]) + (message[9] ^ h2[9]) - (message[11] ^ h2[11]) - (message[14] ^ h2[14]);
		Q[5] = (message[3] ^ h2[3]) - (message[2] ^ h2[2]) + (message[10] ^ h2[10]) - (message[12] ^ h2[12]) + (message[15] ^ h2[15]);
		Q[6] = (message[4] ^ h2[4]) - (message[0] ^ h2[0]) - (message[3] ^ h2[3]) - (message[11] ^ h2[11]) + (message[13] ^ h2[13]);
		Q[7] = (message[1] ^ h2[1]) - (message[4] ^ h2[4]) - (message[5] ^ h2[5]) - (message[12] ^ h2[12]) - (message[14] ^ h2[14]);
		Q[8] = (message[2] ^ h2[2]) - (message[5] ^ h2[5]) - (message[6] ^ h2[6]) + (message[13] ^ h2[13]) - (message[15] ^ h2[15]);
		Q[9] = (message[0] ^ h2[0]) - (message[3] ^ h2[3]) + (message[6] ^ h2[6]) - (message[7] ^ h2[7]) + (message[14] ^ h2[14]);
		Q[10] = (message[8] ^ h2[8]) - (message[1] ^ h2[1]) - (message[4] ^ h2[4]) - (message[7] ^ h2[7]) + (message[15] ^ h2[15]);
		Q[11] = (message[8] ^ h2[8]) - (message[0] ^ h2[0]) - (message[2] ^ h2[2]) - (message[5] ^ h2[5]) + (message[9] ^ h2[9]);
		Q[12] = (message[1] ^ h2[1]) + (message[3] ^ h2[3]) - (message[6] ^ h2[6]) - (message[9] ^ h2[9]) + (message[10] ^ h2[10]);
		Q[13] = (message[2] ^ h2[2]) + (message[4] ^ h2[4]) + (message[7] ^ h2[7]) + (message[10] ^ h2[10]) + (message[11] ^ h2[11]);
		Q[14] = (message[3] ^ h2[3]) - (message[5] ^ h2[5]) + (message[8] ^ h2[8]) - (message[11] ^ h2[11]) - (message[12] ^ h2[12]);
		Q[15] = (message[12] ^ h2[12]) - (message[4] ^ h2[4]) - (message[6] ^ h2[6]) - (message[9] ^ h2[9]) + (message[13] ^ h2[13]);

		Q[0] = ss0(Q[0]) + h2[1];
		Q[1] = ss1(Q[1]) + h2[2];
		Q[2] = ss2(Q[2]) + h2[3];
		Q[3] = ss3(Q[3]) + h2[4];
		Q[4] = ss4(Q[4]) + h2[5];
		Q[5] = ss0(Q[5]) + h2[6];
		Q[6] = ss1(Q[6]) + h2[7];
		Q[7] = ss2(Q[7]) + h2[8];
		Q[8] = ss3(Q[8]) + h2[9];
		Q[9] = ss4(Q[9]) + h2[10];
		Q[10] = ss0(Q[10]) + h2[11];
		Q[11] = ss1(Q[11]) + h2[12];
		Q[12] = ss2(Q[12]) + h2[13];
		Q[13] = ss3(Q[13]) + h2[14];
		Q[14] = ss4(Q[14]) + h2[15];
		Q[15] = ss0(Q[15]) + h2[0];

#pragma unroll
		for(int i = 0; i<2; i++)
			Q[i + 16] = expand32_1(i + 16, message, h2, Q);

		precalc = Q[18 - 16] + Q[18 - 14] + Q[18 - 12] + Q[18 - 10] + Q[18 - 8] + Q[18 - 6];
		precalc2 = Q[19 - 16] + Q[19 - 14] + Q[19 - 12] + Q[19 - 10] + Q[19 - 8] + Q[19 - 6];

#pragma unroll
		for(int i = 2 + 16; i < 16 + 16; i += 2)
		{
			precalc = precalc + Q[i - 4];
			precalc2 = precalc2 + Q[i + 1 - 4];
			p1 = ((i*(0x05555555ul) + SPH_ROTL32(message[(i - 16) % 16], ((i - 16) % 16) + 1) + SPH_ROTL32(message[(i - 13) % 16], ((i - 13) % 16) + 1) - SPH_ROTL32(message[(i - 6) % 16], ((i - 6) % 16) + 1)) ^ h2[(i - 16 + 7) % 16]);
			p2 = (((i + 1)*(0x05555555ul) + SPH_ROTL32(message[((i + 1) - 16) % 16], (((i + 1) - 16) % 16) + 1) + SPH_ROTL32(message[((i + 1) - 13) % 16], (((i + 1) - 13) % 16) + 1) - SPH_ROTL32(message[((i + 1) - 6) % 16], (((i + 1) - 6) % 16) + 1)) ^ h2[((i + 1) - 16 + 7) % 16]);
			Q[i] = precalc + expand32_2(i, message, h2, Q) + p1;
			Q[i + 1] = precalc2 + expand32_2(i + 1, message, h2, Q) + p2;
			precalc = precalc - Q[i - 16];
			precalc2 = precalc2 - Q[i + 1 - 16];
		}

		XL32 = Q[16] ^ Q[17] ^ Q[18] ^ Q[19] ^ Q[20] ^ Q[21] ^ Q[22] ^ Q[23];
		XH32 = XL32^Q[24] ^ Q[25] ^ Q[26] ^ Q[27] ^ Q[28] ^ Q[29] ^ Q[30] ^ Q[31];

		message[3] = (shr(XH32, 1) ^ shl(Q[19], 5) ^ message[3]) + (XL32    ^ Q[27] ^ Q[3]);
		message[15] = SPH_ROTL32(message[3], 16) + (XH32     ^     Q[31] ^ message[15]) + (shr(XL32, 2) ^ Q[22] ^ Q[15]);

		if(message[15] <= backup)
		{

			uint32_t tmp = atomicExch(nonceVector, startNounce + thread);
			if(tmp != 0)
				nonceVector[1] = tmp;
		}
	}
}


__host__
void bmw256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *resultnonces, uint32_t Target)
{
	CUDA_SAFE_CALL(cudaMemsetAsync(d_nonce[thr_id], 0x0, 2 * sizeof(uint32_t), gpustream[thr_id]));

	// berechne wie viele Thread Blocks wir brauchen
	dim3 grid((threads + TPB - 1) / TPB);
	dim3 block(TPB);

	bmw256_gpu_hash_32 << <grid, block >> >(threads, startNounce, (uint2 *)g_hash, d_nonce[thr_id], Target);
	CUDA_SAFE_CALL(cudaGetLastError());
	if(opt_debug)
		CUDA_SAFE_CALL(cudaDeviceSynchronize());
	CUDA_SAFE_CALL(cudaMemcpy(h_nonce[thr_id], d_nonce[thr_id], 2 * sizeof(uint32_t), cudaMemcpyDeviceToHost));
	resultnonces[0] = *(h_nonce[thr_id]);
	resultnonces[1] = *(h_nonce[thr_id] + 1);
}


__host__
void bmw256_cpu_init(int thr_id)
{
	CUDA_SAFE_CALL(cudaMalloc(&d_nonce[thr_id], 2 * sizeof(uint32_t)));
	CUDA_SAFE_CALL(cudaMallocHost(&h_nonce[thr_id], 2 * sizeof(uint32_t)));
}

/*
__host__
void bmw256_setTarget(int thr_id, const void *pTargetIn)
{
cudaMemcpyToSymbolAsync(pTarget, pTargetIn, 8 * sizeof(uint32_t), 0, cudaMemcpyHostToDevice, gpustream[thr_id]);
}
*/