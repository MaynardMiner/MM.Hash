# allow to use Host cuda functions in C/C++
DEF_INCLUDES = @CUDA_INCLUDES@

if WANT_JANSSON
JANSSON_INCLUDES = -I$(top_srcdir)/compat/jansson
else
JANSSON_INCLUDES =
endif

EXTRA_DIST = autogen.sh README.txt LICENSE.txt \
			  cudaminer.sln cudaminer.vcxproj cudaminer.vcxproj.filters \
			  compat/gettimeofday.c compat/getopt/getopt_long.c cpuminer-config.h.in

SUBDIRS = compat

bin_PROGRAMS = ccminer

ccminer_SOURCES = elist.h miner.h compat.h \
			  compat/inttypes.h compat/stdbool.h compat/unistd.h \
			  compat/sys/time.h compat/getopt/getopt.h \
			  crc32.c \
			  ccminer.cpp util.cpp \
			  api.cpp hashlog.cpp stats.cpp sysinfos.cpp cuda.cpp \
			  nvml.cpp nvml.h nvsettings.cpp \
			  cuda_helper.h cuda_vector.h \
			  sph/neoscrypt.h sph/neoscrypt.cpp \
			  sph/sha256_Y.h sph/sha256_Y.c sph/sph_sha2.c \
			  fuguecoin.cpp Algo256/cuda_fugue256.cu sph/fugue.c \
			  groestlcoin.cpp cuda_groestlcoin.cu cuda_groestlcoin.h \
			  myriadgroestl.cpp cuda_myriadgroestl.cu \
			  lyra2/Lyra2.c lyra2/Sponge.c \
			  lyra2/lyra2REv2.cu lyra2/cuda_lyra2v2.cu \
			  Algo256/cuda_blake256.cu Algo256/cuda_groestl256.cu Algo256/cuda_keccak256.cu Algo256/cuda_skein256.cu \
			  Algo256/cuda_bmw256.cu Algo256/cuda_cubehash256.cu \
			  Algo256/blake256.cu Algo256/keccak256.cu \
			  JHA/jackpotcoin.cu JHA/cuda_jha_keccak512.cu \
			  JHA/cuda_jha_compactionTest.cu cuda_checkhash.cu \
			  quark/cuda_jh512.cu quark/cuda_quark_blake512.cu quark/cuda_quark_groestl512.cu quark/cuda_skein512.cu \
			  quark/cuda_bmw512.cu quark/cuda_quark_keccak512.cu quark/cuda_jh512keccak512.cu \
			  quark/quarkcoin.cu \
			  quark/cuda_quark_compactionTest.cu  \
			  cuda_nist5.cu pentablake.cu skein.cu \
			  Sia/sia.cu Sia/cuda_sia.cu \
			  sph/bmw.c sph/blake.c sph/groestl.c sph/jh.c sph/keccak.c sph/skein.c \
			  BlueMidnightWish_opt.c SHA3api_ref.h \
			  sph/cubehash.c sph/echo.c sph/luffa.c sph/sha2.c sph/shavite.c sph/simd.c \
			  sph/hamsi.c sph/hamsi_helper.c sph/sph_hamsi.h \
			  sph/shabal.c sph/whirlpool.c sph/sha2big.c sph/haval.c \
			  qubit/qubit.cu qubit/qubit_luffa512.cu qubit/deep.cu qubit/doom.cu \
			  x11/x11.cu x11/fresh.cu x11/cuda_x11_luffa512.cu x11/cuda_x11_cubehash512.cu \
			  x11/cuda_x11_shavite512.cu x11/cuda_x11_simd512.cu x11/cuda_x11_echo.cu \
			  x11/cuda_x11_luffa512_Cubehash.cu \
			  x13/x13.cu x13/cuda_x13_hamsi512.cu x13/cuda_x13_fugue512.cu \
			  x15/x14.cu x15/x15.cu x15/cuda_x14_shabal512.cu x15/cuda_x15_whirlpool.cu \
			  x15/whirlpool.cu \
			  x17/x17.cu x17/cuda_x17_haval512.cu x17/cuda_x17_sha512.cu \
			  x11/s3.cu x11/c11.cu \
			  bitcoin.cu cuda_bitcoin.cu \
			  x15/cuda_whirlpoolx.cu x15/whirlpoolx.cu \
			  neoscrypt/neoscrypt.cu neoscrypt/cuda_neoscrypt.cu \
			  neoscrypt/cuda_neoscrypt_tpruvot.cu \
			  neoscrypt/cuda_vector_tpruvot.cuh neoscrypt/cuda_vector_uint2x4.cuh

# scrypt
# ccminer_SOURCES += scrypt.cpp scrypt-jane.cpp \
#     scrypt/blake.cu scrypt/keccak.cu scrypt/sha256.cu \
#     scrypt/salsa_kernel.cu scrypt/test_kernel.cu \
#     scrypt/fermi_kernel.cu scrypt/kepler_kernel.cu \
#     scrypt/nv_kernel.cu scrypt/nv_kernel2.cu scrypt/titan_kernel.cu

			  
if HAVE_NVML
nvml_defs = -DUSE_WRAPNVML
nvml_libs = -ldl
endif

ccminer_LDFLAGS  = $(PTHREAD_FLAGS) @CUDA_LDFLAGS@
ccminer_LDADD    = @LIBCURL@ @JANSSON_LIBS@ @PTHREAD_LIBS@ @WS2_LIBS@ @CUDA_LIBS@ @OPENMP_CFLAGS@ @LIBS@ $(nvml_libs)
ccminer_CPPFLAGS = @LIBCURL_CPPFLAGS@ @OPENMP_CFLAGS@ $(CPPFLAGS) $(PTHREAD_FLAGS) -fno-strict-aliasing $(JANSSON_INCLUDES) $(DEF_INCLUDES) $(nvml_defs) -DSCRYPT_KECCAK512 -DSCRYPT_CHACHA -DSCRYPT_CHOOSE_COMPILETIME

if HAVE_OSX
ccminer_CPPFLAGS += -I/usr/local/llvm/lib/clang/4.0.0/include
ccminer_LDFLAGS += -L/usr/local/llvm/lib
ccminer_LDADD += -lomp
endif

nvcc_ARCH  = -gencode=arch=compute_61,code=sm_61
nvcc_ARCH += -gencode=arch=compute_60,code=sm_60
nvcc_ARCH += -gencode=arch=compute_52,code=sm_52
nvcc_ARCH += -gencode=arch=compute_50,code=sm_50
nvcc_ARCH += -gencode=arch=compute_37,code=sm_37
nvcc_ARCH += -gencode=arch=compute_35,code=sm_35
nvcc_ARCH += -gencode=arch=compute_30,code=sm_30
nvcc_ARCH += -gencode=arch=compute_70,code=sm_70

nvcc_FLAGS = $(nvcc_ARCH) @CUDA_INCLUDES@ -I. @CUDA_CFLAGS@
nvcc_FLAGS += $(JANSSON_INCLUDES)

# we're now targeting all major compute architectures within one binary.
.cu.o:
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=128 -o $@ -c $<

Algo256/blake256.o: Algo256/blake256.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=64 -o $@ -c $<

heavy/cuda_hefty1.o: heavy/cuda_hefty1.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=80 -o $@ -c $<

qubit/qubit_luffa512.o: qubit/qubit_luffa512.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=80 -o $@ -c $<

# Luffa and Echo are faster with 80 registers than 128
x11/cuda_x11_luffa512.o: x11/cuda_x11_luffa512.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=80 -o $@ -c $<

x11/cuda_x11_luffa512_Cubehash.o: x11/cuda_x11_luffa512_Cubehash.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=80 -o $@ -c $<

x13/cuda_x13_hamsi512.o: x13/cuda_x13_hamsi512.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=72 -o $@ -c $<

x17/cuda_x17_sha512.o: x17/cuda_x17_sha512.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=80 -o $@ -c $<

quark/cuda_quark_blake512.o: quark/cuda_quark_blake512.cu
	$(NVCC) $(nvcc_FLAGS) -I cudpp-2.1/include --maxrregcount=80 -o $@ -c $<

quark/cuda_quark_keccak512.o: quark/cuda_quark_keccak512.cu
	$(NVCC) $(nvcc_FLAGS) -I cudpp-2.1/include --maxrregcount=88 -o $@ -c $<

quark/cuda_quark_compactionTest.o: quark/cuda_quark_compactionTest.cu
	$(NVCC) $(nvcc_FLAGS) -I cudpp-2.1/include --maxrregcount=80 -o $@ -c $<

JHA/cuda_jha_compactionTest.o: JHA/cuda_jha_compactionTest.cu
	$(NVCC) $(nvcc_FLAGS) -I cudpp-2.1/include --maxrregcount=80 -o $@ -c $<

skein.o: skein.cu
	$(NVCC) $(nvcc_FLAGS) --maxrregcount=64 -o $@ -c $<

neoscrypt/cuda_neoscrypt.o: neoscrypt/cuda_neoscrypt.cu
	$(NVCC) -gencode=arch=compute_61,code=sm_61 -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_52,code=sm_52 -gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_35,code=sm_35 -gencode=arch=compute_37,code=sm_37 -gencode=arch=compute_70,code=sm_70 @CUDA_INCLUDES@ -I. @CUDA_CFLAGS@ -o $@ -c $<

neoscrypt/cuda_neoscrypt_tpruvot.o: neoscrypt/cuda_neoscrypt_tpruvot.cu
	$(NVCC) -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_61,code=sm_61 -gencode=arch=compute_70,code=sm_70 @CUDA_INCLUDES@ -I. $(JANSSON_INCLUDES) @CUDA_CFLAGS@ -o $@ -c $<
