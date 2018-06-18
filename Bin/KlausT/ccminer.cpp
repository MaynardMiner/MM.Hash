/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2014 pooler
 * Copyright 2014-2015 tpruvot
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

#ifndef WIN32
#include "ccminer-config.h"
#else
#include "ccminer-config-win.h"
#endif
#include "cuda_runtime_api.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cinttypes>
#include <unistd.h>
#include <cmath>
#include <sys/time.h>
#include <ctime>
#include <csignal>

#include <curl/curl.h>
#include <jansson.h>
#include <openssl/sha.h>

#ifdef WIN32
#include <windows.h>
#include <cstdint>
#else
#include <errno.h>
#include <sys/resource.h>
#if HAVE_SYS_SYSCTL_H
#include <sys/types.h>
#if HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif
#include <sys/sysctl.h>
#endif
#endif
using namespace std;

#include "miner.h"

#ifdef WIN32
#include <Mmsystem.h>
#pragma comment(lib, "winmm.lib")
#include "compat/winansi.h"
BOOL WINAPI ConsoleHandler(DWORD);
#endif

#define PROGRAM_NAME		"ccminer"
#define LP_SCANTIME		25
#define MNR_BLKHDR_SZ 80

double expectedblocktime(const uint32_t *target);

extern void get_cuda_arch(int *version);
extern int cuda_arch[MAX_GPUS];

// from cuda.cpp
int cuda_num_devices();
void cuda_devicenames();
void cuda_devicereset();
int cuda_finddevice(char *name);
void cuda_print_devices();
void cuda_get_device_sm();
void cuda_reset_device(int thr_id, bool *init);

#include "nvml.h"
#ifdef USE_WRAPNVML
nvml_handle *hnvml = NULL;
#endif

enum workio_commands {
	WC_GET_WORK,
	WC_SUBMIT_WORK,
};

struct workio_cmd {
	enum workio_commands	cmd;
	struct thr_info		*thr;
	union {
		struct work	*work;
	} u;
};

bool opt_debug_diff = false;
bool opt_debug_threads = false;
bool opt_showdiff = true;
bool opt_hwmonitor = true;

const char *algo_names[] =
{
	"invalid",
	"bitcoin",
	"blake",
	"blakecoin",
	"c11",
	"deep",
	"dmd-gr",
	"doom", /* is luffa */
	"fresh",
	"fugue256",
	"groestl",
	"keccak",
	"jackpot",
	"luffa",
	"lyra2v2",
	"myr-gr",
	"nist5",
	"penta",
	"quark",
	"qubit",
	"sia",
	"skein",
	"s3",
	"whirl",
	"whirlpoolx",
	"x11",
	"x13",
	"x14",
	"x15",
	"x17",
	"vanilla",
	"neoscrypt"
};

char curl_err_str[CURL_ERROR_SIZE];
bool opt_verify = true;
bool opt_debug = false;
bool opt_protocol = false;
bool opt_benchmark = false;
bool want_longpoll = true;
bool have_longpoll = false;
bool want_stratum = true;
bool have_stratum = false;
bool allow_gbt = true;
bool allow_mininginfo = true;
bool check_dups = false;
static bool submit_old = false;
bool use_syslog = false;
bool use_colors = true;
static bool opt_background = false;
bool opt_quiet = false;
static int opt_retries = -1;
static int opt_fail_pause = 20;
int opt_timeout = 120;
static int opt_scantime = 25;
static json_t *opt_config = nullptr;
static const bool opt_time = true;
enum sha_algos opt_algo = ALGO_INVALID;
int opt_n_threads = 0;
int gpu_threads = 1;
int opt_affinity = -1;
int opt_priority = 0;
static double opt_difficulty = 1; // CH
static bool opt_extranonce = true;
bool opt_trust_pool = false;
int num_cpus;
int active_gpus;
bool need_nvsettings = false;
bool need_memclockrst = false;
char * device_name[MAX_GPUS] = { nullptr };
int device_map[MAX_GPUS] = { 0 };
long  device_sm[MAX_GPUS] = { 0 };
uint32_t gpus_intensity[MAX_GPUS] = {0};
int32_t device_mem_offsets[MAX_GPUS] = {0};
uint32_t device_gpu_clocks[MAX_GPUS] = {0};
uint32_t device_mem_clocks[MAX_GPUS] = {0};
uint32_t device_plimit[MAX_GPUS] = {0};
int8_t device_pstate[MAX_GPUS];
int32_t device_led[MAX_GPUS] = {-1, -1};
int opt_led_mode = 0;
int opt_cudaschedule = -1;
uint8_t device_tlimit[MAX_GPUS] = {0};
char *rpc_user = NULL;
static char *rpc_url = nullptr;
static char *rpc_userpass = nullptr;
static char *rpc_pass = nullptr;
static char *short_url = NULL;
char *opt_cert = nullptr;
char *opt_proxy = nullptr;
long opt_proxy_type;
struct thr_info *thr_info = nullptr;
static int work_thr_id;
struct thr_api *thr_api = nullptr;
int longpoll_thr_id = -1;
int stratum_thr_id = -1;
int api_thr_id = -1;
bool stratum_need_reset = false;
volatile bool abort_flag = false;
struct work_restart *work_restart = NULL;
bool send_stale;
struct stratum_ctx stratum = { 0 };
bool stop_mining = false;
volatile bool mining_has_stopped[MAX_GPUS];
unsigned int cudaschedule = cudaDeviceScheduleBlockingSync;
FILE *logfilepointer;
char *logfilename;
bool opt_logfile = false;

pthread_mutex_t applog_lock = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t stats_lock = PTHREAD_MUTEX_INITIALIZER;
uint32_t accepted_count = 0L;
uint32_t rejected_count = 0L;
double thr_hashrates[MAX_GPUS];
uint64_t global_hashrate = 0;
double   global_diff = 0.0;
uint64_t net_hashrate = 0;
uint64_t net_blocks = 0;

int opt_statsavg = 30;
uint16_t opt_api_listen = 0; /* 0 to disable */
bool opt_stratum_stats = true;
static char* opt_syslog_pfx = nullptr;
char *opt_api_allow = nullptr;

#ifdef HAVE_GETOPT_LONG
#include <getopt.h>
#else
struct option {
	const char *name;
	int has_arg;
	int *flag;
	int val;
};
#endif

static char const usage[] = "\
Usage: " PROGRAM_NAME " [OPTIONS]\n\
Options:\n\
  -a, --algo=ALGO specify the hash algorithm to use\n\
			bitcoin     Bitcoin\n\
			blake       Blake 256 (SFR/NEOS)\n\
			blakecoin   Fast Blake 256 (8 rounds)\n\
			c11         X11 variant\n\
			deep        Deepcoin\n\
			dmd-gr      Diamond-Groestl\n\
			fresh       Freshcoin (shavite 80)\n\
			fugue256    Fuguecoin\n\
			groestl     Groestlcoin\n\
			jackpot     Jackpot (JHA)\n\
			keccak      Keccak-256 (Maxcoin)\n\
			luffa       Doomcoin\n\
			lyra2v2     VertCoin\n\
			myr-gr      Myriad-Groestl\n\
			neoscrypt   neoscrypt (FeatherCoin)\n\
			nist5       NIST5 (TalkCoin)\n\
			penta       Pentablake hash (5x Blake 512)\n\
			quark       Quark\n\
			qubit       Qubit\n\
			sia         Siacoin (at pools compatible to siamining.com) \n\
			skein       Skein SHA2 (Skeincoin)\n\
			s3          S3 (1Coin)\n\
			x11         X11 (DarkCoin)\n\
			x13         X13 (MaruCoin)\n\
			x14         X14\n\
			x15         X15\n\
			x17         X17 (peoplecurrency)\n\
			vanilla     Blake 256 8 rounds\n\
			whirl       Whirlcoin (old whirlpool)\n\
			whirlpoolx  Vanillacoin \n\
  -d, --devices         Comma separated list of CUDA devices to use. \n\
                        Device IDs start counting from 0! Alternatively takes\n\
                        string names of your cards like gtx780ti or gt640#2\n\
                        (matching 2nd gt640 in the PC)\n\
  -i  --intensity=N     GPU intensity 8-31 (default: auto) \n\
                        Decimals are allowed for fine tuning \n\
  -f, --diff-factor     Divide difficulty by this factor (default 1.0) \n\
  -m, --diff-multiplier Multiply difficulty by this value (default 1.0) \n\
  -o, --url=URL         URL of mining server\n\
  -O, --userpass=U:P    username:password pair for mining server\n\
  -u, --user=USERNAME   username for mining server\n\
  -p, --pass=PASSWORD   password for mining server\n\
      --cert=FILE       certificate for mining server using SSL\n\
  -x, --proxy=...       [PROTOCOL://]HOST[:PORT]  connect through a proxy\n\
  -t, --threads=N       number of miner threads (default: number of nVidia GPUs)\n\
  -r, --retries=N       number of times to retry if a network call fails\n\
                          (default: retry indefinitely)\n\
  -R, --retry-pause=N   time to pause between retries, in seconds (default: 30)\n\
  -T, --timeout=N       network timeout, in seconds (default: 270)\n\
  -s, --scantime=N      upper bound on time spent scanning current work when\n\
                          long polling is unavailable, in seconds (default: 5)\n\
  -n, --ndevs           list cuda devices\n\
  -N, --statsavg        number of samples used to display hashrate (default: 30)\n\
      --no-gbt          disable getblocktemplate support (height check in solo)\n\
      --no-longpoll     disable X-Long-Polling support\n\
      --no-stratum      disable X-Stratum support\n\
  -e                    disable extranonce\n\
  -q, --quiet           disable per-thread hashmeter output\n\
      --no-color        disable colored output\n\
  -D, --debug           enable debug output\n\
  -P, --protocol-dump   verbose dump of protocol-level activities\n\
      --cpu-affinity    set process affinity to cpu core(s), mask 0x3 for cores 0 and 1\n\
      --cpu-priority    set process priority (default: 0 idle, 2 normal to 5 highest)\n\
      --cuda-schedule   set CUDA scheduling option:\n\
                        0: BlockingSync (default)\n\
                        1: Spin\n\
                        2: Yield\n\
  -b, --api-bind=...    IP address and port number for the miner API (example: 127.0.0.1:4068)\n\
      --logfile=FILE    create logfile\n\
  -S, --syslog          use system log for output messages\n\
      --syslog-prefix=... allow to change syslog tool name\n\
  -B, --background      run the miner in the background\n\
      --benchmark       run in offline benchmark mode\n\
      --no-cpu-verify   don't verify the found results\n\
  -c, --config=FILE     load a JSON-format configuration file\n\
  -V, --version         display version information and exit\n\
  -h, --help            display this help text and exit\n"
#if defined(USE_WRAPNVML) && (defined(__linux) || defined(_WIN64)) /* via nvml */
"\
      --mem-clock=N     Set the gpu memory max clock (346.72+ driver)\n\
      --gpu-clock=N     Set the gpu engine max clock (346.72+ driver)\n\
      --pstate=N        (not for 10xx cards) Set the gpu power state (352.21+ driver)\n\
      --plimit=N        Set the gpu power limit (352.21+ driver)\n"
#endif
"";

static char const short_options[] =
#ifdef HAVE_SYSLOG_H
"S"
#endif
"a:c:i:Dhp:Px:nqr:R:s:t:T:o:u:O:Vd:f:m:N:b:eB";

static struct option const options[] =
{
	{"algo", 1, NULL, 'a'},
	{"api-bind", 1, NULL, 'b'},
	{"background", 0, NULL, 'B'},
	{"benchmark", 0, NULL, 1005},
	{"cert", 1, NULL, 1001},
	{"no-cpu-verify", 0, NULL, 1022},
	{"config", 1, NULL, 'c'},
	{"cputest", 0, NULL, 1006},
	{"cpu-affinity", 1, NULL, 1020},
	{"cpu-priority", 1, NULL, 1021},
	{"cuda-schedule", 1, NULL, 1025},
	{"debug", 0, NULL, 'D'},
	{"help", 0, NULL, 'h'},
	{"intensity", 1, NULL, 'i'},
	{"ndevs", 0, NULL, 'n'},
	{"no-color", 0, NULL, 1002},
	{"no-gbt", 0, NULL, 1011},
	{"no-longpoll", 0, NULL, 1003},
	{"no-stratum", 0, NULL, 1007},
	{"pass", 1, NULL, 'p'},
	{"protocol-dump", 0, NULL, 'P'},
	{"proxy", 1, NULL, 'x'},
	{"quiet", 0, NULL, 'q'},
	{"retries", 1, NULL, 'r'},
	{"retry-pause", 1, NULL, 'R'},
	{"scantime", 1, NULL, 's'},
	{"statsavg", 1, NULL, 'N'},
#ifdef HAVE_SYSLOG_H
	{"syslog", 0, NULL, 'S'},
	{"syslog-prefix", 1, NULL, 1008},
#endif
	{"threads", 1, NULL, 't'},
	{"Disable extranounce support", 1, NULL, 'e'},
	{"timeout", 1, NULL, 'T'},
	{"url", 1, NULL, 'o'},
	{"user", 1, NULL, 'u'},
	{"userpass", 1, NULL, 'O'},
	{"version", 0, NULL, 'V'},
	{"devices", 1, NULL, 'd'},
	{"diff-multiplier", 1, NULL, 'm'},
	{"diff-factor", 1, NULL, 'f'},
	{"diff", 1, NULL, 'f'}, // compat
	{"gpu-clock", 1, NULL, 1070},
	{"mem-clock", 1, NULL, 1071},
	{"pstate", 1, NULL, 1072},
	{"plimit", 1, NULL, 1073},
	{"logfile", 1, NULL, 1074},
	{0, 0, 0, 0}
};

struct work _ALIGN(64) g_work;
time_t g_work_time;
static pthread_mutex_t g_work_lock = PTHREAD_MUTEX_INITIALIZER;


#ifdef __linux /* Linux specific policy and affinity management */
#include <sched.h>
static inline void drop_policy(void)
{
	struct sched_param param;
	param.sched_priority = 0;
#ifdef SCHED_IDLE
	if(unlikely(sched_setscheduler(0, SCHED_IDLE, &param) == -1))
#endif
#ifdef SCHED_BATCH
		sched_setscheduler(0, SCHED_BATCH, &param);
#endif
}
static void affine_to_cpu_mask(int id, uint8_t mask)
{
	cpu_set_t set;
	CPU_ZERO(&set);
	for(uint8_t i = 0; i < num_cpus; i++)
	{
		// cpu mask
		if(mask & (1 << i))
		{
			CPU_SET(i, &set); printf("%d \n", i);
		}
	}
	if(id == -1)
	{
		// process affinity
		sched_setaffinity(0, sizeof(&set), &set);
	}
	else
	{
		// thread only
		pthread_setaffinity_np(thr_info[id].pth, sizeof(&set), &set);
	}
}
#elif defined(__FreeBSD__) /* FreeBSD specific policy and affinity management */
#include <sys/cpuset.h>
static inline void drop_policy(void)
{}
static void affine_to_cpu_mask(int id, uint8_t mask)
{
	cpuset_t set;
	CPU_ZERO(&set);
	for(uint8_t i = 0; i < num_cpus; i++)
	{
		if(mask & (1 << i)) CPU_SET(i, &set);
	}
	cpuset_setaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, sizeof(cpuset_t), &set);
}
#else
#ifdef WIN32
static inline void drop_policy(void)
{}
static void affine_to_cpu_mask(int id, uint8_t mask)
{
	if(id == -1)
		SetProcessAffinityMask(GetCurrentProcess(), mask);
	else
		SetThreadAffinityMask(GetCurrentThread(), mask);
}
#else // OSX is not linux
static inline void drop_policy(void)
{
}
static void affine_to_cpu_mask(int id, uint8_t mask)
{
}
#endif
#endif

static bool get_blocktemplate(CURL *curl, struct work *work);

void get_currentalgo(char* buf, int sz)
{
	snprintf(buf, sz, "%s", algo_names[opt_algo]);
}

/**
* Exit app
*/
static bool already_exiting = false; // make sure only one thread executes proper_exit()
void proper_exit(int reason)
{
	extern struct stratum_ctx stratum;
	if(already_exiting)
		sleep(10);
	else
	{
		already_exiting = true;
		if(opt_n_threads > 0)
		{
			time_t start = time(NULL);
			stop_mining = true;
			applog(LOG_INFO, "stopping %d threads", opt_n_threads);
			bool everything_stopped;
			do
			{
				everything_stopped = true;
				for(int i = 0; i < opt_n_threads; i++)
				{
					if(!mining_has_stopped[i])
						everything_stopped = false;
				}
			} while(!everything_stopped && (time(NULL) - start) < 5);
			applog(LOG_INFO, "resetting GPUs");
			cuda_devicereset();
		}
		pthread_mutex_lock(&stratum.sock_lock);
		curl_global_cleanup();
		pthread_mutex_unlock(&stratum.sock_lock);

#ifdef WIN32
		timeEndPeriod(1);
#endif
#ifdef USE_WRAPNVML
		if(hnvml)
		{
			for(int n = 0; n < opt_n_threads; n++)
			{
				nvml_reset_clocks(hnvml, device_map[n]);
			}
			nvml_destroy(hnvml);
		}
		if(need_memclockrst)
		{
#ifdef WIN32
			for(int n = 0; n < opt_n_threads; n++)
			{
				nvapi_toggle_clocks(n, false);
			}
#endif
		}
#endif
	}
	if(opt_logfile)
		fclose(logfilepointer);
	sleep(1);
	exit(reason);
}

static size_t jobj_binary(const json_t *obj, const char *key,
						void *buf, size_t buflen)
{
	const char *hexstr;
	json_t *tmp;

	tmp = json_object_get(obj, key);
	if(unlikely(tmp == NULL))
	{
		applog(LOG_ERR, "JSON key '%s' not found", key);
		return false;
	}
	hexstr = json_string_value(tmp);
	if(unlikely(hexstr == NULL))
	{
		applog(LOG_ERR, "JSON key '%s' is not a string", key);
		return false;
	}
	if(strlen(hexstr) / 2 <= buflen)
		hex2bin((uchar*)buf, hexstr, buflen);
	else
		return 0;
	return strlen(hexstr)/2;
}

static bool work_decode(const json_t *val, struct work *work)
{
	int target_size;
	int midstate_size = sizeof(work->midstate);
	int atarget_sz = ARRAY_SIZE(work->target);
	int i;

	size_t data_size = jobj_binary(val, "data", work->data, sizeof(work->data));

	if(opt_algo != ALGO_NEO && data_size != 128)
	{
		applog(LOG_ERR, "JSON invalid data");
		return false;
	}
	work->datasize = data_size;
	int adata_sz = (int)data_size / 4;

	target_size = (int)jobj_binary(val, "target", work->target, sizeof(work->target));
	if(target_size != sizeof(work->target))
	{
		applog(LOG_ERR, "JSON invalid target", target_size);
		return false;
	}

	for(i = 0; i < adata_sz; i++)
		work->data[i] = le32dec(work->data + i);
	for(i = 0; i < atarget_sz; i++)
		work->target[i] = le32dec(work->target + i);

	json_t *jr = json_object_get(val, "noncerange");
	if(jr)
	{
		const char * hexstr = json_string_value(jr);
		if(likely(hexstr))
		{
			// never seen yet...
			hex2bin((uchar*)work->noncerange.u64, hexstr, 8);
			applog(LOG_DEBUG, "received noncerange: %08x-%08x",
				   work->noncerange.u32[0], work->noncerange.u32[1]);
		}
	}

	/* use work ntime as job id (solo-mining) */
	cbin2hex(work->job_id, (const char*)&work->data[17], 4);

	return true;
}

/**
* Calculate the work difficulty as double
* Not sure it works with pools
*/
static void calc_diff(struct work *work, int known)
{
	// sample for diff 32.53 : 00000007de5f0000
	const uint64_t diffone = 0xFFFF000000000000ull;
	uint64_t *data64, d64;
	char rtarget[32];

	swab256(rtarget, work->target);
	data64 = (uint64_t *)(rtarget + 3); /* todo: index (3) can be tuned here */

	d64 = swab64(*data64);
	if(unlikely(!d64))
		d64 = 1;
	work->difficulty = (double)diffone / d64;
	if(opt_difficulty > 0.)
	{
		work->difficulty /= opt_difficulty;
	}
}

static int share_result(int result, const char *reason)
{
	char s[32] = { 0 };
	double hashrate = 0.;

	pthread_mutex_lock(&stats_lock);

	for(int i = 0; i < opt_n_threads; i++)
	{
		hashrate += stats_get_speed(i, thr_hashrates[i]);
	}
	result ? accepted_count++ : rejected_count++;
	pthread_mutex_unlock(&stats_lock);

	global_hashrate = llround(hashrate);

	format_hashrate(hashrate, s);
	applog(LOG_NOTICE, "accepted: %lu/%lu (%.2f%%), %s %s",
		   accepted_count,
		   accepted_count + rejected_count,
		   100. * accepted_count / (accepted_count + rejected_count),
		   s,
		   use_colors ?
		   (result ? CL_GRN "yay!!!" : CL_RED "booooo")
		   : (result ? "(yay!!!)" : "(booooo)"));

	if(reason)
	{
		applog(LOG_WARNING, "reject reason: %s", reason);
		if(strncmp(reason, "Duplicate share", 15) == 0 && !check_dups)
		{
			applog(LOG_WARNING, "enabling duplicates check feature");
			check_dups = true;
		}
		return 0;

	}
	return 1;
}

static bool submit_upstream_work(CURL *curl, struct work *work)
{
	json_t *val, *res, *reason;
	bool stale_work = false;
	char s[384];

	/* discard if a newer block was received */
	stale_work = !send_stale && (work->height && work->height < g_work.height);
	if(have_stratum && !stale_work)
	{
		pthread_mutex_lock(&g_work_lock);
		if(strlen(work->job_id + 8))
		{
			if(!send_stale && strncmp(work->job_id + 8, g_work.job_id + 8, sizeof(g_work.job_id) - 8) != 0)
				stale_work = true;
			else
				stale_work = false;
		}
		if(!send_stale && stale_work)
		{
			if(opt_debug) applog(LOG_DEBUG, "outdated job %s, new %s",
								 work->job_id + 8, g_work.job_id + 8);
		}
		pthread_mutex_unlock(&g_work_lock);
	}

	if(!have_stratum && !stale_work && allow_gbt)
	{
		struct work wheight = { 0 };
		if(get_blocktemplate(curl, &wheight))
		{
			if(work->height && work->height < wheight.height)
			{
				if(opt_debug)
					applog(LOG_WARNING, "block %u was already solved", work->height, wheight.height);
				return true;
			}
		}
	}

	if(!send_stale && stale_work)
	{
//		if(opt_debug)
			applog(LOG_WARNING, "stale share detected, discarding");
		rejected_count++;
		return true;
	}
	calc_diff(work, 0);

	if(have_stratum)
	{
		uint32_t sent = 0;
		uint32_t ntime, nonce;
		char *ntimestr, *noncestr, *xnonce2str;

		if(opt_algo != ALGO_SIA)
		{
			le32enc(&ntime, work->data[17]);
			le32enc(&nonce, work->data[19]);
			noncestr = bin2hex((const uchar*)(&nonce), 4);
			ntimestr = bin2hex((const uchar*)(&ntime), 4);
		}
		else
		{
			le32enc(&ntime, work->data[10]);
			uint64_t ntime64 = ntime;
			le32enc(&nonce, work->data[8]);
			uint64_t nonce64 = nonce;
			le32enc(&nonce, work->data[9]);
			nonce64 += (uint64_t)nonce << 32;
			noncestr = bin2hex((const uchar*)(&nonce64), 8);
			ntimestr = bin2hex((const uchar*)(&ntime64), 8);
		}


		if(check_dups)
			sent = hashlog_already_submittted(work->job_id, nonce);
		if(sent > 0)
		{
			sent = (uint32_t)time(NULL) - sent;
			if(!opt_quiet)
			{
				applog(LOG_WARNING, "nonce %s was already sent %u seconds ago", noncestr, sent);
				hashlog_dump_job(work->job_id);
			}
			free(noncestr);
			// prevent useless computing on some pools
			g_work_time = 0;
			restart_threads();
			return true;
		}

		xnonce2str = bin2hex(work->xnonce2, work->xnonce2_len);

		sprintf(s,
				"{\"method\": \"mining.submit\", \"params\": [\"%s\", \"%s\", \"%s\", \"%s\", \"%s\"], \"id\":4}",
				rpc_user, work->job_id + 8, xnonce2str, ntimestr, noncestr);
		free(xnonce2str);
		free(ntimestr);
		free(noncestr);

		gettimeofday(&stratum.tv_submit, NULL);
		if(unlikely(!stratum_send_line(&stratum, s)))
		{
			applog(LOG_ERR, "submit_upstream_work stratum_send_line failed");
			return false;
		}

		if(check_dups)
			hashlog_remember_submit(work, nonce);

	}
	else
	{

		/* build hex string */
		char *str = NULL;
		for(int i = 0; i < (work->datasize >> 2); i++)
			le32enc(work->data + i, work->data[i]);
		str = bin2hex((uchar*)work->data, work->datasize);
		if(unlikely(!str))
		{
			applog(LOG_ERR, "submit_upstream_work OOM");
			return false;
		}

		/* build JSON-RPC request */
		sprintf(s,
				"{\"method\": \"getwork\", \"params\": [\"%s\"], \"id\":4}\r\n",
				str);

		/* issue JSON-RPC request */
		val = json_rpc_call(curl, rpc_url, rpc_userpass, s, false, false, NULL);
		if(unlikely(!val))
		{
			applog(LOG_ERR, "submit_upstream_work json_rpc_call failed");
			return false;
		}

		res = json_object_get(val, "result");
		reason = json_object_get(val, "reject-reason");
		if(!share_result(json_is_true(res), reason ? json_string_value(reason) : NULL))
		{
			if(check_dups)
				hashlog_purge_job(work->job_id);
		}

		json_decref(val);

		free(str);
	}

	return true;
}

/* simplified method to only get some extra infos in solo mode */
static bool gbt_work_decode(const json_t *val, struct work *work)
{
	json_t *err = json_object_get(val, "error");
	if(err && !json_is_null(err))
	{
		allow_gbt = false;
		applog(LOG_INFO, "GBT not supported, block height unavailable");
		return false;
	}

	if(!work->height)
	{
		// complete missing data from getwork
		json_t *key = json_object_get(val, "height");
		if(key && json_is_integer(key))
		{
			work->height = (uint32_t)json_integer_value(key);
			if(!opt_quiet && work->height > g_work.height)
			{
				if(!have_stratum && allow_mininginfo && global_diff > 0)
				{
					char netinfo[64] = { 0 };
					char srate[32] = { 0 };
					sprintf(netinfo, "diff %.2f", global_diff);
					if(net_hashrate)
					{
						format_hashrate((double)net_hashrate, srate);
						strcat(netinfo, ", net ");
						strcat(netinfo, srate);
					}
					applog(LOG_BLUE, "%s block %d, %s",
						   algo_names[opt_algo], work->height, netinfo);
				}
				else
				{
					applog(LOG_BLUE, "%s %s block %d", short_url,
						   algo_names[opt_algo], work->height);
				}
				g_work.height = work->height;
				if(!have_stratum)
				{
					double x = expectedblocktime(work->target);
					if(x != 0.0)
						applog(LOG_BLUE, "50%% chance to find a block in about %.2f days", x);
				}

			}
		}
	}

	return true;
}

#define GBT_CAPABILITIES "[\"coinbasetxn\", \"coinbasevalue\", \"longpoll\", \"workid\"]"
static const char *gbt_req =
"{\"method\": \"getblocktemplate\", \"params\": ["
//	"{\"capabilities\": " GBT_CAPABILITIES "}"
"], \"id\":9}\r\n";

static bool get_blocktemplate(CURL *curl, struct work *work)
{
	if(!allow_gbt)
		return false;

	int curl_err = 0;
	json_t *val = json_rpc_call(curl, rpc_url, rpc_userpass, gbt_req,
								want_longpoll, have_longpoll, &curl_err);

	if(!val && curl_err == -1)
	{
		// when getblocktemplate is not supported, disable it
		allow_gbt = false;
		if(!opt_quiet)
		{
			applog(LOG_BLUE, "gbt not supported, block height notices disabled");
		}
		return false;
	}

	bool rc = gbt_work_decode(json_object_get(val, "result"), work);

	json_decref(val);

	return rc;
}

// good alternative for wallet mining, difficulty and net hashrate
static const char *info_req =
"{\"method\": \"getmininginfo\", \"params\": [], \"id\":8}\r\n";

static bool get_mininginfo(CURL *curl, struct work *work)
{
	if(have_stratum || !allow_mininginfo)
		return false;

	int curl_err = 0;
	json_t *val = json_rpc_call(curl, rpc_url, rpc_userpass, info_req,
								want_longpoll, have_longpoll, &curl_err);

	if(!val && curl_err == -1)
	{
		allow_mininginfo = false;
		if(opt_debug)
		{
			applog(LOG_DEBUG, "getmininginfo not supported");
		}
		return false;
	}
	else
	{
		json_t *res = json_object_get(val, "result");
		// "blocks": 491493 (= current work height - 1)
		// "difficulty": 0.99607860999999998
		// "networkhashps": 56475980
		if(res)
		{
			json_t *key = json_object_get(res, "powdifficulty");
			if(key && json_is_real(key))
			{
				global_diff = json_real_value(key);
			}
			key = json_object_get(res, "difficulty");
			if(key && json_is_real(key))
			{
				global_diff = json_real_value(key);
			}
			key = json_object_get(res, "networkhashps");
			if(key && json_is_integer(key))
			{
				net_hashrate = json_integer_value(key);
			}
			key = json_object_get(res, "blocks");
			if(key && json_is_integer(key))
			{
				net_blocks = json_integer_value(key);
			}
		}
	}
	json_decref(val);
	return true;
}

// time (in days) for a 50% chance to find a block
double expectedblocktime(const uint32_t *target)
{
	double x = 0.0;
	if(global_hashrate == 0)
		return 0;
	else
	{
		for(int i = 0; i < 8; i++)
		{
			x *= 4294967296.0;
			x += target[7 - i];
		}
		if(x != 0.0)
			return 115792089237316195423570985008687907853269984665640564039457584007913129639935.0 / x / (double)global_hashrate / 86400.0;
		else
			return 0.0;
	}
}

static const char *rpc_req =
"{\"method\": \"getwork\", \"params\": [], \"id\":0}\r\n";

static bool get_upstream_work(CURL *curl, struct work *work)
{
	json_t *val;
	bool rc;
	struct timeval tv_start, tv_end, diff;

	gettimeofday(&tv_start, NULL);
	val = json_rpc_call(curl, rpc_url, rpc_userpass, rpc_req,
						want_longpoll, false, NULL);
	gettimeofday(&tv_end, NULL);

	if(have_stratum)
	{
		if(val)
			json_decref(val);
		return true;
	}

	if(!val)
		return false;

	rc = work_decode(json_object_get(val, "result"), work);

	if(opt_protocol && rc)
	{
		timeval_subtract(&diff, &tv_end, &tv_start);
		/* show time because curl can be slower against versions/config */
		applog(LOG_DEBUG, "got new work in %.2f ms",
			   (1000.0 * diff.tv_sec) + (0.001 * diff.tv_usec));
	}

	json_decref(val);

	get_mininginfo(curl, work);
	get_blocktemplate(curl, work);

	return rc;
}

static void workio_cmd_free(struct workio_cmd *wc)
{
	if(!wc)
		return;

	switch(wc->cmd)
	{
	case WC_SUBMIT_WORK:
		aligned_free(wc->u.work);
		break;
	default: /* do nothing */
		break;
	}

	memset(wc, 0, sizeof(*wc));	/* poison */
	free(wc);
}

static bool workio_get_work(struct workio_cmd *wc, CURL *curl)
{
	struct work *ret_work;
	int failures = 0;

	ret_work = (struct work*)aligned_calloc(sizeof(*ret_work));
	if(!ret_work)
		return false;

	/* obtain new work from bitcoin via JSON-RPC */
	while(!get_upstream_work(curl, ret_work))
	{
		if(unlikely((opt_retries >= 0) && (++failures > opt_retries)))
		{
			applog(LOG_ERR, "json_rpc_call failed, terminating workio thread");
			aligned_free(ret_work);
			return false;
		}

		/* pause, then restart work-request loop */
		applog(LOG_ERR, "json_rpc_call failed, retry after %d seconds",
			   opt_fail_pause);
		sleep(opt_fail_pause);
	}

	/* send work to requesting thread */
	if(!tq_push(wc->thr->q, ret_work))
		aligned_free(ret_work);

	return true;
}

static bool workio_submit_work(struct workio_cmd *wc, CURL *curl)
{
	int failures = 0;

	/* submit solution to bitcoin via JSON-RPC */
	while(!submit_upstream_work(curl, wc->u.work))
	{
		if(unlikely((opt_retries >= 0) && (++failures > opt_retries)))
		{
			applog(LOG_ERR, "...terminating workio thread");
			return false;
		}

		/* pause, then restart work-request loop */
		if(!opt_benchmark)
			applog(LOG_ERR, "...retry after %d seconds", opt_fail_pause);

		sleep(opt_fail_pause);
	}

	return true;
}

static void *workio_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info*)userdata;
	CURL *curl;
	bool ok = true;

	curl = curl_easy_init();
	if(unlikely(!curl))
	{
		applog(LOG_ERR, "CURL initialization failed");
		return NULL;
	}

	while(ok && !stop_mining)
	{
		struct workio_cmd *wc;

		/* wait for workio_cmd sent to us, on our queue */
		wc = (struct workio_cmd *)tq_pop(mythr->q, NULL);
		if(!wc)
		{
			ok = false;
			break;
		}

		/* process workio_cmd */
		switch(wc->cmd)
		{
		case WC_GET_WORK:
			ok = workio_get_work(wc, curl);
			break;
		case WC_SUBMIT_WORK:
			ok = workio_submit_work(wc, curl);
			break;

		default:		/* should never happen */
			ok = false;
			break;
		}

		workio_cmd_free(wc);
	}

	tq_freeze(mythr->q);

	return NULL;
}

static bool get_work(struct thr_info *thr, struct work *work)
{
	struct workio_cmd *wc;
	struct work *work_heap;

	if(opt_benchmark)
	{
		if(opt_algo != ALGO_SIA)
		{
			memset(work->data, 0x55, 76);
			memset(work->data + 19, 0x00, 52);
			work->data[1] = (uint32_t)((double)rand() / (1ULL + RAND_MAX) * 0xffffffffu);
			work->data[20] = 0x80000000;
			work->data[31] = 0x00000280;
			memset(work->target, 0x00, sizeof(work->target));
			work->datasize = 128;
		}
		else
		{
			memset(work->data, 0, 4);
			work->data[1] = (uint32_t)((double)rand() / (1ULL + RAND_MAX) * 0xffffffffu);
			memset(work->data+2, 0x55, 24);
			memset(work->data + 8, 0, 8);
			memset(work->data + 10, 0, 4);
			memset(work->data + 11, 0x55, 4);
			memset(work->data + 12, 0x55, 32);
			memset(work->target, 0x00, sizeof(work->target));
			work->datasize = 128;
		}
		return true;
	}

	/* fill out work request message */
	wc = (struct workio_cmd *)calloc(1, sizeof(*wc));
	if(wc == NULL)
	{
		applog(LOG_ERR, "Out of memory!");
		proper_exit(2);
	}

	wc->cmd = WC_GET_WORK;
	wc->thr = thr;

	/* send work request to workio thread */
	if(!tq_push(thr_info[work_thr_id].q, wc))
	{
		workio_cmd_free(wc);
		return false;
	}

	/* wait for response, a unit of work */
	work_heap = (struct work *)tq_pop(thr->q, NULL);
	if(!work_heap)
		return false;

	/* copy returned work into storage provided by caller */
	memcpy(work, work_heap, sizeof(*work));
	aligned_free(work_heap);

	return true;
}

static bool submit_work(struct thr_info *thr, const struct work *work_in)
{
	struct workio_cmd *wc;
	/* fill out work request message */
	wc = (struct workio_cmd *)calloc(1, sizeof(*wc));
	if(wc == NULL)
	{
		applog(LOG_ERR, "Out of memory!");
		proper_exit(2);
	}

	wc->u.work = (struct work *)aligned_calloc(sizeof(*work_in));
	if(wc->u.work == NULL)
	{
		applog(LOG_ERR, "Out of memory!");
		proper_exit(2);
	}

	wc->cmd = WC_SUBMIT_WORK;
	wc->thr = thr;
	memcpy(wc->u.work, work_in, sizeof(*work_in));

	/* send solution to workio thread */
	if(!tq_push(thr_info[work_thr_id].q, wc))
		goto err_out;

	return true;

err_out:
	workio_cmd_free(wc);
	return false;
}

static bool stratum_gen_work(struct stratum_ctx *sctx, struct work *work)
{
	extern void siahash(const void *data, unsigned int len, void *hash);
	uchar merkle_root[1024];
	int i;

	if(!sctx->job.job_id)
	{
		// applog(LOG_WARNING, "stratum_gen_work: job not yet retrieved");
		return false;
	}

	pthread_mutex_lock(&sctx->work_lock);

	// store the job ntime as high part of jobid
	snprintf(work->job_id, sizeof(work->job_id), "%07x %s",
					 be32dec(sctx->job.ntime) & 0xfffffff, sctx->job.job_id);
	work->xnonce2_len = sctx->xnonce2_size;
	memcpy(work->xnonce2, sctx->job.xnonce2, sctx->xnonce2_size);

	// also store the block number
	work->height = sctx->job.height;

	/* Generate merkle root */
	switch(opt_algo)
	{
		case ALGO_FUGUE256:
		case ALGO_GROESTL:
		case ALGO_KECCAK:
		case ALGO_BLAKECOIN:
		case ALGO_WHC:
			SHA256((uchar*)sctx->job.coinbase, sctx->job.coinbase_size, (uchar*)merkle_root);
			break;
		case ALGO_SIA:
		{
			merkle_root[0] = (uchar)0;
			memcpy(merkle_root + 1, sctx->job.coinbase, sctx->job.coinbase_size);
			siahash(merkle_root, (unsigned int)sctx->job.coinbase_size + 1, merkle_root + 33);
			break;
		}
		default:
			sha256d(merkle_root, sctx->job.coinbase, (int)sctx->job.coinbase_size);
	}
	if(opt_algo == ALGO_SIA)
		merkle_root[0] = (uchar)1;

	for(i = 0; i < sctx->job.merkle_count; i++)
	{
		if(opt_algo == ALGO_SIA)
		{
			memcpy(merkle_root + 1, sctx->job.merkle[i], 32);
			siahash(merkle_root, 65, merkle_root + 33);
		}
		else
		{
			memcpy(merkle_root + 32, sctx->job.merkle[i], 32);
			sha256d(merkle_root, merkle_root, 64);
		}
	}

	/* Increment extranonce2 */
	if(opt_extranonce)
	{
		i = 0;
		do
		{
			sctx->job.xnonce2[i]++;
			i++;
		} while(i < (int)sctx->xnonce2_size && sctx->job.xnonce2[i - 1] == 0);
	}
	static uint32_t highnonce = 0;
	if(opt_algo == ALGO_SIA)
		highnonce++;

	/* Assemble block header */
	memset(work->data, 0, sizeof(work->data));
	if(opt_algo != ALGO_SIA)
	{
		work->data[0] = le32dec(sctx->job.version);
		for(i = 0; i < 8; i++)
			work->data[1 + i] = le32dec((uint32_t *)sctx->job.prevhash + i);
		for(i = 0; i < 8; i++)
			work->data[9 + i] = be32dec((uint32_t *)merkle_root + i);
		work->data[17] = le32dec(sctx->job.ntime);
		work->data[18] = le32dec(sctx->job.nbits);
		work->data[20] = 0x80000000;
		work->data[31] = 0x00000280;
	}
	else
	{
		for(i = 0; i < 8; i++)
			work->data[i] = le32dec((uint32_t *)sctx->job.prevhash + i);
		work->data[8] = 0; // nonce
		work->data[9] = highnonce;
		work->data[10] = le32dec(sctx->job.ntime);
		work->data[11] = 0;
		for(i = 0; i < 8; i++)
			work->data[12 + i] = le32dec((uint32_t *)(merkle_root + 33) + i);
	}

	pthread_mutex_unlock(&sctx->work_lock);
	if(opt_debug)
	{
		char *tm;
		if(opt_algo != ALGO_SIA)
			tm = atime2str(swab32(work->data[17]) - sctx->srvtime_diff);
		else
			tm = atime2str(work->data[10] - sctx->srvtime_diff);
		char *xnonce2str = bin2hex(work->xnonce2, sctx->xnonce2_size);
		applog(LOG_DEBUG, "DEBUG: job_id=%s xnonce2=%s time=%s",
					 work->job_id, xnonce2str, tm);
		free(tm);
		free(xnonce2str);
	}

	switch(opt_algo)
	{
		case ALGO_JACKPOT:
		case ALGO_NEO:
			diff_to_target(work->target, sctx->job.diff / (65536.0 * opt_difficulty));
			break;
		case ALGO_DMD_GR:
		case ALGO_FRESH:
		case ALGO_FUGUE256:
		case ALGO_GROESTL:
		case ALGO_KECCAK:
		case ALGO_LYRA2v2:
			diff_to_target(work->target, sctx->job.diff / (256.0 * opt_difficulty));
			break;
		default:
			diff_to_target(work->target, sctx->job.diff / opt_difficulty);
	}
	return true;
}

void restart_threads(void)
{
	if(opt_debug && !opt_quiet)
		applog(LOG_DEBUG, "%s", __FUNCTION__);

	for(int i = 0; i < opt_n_threads; i++)
		work_restart[i].restart = 1;
}

static void *miner_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
	int thr_id = mythr->id;
	struct work work;
	uint64_t loopcnt = 0;
	uint32_t max_nonce;
	uint64_t end_nonce = 0x100000000ull / opt_n_threads * (thr_id + 1) - 1;
	bool extrajob = false;
	char s[16];
	int rc = 0;

	memset(&work, 0, sizeof(work)); // prevent work from being used uninitialized

	if(opt_priority > 0)
	{
		int prio = 2; // default to normal
#ifndef WIN32
		prio = 0;
		// note: different behavior on linux (-19 to 19)
		switch(opt_priority)
		{
		case 0:
			prio = 15;
			break;
		case 1:
			prio = 5;
			break;
		case 2:
			prio = 0; // normal process
			break;
		case 3:
			prio = -1; // above
			break;
		case 4:
			prio = -10;
			break;
		case 5:
			prio = -15;
		}
		if(opt_debug)
			applog(LOG_DEBUG, "Thread %d priority %d (nice %d)",
			thr_id, opt_priority, prio);
#endif
		setpriority(PRIO_PROCESS, 0, prio);
		drop_policy();
	}


	/* Cpu thread affinity */
	if(num_cpus > 1)
	{
		if(opt_affinity == -1)
		{
			if(opt_debug)
				applog(LOG_DEBUG, "Binding thread %d to cpu %d (mask %x)", thr_id,
				thr_id%num_cpus, (1 << (thr_id)));
			affine_to_cpu_mask(thr_id, 1 << (thr_id));
		}
		else if(opt_affinity != -1)
		{
			if(opt_debug)
				applog(LOG_DEBUG, "Binding thread %d to gpu mask %x", thr_id,
				opt_affinity);
			affine_to_cpu_mask(thr_id, opt_affinity);
		}
	}

	get_cuda_arch(&cuda_arch[thr_id]);

	while(!stop_mining)
	{
		// &work.data[19]
		int wcmplen;
		switch(opt_algo)
		{
			case ALGO_SIA:
				wcmplen = 80;
				break;
			default:
				wcmplen = 76;
		}
		uint32_t *nonceptr;
		if(opt_algo!=ALGO_SIA)
			nonceptr = (uint32_t*)(((char*)work.data) + wcmplen);
		else
			nonceptr = (uint32_t*)(((char*)work.data) + 8*4);

		struct timeval tv_start, tv_end, diff;
		uint32_t hashes_done = 0;
		uint32_t start_nonce;
		uint32_t scan_time = have_longpoll ? LP_SCANTIME : opt_scantime;
		uint64_t max64, minmax;

		if(have_stratum)
		{
			pthread_mutex_lock(&g_work_lock);
			if(loopcnt == 0 || time(NULL) >= (g_work_time + opt_scantime))
				extrajob = true;
			if(nonceptr[0] >= end_nonce - 0x00004000 || extrajob)
			{
				extrajob = false;
				int loop = 0;
				while(!stratum_gen_work(&stratum, &g_work) && !stop_mining)
				{
					pthread_mutex_unlock(&g_work_lock);
					if(loop > 0)
						applog(LOG_WARNING, "GPU #%d: waiting for data", device_map[thr_id]);
					sleep(3);
					loop++;
					pthread_mutex_lock(&g_work_lock);
				}
			}
		}
		else
		{
			pthread_mutex_lock(&g_work_lock);
			if((time(NULL) - g_work_time) >= scan_time || nonceptr[0] >= (end_nonce - 0x00004000))
			{
				if(opt_debug && g_work_time && !opt_quiet)
					applog(LOG_DEBUG, "work time %u/%us nonce %x/%x", time(NULL) - g_work_time,
					scan_time, nonceptr[0], end_nonce);
				/* obtain new work from internal workio thread */
				if(unlikely(!get_work(mythr, &g_work)))
				{
					pthread_mutex_unlock(&g_work_lock);
					applog(LOG_ERR, "work retrieval failed, exiting mining thread %d", mythr->id);
					goto out;
				}
				g_work_time = time(NULL);
			}
		}
		if(!opt_benchmark && (g_work.height != work.height || memcmp(work.target, g_work.target, sizeof(work.target))))
		{
			calc_diff(&g_work, 0);
			if(!have_stratum && !allow_mininginfo)
				global_diff = g_work.difficulty;
			if(opt_debug)
			{
				uint64_t target64 = g_work.target[7] * 0x100000000ULL + g_work.target[6];
				applog(LOG_DEBUG, "job %s target change: %llx (%.1f)", g_work.job_id, target64, g_work.difficulty);
			}
			memcpy(work.target, g_work.target, sizeof(work.target));
			work.difficulty = g_work.difficulty;
			work.height = g_work.height;
		}

		int different;
		if(opt_algo != ALGO_SIA)
			different = memcmp(work.data, g_work.data, wcmplen);
		else
			different = memcmp(work.data, g_work.data, 7*4) || memcmp(work.data + 9, g_work.data + 9, 44);
		if(different)
		{
			if(opt_debug)
				applog(LOG_DEBUG, "thread %d: new work", thr_id);
#if 0
			if(opt_debug)
			{
				for(int n = 0; n <= (wcmplen - 8); n += 8)
				{
					if(memcmp(work.data + n, g_work.data + n, 8))
					{
						applog(LOG_DEBUG, "job %s work updated at offset %d:", g_work.job_id, n);
						applog_hash((uchar*)&work.data[n]);
						applog_compare_hash((uchar*)&g_work.data[n], (uchar*)&work.data[n]);
					}
				}
			}
#endif
			if(opt_debug && opt_algo == ALGO_SIA)
				applog(LOG_DEBUG, "thread %d: high nonce = %08X", thr_id, work.data[9]);
			memcpy(&work, &g_work, sizeof(struct work));
			nonceptr[0] = (uint32_t)((0x100000000ull / opt_n_threads) * thr_id); // 0 if single thr
		}
		else
		{
			if(opt_debug)
				applog(LOG_DEBUG, "thread %d: continue with old work", thr_id);
		}
		work_restart[thr_id].restart = 0;
		pthread_mutex_unlock(&g_work_lock);
		/* adjust max_nonce to meet target scan time */
		uint32_t max64time;
		if(have_stratum)
			max64time = LP_SCANTIME;
		else
			max64time = (uint32_t)max(1, scan_time + g_work_time - time(NULL));

		max64 = max64time * (uint32_t)thr_hashrates[thr_id];

		/* on start, max64 should not be 0,
		*    before hashrate is computed */
		switch(opt_algo)
		{
			case ALGO_KECCAK:
				minmax = 83000000 * max64time;
				break;
			case ALGO_BLAKE:
			case ALGO_SIA:
				minmax = 260000000 * max64time;
				break;
			case ALGO_BLAKECOIN:
			case ALGO_VANILLA:
				minmax = 470000000 * max64time;
				break;
			case ALGO_BITCOIN:
				minmax = 100000000 * max64time;
				break;
			case ALGO_QUBIT:
			case ALGO_QUARK:
				minmax = 3100000 * max64time;
				break;
			case ALGO_JACKPOT:
				minmax = 2800000 * max64time;
				break;
			case ALGO_SKEIN:
			case ALGO_WHCX:
			case ALGO_DOOM:
			case ALGO_LUFFA_DOOM:
				minmax = 38000000 * max64time;
				break;
			case ALGO_NIST5:
			case ALGO_S3:
				minmax = 4600000 * max64time;
				break;
			case ALGO_X11:
			case ALGO_C11:
				minmax = 1500000 * max64time;
				break;
			case ALGO_X13:
				minmax = 1200000 * max64time;
				break;
			case ALGO_X17:
			case ALGO_X15:
				minmax = 1000000 * max64time;
				break;
			case ALGO_LYRA2v2:
				minmax = 1900000 * max64time;
				break;
			case ALGO_NEO:
				minmax = 90000 * max64time;
				break;
			default:
				minmax = 4000 * max64time;
		}
		max64 = max(minmax, max64);

		// we can't scan more than uint capacity
		max64 = min(UINT32_MAX, max64);
		start_nonce = nonceptr[0];

		/* never let small ranges at end */
		if(end_nonce >= UINT32_MAX - 256)
			end_nonce = UINT32_MAX;

		if((max64 + start_nonce) >= end_nonce)
			max_nonce = (uint32_t)end_nonce;
		else
			max_nonce = (uint32_t)(max64 + start_nonce);

		// todo: keep it rounded for gpu threads ?

		work.scanned_from = start_nonce;

		if(opt_debug)
			applog(LOG_DEBUG, "GPU #%d: start=%08x end=%08x range=%08x",
			device_map[thr_id], start_nonce, max_nonce, (max_nonce - start_nonce + 1));

		hashes_done = 0;
		gettimeofday(&tv_start, NULL);
		uint32_t databackup;
		if(opt_algo != ALGO_SIA)
			databackup = nonceptr[2];
		else
			databackup = nonceptr[12];

		if(!stop_mining)
			mining_has_stopped[thr_id] = false;
		else
		{
			mining_has_stopped[thr_id] = true;
			pthread_exit(nullptr);
		}

		/* scan nonces for a proof-of-work hash */
		switch(opt_algo)
		{

		case ALGO_KECCAK:
			rc = scanhash_keccak256(thr_id, work.data, work.target,
									max_nonce, &hashes_done);
			break;

		case ALGO_DEEP:
			rc = scanhash_deep(thr_id, work.data, work.target,
							   max_nonce, &hashes_done);
			break;

		case ALGO_DOOM:
		case ALGO_LUFFA_DOOM:
			rc = scanhash_doom(thr_id, work.data, work.target,
							   max_nonce, &hashes_done);
			break;

		case ALGO_C11:
			rc = scanhash_c11(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_FUGUE256:
			rc = scanhash_fugue256(thr_id, work.data, work.target,
								   max_nonce, &hashes_done);
			break;

		case ALGO_GROESTL:
		case ALGO_DMD_GR:
			rc = scanhash_groestlcoin(thr_id, work.data, work.target,
									  max_nonce, &hashes_done);
			break;

		case ALGO_MYR_GR:
			rc = scanhash_myriad(thr_id, work.data, work.target,
								 max_nonce, &hashes_done);
			break;

		case ALGO_JACKPOT:
			rc = scanhash_jackpot(thr_id, work.data, work.target,
								  max_nonce, &hashes_done);
			break;

		case ALGO_QUARK:
			rc = scanhash_quark(thr_id, work.data, work.target,
								max_nonce, &hashes_done);
			break;

		case ALGO_QUBIT:
			rc = scanhash_qubit(thr_id, work.data, work.target,
								max_nonce, &hashes_done);
			break;


		case ALGO_BITCOIN:
			rc = scanhash_bitcoin(thr_id, work.data, work.target,
								  max_nonce, &hashes_done);
			break;

		case ALGO_VANILLA:
			rc = scanhash_blake256(thr_id, work.data, work.target,
														 max_nonce, &hashes_done, 8);
			break;

		case ALGO_BLAKECOIN:
			rc = scanhash_blake256(thr_id, work.data, work.target,
								   max_nonce, &hashes_done, 8);
			break;

		case ALGO_BLAKE:
			rc = scanhash_blake256(thr_id, work.data, work.target,
								   max_nonce, &hashes_done, 14);
			break;

		case ALGO_FRESH:
			rc = scanhash_fresh(thr_id, work.data, work.target,
								max_nonce, &hashes_done);
			break;

		case ALGO_LYRA2v2:
			rc = scanhash_lyra2v2(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_NIST5:
			rc = scanhash_nist5(thr_id, work.data, work.target,
								max_nonce, &hashes_done);
			break;

		case ALGO_PENTABLAKE:
			rc = scanhash_pentablake(thr_id, work.data, work.target,
									 max_nonce, &hashes_done);
			break;

		case ALGO_SKEIN:
			rc = scanhash_skeincoin(thr_id, work.data, work.target,
									max_nonce, &hashes_done);
			break;

		case ALGO_S3:
			rc = scanhash_s3(thr_id, work.data, work.target,
							 max_nonce, &hashes_done);
			break;

		case ALGO_WHC:
			rc = scanhash_whc(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_WHCX:
			rc = scanhash_whirlpoolx(thr_id, work.data, work.target,
									 max_nonce, &hashes_done);
			break;

		case ALGO_X11:
			rc = scanhash_x11(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_X13:
			rc = scanhash_x13(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_X14:
			rc = scanhash_x14(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_X15:
			rc = scanhash_x15(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_X17:
			rc = scanhash_x17(thr_id, work.data, work.target,
							  max_nonce, &hashes_done);
			break;

		case ALGO_NEO:
			if(!have_stratum && work.datasize == 128)
				rc = scanhash_neoscrypt(true, thr_id, work.data, work.target, max_nonce, &hashes_done);
			else
				rc = scanhash_neoscrypt(have_stratum, thr_id, work.data, work.target, max_nonce, &hashes_done);
			break;

		case ALGO_SIA:
			rc = scanhash_sia(thr_id, work.data, work.target, max_nonce, &hashes_done);
			break;

		default:
			/* should never happen */
			goto out;
		}
		mining_has_stopped[thr_id] = true;
		/* record scanhash elapsed time */
		gettimeofday(&tv_end, NULL);
		if(rc && opt_debug)
			applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", nonceptr[0], swab32(nonceptr[0])); // data[19]
		if(opt_algo != ALGO_SIA)
		{
			if(rc > 1 && opt_debug)
				applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", nonceptr[2], swab32(nonceptr[2])); // data[21]
		}
		else
		{
			if(rc > 1 && opt_debug)
				applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", nonceptr[12], swab32(nonceptr[12])); // data[21]
		}
		timeval_subtract(&diff, &tv_end, &tv_start);

		if(diff.tv_sec > 0 || (diff.tv_sec == 0 && diff.tv_usec>2000)) // avoid totally wrong hash rates
		{
			double dtime = (double)diff.tv_sec + 1e-6 * diff.tv_usec;

			/* hashrate factors for some algos */
			double rate_factor;
			switch(opt_algo)
			{
				case ALGO_JACKPOT:
				case ALGO_QUARK:
					// to stay comparable to other ccminer forks or pools
					rate_factor = 0.5;
					break;
				default:
					rate_factor = 1.0;
			}

			/* store thread hashrate */
			if(dtime > 0.0)
			{
				pthread_mutex_lock(&stats_lock);
				thr_hashrates[thr_id] = hashes_done / dtime;
				thr_hashrates[thr_id] *= rate_factor;
				stats_remember_speed(thr_id, hashes_done, thr_hashrates[thr_id], (uint8_t)rc, work.height);
				pthread_mutex_unlock(&stats_lock);
			}
		}

		work.scanned_to = start_nonce + hashes_done - 1;
		if(opt_debug && opt_benchmark)
		{
			// to debug nonce ranges
			applog(LOG_DEBUG, "GPU #%d:  ends=%08x range=%08x", device_map[thr_id],
				   start_nonce + hashes_done - 1, hashes_done);
		}

		if(check_dups)
			hashlog_remember_scan_range(&work);

		if(!opt_quiet && loopcnt > 0)
		{
			double hashrate;

			hashrate = thr_hashrates[thr_id];
			format_hashrate(hashrate, s);
			applog(LOG_INFO, "GPU #%d: %s, %s", device_map[thr_id], device_name[device_map[thr_id]], s);
		}

		/* loopcnt: ignore first loop hashrate */
		if((loopcnt>0) && thr_id == (opt_n_threads - 1))
		{
			double hashrate = 0.;
			pthread_mutex_lock(&stats_lock);
			for(int i = 0; i < opt_n_threads; i++)
				hashrate += stats_get_speed(i, thr_hashrates[i]);
			pthread_mutex_unlock(&stats_lock);
			if(opt_benchmark)
			{
				format_hashrate(hashrate, s);
				applog(LOG_NOTICE, "Total: %s", s);
			}

			// X-Mining-Hashrate
			global_hashrate = llround(hashrate);
		}

		/* if nonce found, submit work */
		if(rc && !opt_benchmark)
		{
			uint32_t found2;
			if(opt_algo != ALGO_SIA)
			{
				found2 = nonceptr[2];
				nonceptr[2] = databackup;
			}
			else
			{
				found2 = nonceptr[12];
				nonceptr[12] = databackup;
			}
			if(!submit_work(mythr, &work))
				break;

			// prevent stale work in solo
			// we can't submit twice a block!
			if(!have_stratum && !have_longpoll)
			{
				pthread_mutex_lock(&g_work_lock);
				// will force getwork
				g_work_time = 0;
				pthread_mutex_unlock(&g_work_lock);
				continue;
			}

			// second nonce found, submit too (on pool only!)
			if(rc > 1)
			{
				nonceptr[0] = found2;
				if(!submit_work(mythr, &work))
					break;
			}
		}
		nonceptr[0] = start_nonce + hashes_done;

		loopcnt++;
	}

out:
	tq_freeze(mythr->q);

	return NULL;
}

static void *longpoll_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
	CURL *curl = NULL;
	char *copy_start, *hdr_path = NULL, *lp_url = NULL;
	bool need_slash = false;

	curl = curl_easy_init();
	if(unlikely(!curl))
	{
		applog(LOG_ERR, "CURL initialization failed");
		goto out;
	}

start:
	hdr_path = (char*)tq_pop(mythr->q, NULL);
	if(!hdr_path)
		goto out;

	/* full URL */
	if(strstr(hdr_path, "://"))
	{
		lp_url = hdr_path;
		hdr_path = NULL;
	}

	/* absolute path, on current server */
	else
	{
		copy_start = (*hdr_path == '/') ? (hdr_path + 1) : hdr_path;
		if(rpc_url[strlen(rpc_url) - 1] != '/')
			need_slash = true;

		lp_url = (char*)malloc(strlen(rpc_url) + strlen(copy_start) + 2);
		if(lp_url == NULL)
		{
			applog(LOG_ERR, "Out of memory!");
			proper_exit(2);
		}

		sprintf(lp_url, "%s%s%s", rpc_url, need_slash ? "/" : "", copy_start);
	}

	applog(LOG_INFO, "Long-polling enabled on %s", lp_url);

	while(!stop_mining)
	{
		json_t *val, *soval;
		int err;

		val = json_rpc_call(curl, lp_url, rpc_userpass, rpc_req,
							false, true, &err);
		if(have_stratum)
		{
			if(val)
				json_decref(val);
			goto out;
		}
		if(likely(val))
		{
			soval = json_object_get(json_object_get(val, "result"), "submitold");
			submit_old = soval ? json_is_true(soval) : false;
			pthread_mutex_lock(&g_work_lock);
			if(work_decode(json_object_get(val, "result"), &g_work))
			{
				if(!opt_quiet)
					applog(LOG_BLUE, "%s detected new block", short_url);
				g_work_time = time(NULL);
				restart_threads();
			}
			pthread_mutex_unlock(&g_work_lock);
			json_decref(val);
		}
		else
		{
			pthread_mutex_lock(&g_work_lock);
			g_work_time -= LP_SCANTIME;
			pthread_mutex_unlock(&g_work_lock);
			restart_threads();
			if(err != CURLE_OPERATION_TIMEDOUT)
			{
				have_longpoll = false;
				free(hdr_path);
				free(lp_url);
				lp_url = NULL;
				sleep(opt_fail_pause);
				goto start;
			}
		}
	}

out:
	free(hdr_path);
	free(lp_url);
	tq_freeze(mythr->q);

	return NULL;
}

static bool stratum_handle_response(char *buf)
{
	json_t *val, *err_val, *res_val, *id_val;
	json_error_t err;
	struct timeval tv_answer, diff;
	bool ret = false;

	val = JSON_LOADS(buf, &err);
	if(!val)
	{
		applog(LOG_INFO, "JSON decode failed(%d): %s", err.line, err.text);
		goto out;
	}

	res_val = json_object_get(val, "result");
	err_val = json_object_get(val, "error");
	id_val = json_object_get(val, "id");

	if(!id_val || json_is_null(id_val) || !res_val)
		goto out;

	// ignore subscribe late answer (yaamp)
	if(json_integer_value(id_val) < 4)
		goto out;

	gettimeofday(&tv_answer, NULL);
	timeval_subtract(&diff, &tv_answer, &stratum.tv_submit);
	// store time required to the pool to answer to a submit
	stratum.answer_msec = (1000 * diff.tv_sec) + (uint32_t)(0.001 * diff.tv_usec);

	share_result(json_is_true(res_val),
				 err_val ? json_string_value(json_array_get(err_val, 1)) : NULL);

	ret = true;
out:
	if(val)
		json_decref(val);

	return ret;
}

static void *stratum_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
	char *s;

	stratum.url = (char*)tq_pop(mythr->q, NULL);
	if(!stratum.url)
		goto out;
	applog(LOG_BLUE, "Starting Stratum on %s", stratum.url);
	stratum.curl = NULL;
	while(!stop_mining)
	{
		int failures = 0;

		if(stratum_need_reset)
		{
			stratum_need_reset = false;
			stratum_disconnect(&stratum);
			applog(LOG_DEBUG, "stratum connection reset");
		}

		while(!stratum.curl && !stop_mining)
		{
			pthread_mutex_lock(&g_work_lock);
			g_work_time = 0;
			pthread_mutex_unlock(&g_work_lock);
			restart_threads();

			if(!stratum_connect(&stratum, stratum.url) ||
			   !stratum_subscribe(&stratum) ||
			   !stratum_authorize(&stratum, rpc_user, rpc_pass, opt_extranonce))
			{
				stratum_disconnect(&stratum);
				if(opt_retries >= 0 && ++failures > opt_retries)
				{
					applog(LOG_ERR, "...terminating workio thread");
					tq_push(thr_info[work_thr_id].q, NULL);
					goto out;
				}
				if(!opt_benchmark)
					applog(LOG_ERR, "...retry after %d seconds", opt_fail_pause);
				sleep(opt_fail_pause);
			}
		}

		if(stratum.job.job_id &&
		   (!g_work_time || strncmp(stratum.job.job_id, g_work.job_id + 8, 120)))
		{
			pthread_mutex_lock(&g_work_lock);
			stratum_gen_work(&stratum, &g_work);
			g_work_time = time(NULL);
			if(stratum.job.clean)
			{
//				if(!opt_quiet)
//					applog(LOG_BLUE, "%s %s block %d", short_url, algo_names[opt_algo],
//					stratum.job.height);
				restart_threads();
				if(check_dups)
					hashlog_purge_old();
				stats_purge_old();
			}
			else if(opt_debug && !opt_quiet)
			{
				applog(LOG_BLUE, "%s asks job %s for block %d", short_url,
					   stratum.job.job_id, stratum.job.height);
			}
			pthread_mutex_unlock(&g_work_lock);
		}

		if(!stratum_socket_full(&stratum, opt_timeout))
		{
			applog(LOG_ERR, "Stratum connection timed out");
			s = NULL;
		}
		else
			s = stratum_recv_line(&stratum);
		if(!s)
		{
			stratum_disconnect(&stratum);
			applog(LOG_ERR, "Stratum connection interrupted");
			continue;
		}
		if(!stratum_handle_method(&stratum, s))
			stratum_handle_response(s);
		free(s);
	}

out:
	// call proper_exit() because the main thread only waits for the workio thread
	proper_exit(EXIT_FAILURE);
	return NULL;
}

static void show_version_and_exit(void)
{
	printf("%s v%s\n"
#ifdef WIN32
		   "pthreads static %s\n"
#endif
		   "%s\n",
		   PACKAGE_NAME, PACKAGE_VERSION,
#ifdef WIN32
		   PTW32_VERSION_STRING,
#endif
		   curl_version());
	proper_exit(0);
}

static void show_usage_and_exit(int status)
{
	if(status)
		fprintf(stderr, "Try `" PROGRAM_NAME " --help' for more information.\n");
	else
		printf(usage);
	proper_exit(status);
}

static void parse_arg(int key, char *arg)
{
	char *p = arg;
	int v, i;
	double d;

	switch(key)
	{
	case 'a':
		for(i = 0; i < ARRAY_SIZE(algo_names); i++)
		{
			if(algo_names[i] &&
			   !strcasecmp(arg, algo_names[i]))
			{
				opt_algo = (enum sha_algos)i;
				break;
			}
		}
		break;
	case 'b':
		p = strstr(arg, ":");
		if(p)
		{
			/* ip:port */
			if(p - arg > 0)
			{
				free(opt_api_allow);
				opt_api_allow = strdup(arg);
				opt_api_allow[p - arg] = '\0';
			}
			opt_api_listen = atoi(p + 1);
		}
		else if(arg && strstr(arg, "."))
		{
			/* ip only */
			free(opt_api_allow);
			opt_api_allow = strdup(arg);
		}
		else if(arg)
		{
			/* port or 0 to disable */
			opt_api_listen = atoi(arg);
		}
		break;
	case 'B':
		opt_background = true;
		break;
	case 'c': {
		json_error_t err;
		if(opt_config)
			json_decref(opt_config);
#if JANSSON_VERSION_HEX >= 0x020000
		opt_config = json_load_file(arg, 0, &err);
#else
		opt_config = json_load_file(arg, &err);
#endif
		if(!json_is_object(opt_config))
		{
			applog(LOG_ERR, "JSON decode of %s failed", arg);
			exit(1);
		}
		break;
	}
	case 'i':
		d = atof(arg);
		v = (uint32_t)d;
		if(v < 0 || v > 31)
		{
			printf("Intensity value out of range\n");
			printf("Try --help for more information!\n");
			exit(EXIT_FAILURE);
		}
		else
		{
			int n = 0;
			int ngpus = cuda_num_devices();
			uint32_t last = 0;
			char *pch = arg;
			do
			{
				d = atof(pch);
				v = (uint32_t)d;
				if(v > 7)
				{ /* 0 = default */
					if((d - v) > 0.0)
					{
						uint32_t adds = (uint32_t)floor((d - v) * (1 << v));
						gpus_intensity[n] = (1 << v) + adds;
						applog(LOG_INFO, "Adding %u threads to intensity %u, %u cuda threads",
							   adds, v, gpus_intensity[n]);
					}
					else if(gpus_intensity[n] != (1 << v))
					{
						gpus_intensity[n] = (1 << v);
						applog(LOG_INFO, "Intensity set to %u, %u cuda threads",
							   v, gpus_intensity[n]);
					}
				}
				last = gpus_intensity[n];
				n++;
				pch = strpbrk(pch, ",");
				if(pch != NULL)
					pch++;
			} while(pch != NULL);
			while(n < MAX_GPUS)
				gpus_intensity[n++] = last;
		}
		break;
	case 'D':
		opt_debug = true;
		break;
	case 'N':
		v = atoi(arg);
		if(v < 1)
			opt_statsavg = INT_MAX;
		opt_statsavg = v;
		break;
	case 'n': /* --ndevs */
		cuda_print_devices();
		exit(0);
		break;
	case 'q':
		opt_quiet = true;
		break;
	case 'p':
		free(rpc_pass);
		rpc_pass = strdup(arg);
		break;
	case 'P':
		opt_protocol = true;
		break;
	case 'r':
		v = atoi(arg);
		if(v < -1 || v > 9999)	/* sanity check */
		{
			printf("Value for number of retries is out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_retries = v;
		break;
	case 'R':
		v = atoi(arg);
		if(v < 1 || v > 9999)	/* sanity check */
		{
			printf("Value for retry pause is out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_fail_pause = v;
		break;
	case 's':
		v = atoi(arg);
		if(v < 1 || v > 9999)	/* sanity check */
		{
			printf("Value for scantime is out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_scantime = v;
		break;
	case 'T':
		v = atoi(arg);
		if(v < 1 || v > 99999)	/* sanity check */
		{
			printf("Value for timeout is out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_timeout = v;
		break;
	case 't':
		v = atoi(arg);
		if(v < 1 || v > 9999)	/* sanity check */
		{
			printf("Value for number of threads is out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_n_threads = v;
		break;
	case 'u':
		free(rpc_user);
		rpc_user = strdup(arg);
		break;
	case 'o':			/* --url */
		p = strstr(arg, "://");
		if(p)
		{
			if(strncasecmp(arg, "http://", 7) && strncasecmp(arg, "https://", 8) &&
			   strncasecmp(arg, "stratum+tcp://", 14))
			{
				printf("URL error\n");
				exit(EXIT_FAILURE);
			}
			free(rpc_url);
			rpc_url = strdup(arg);
			short_url = &rpc_url[(p - arg) + 3];
		}
		else
		{
			if(!strlen(arg) || *arg == '/')
			{
				printf("URL error\n");
				exit(EXIT_FAILURE);
			}
			free(rpc_url);
			rpc_url = (char*)malloc(strlen(arg) + 8);
			if(rpc_url == NULL)
			{
				applog(LOG_ERR, "Out of memory!\n");
				exit(1);
			}
			sprintf(rpc_url, "http://%s", arg);
			short_url = &rpc_url[7];
		}
		p = strrchr(rpc_url, '@');
		if(p)
		{
			char *sp, *ap;
			*p = '\0';
			ap = strstr(rpc_url, "://") + 3;
			sp = strchr(ap, ':');
			if(sp)
			{
				free(rpc_userpass);
				rpc_userpass = strdup(ap);
				free(rpc_user);
				rpc_user = (char*)calloc(sp - ap + 1, 1);
				if(rpc_user == NULL)
				{
					applog(LOG_ERR, "Out of memory!\n");
					proper_exit(1);
				}
				strncpy(rpc_user, ap, sp - ap);
				free(rpc_pass);
				rpc_pass = strdup(sp + 1);
			}
			else
			{
				free(rpc_user);
				rpc_user = strdup(ap);
			}
			memmove(ap, p + 1, strlen(p + 1) + 1);
			short_url = p + 1;
		}
		have_stratum = !opt_benchmark && !strncasecmp(rpc_url, "stratum", 7);
		break;
	case 'O':			/* --userpass */
		p = strchr(arg, ':');
		if(!p)
		{
			printf("username:password error\n");
			exit(EXIT_FAILURE);
		}
		free(rpc_userpass);
		rpc_userpass = strdup(arg);
		free(rpc_user);
		rpc_user = (char*)calloc(p - arg + 1, 1);
		if(rpc_user == NULL)
		{
			applog(LOG_ERR, "Out of memory!\n");
			proper_exit(1);
		}
		strncpy(rpc_user, arg, p - arg);
		free(rpc_pass);
		rpc_pass = strdup(p + 1);
		break;
	case 'x':			/* --proxy */
		if(!strncasecmp(arg, "socks4://", 9))
			opt_proxy_type = CURLPROXY_SOCKS4;
		else if(!strncasecmp(arg, "socks5://", 9))
			opt_proxy_type = CURLPROXY_SOCKS5;
#if LIBCURL_VERSION_NUM >= 0x071200
		else if(!strncasecmp(arg, "socks4a://", 10))
			opt_proxy_type = CURLPROXY_SOCKS4A;
		else if(!strncasecmp(arg, "socks5h://", 10))
			opt_proxy_type = CURLPROXY_SOCKS5_HOSTNAME;
#endif
		else
			opt_proxy_type = CURLPROXY_HTTP;
		free(opt_proxy);
		opt_proxy = strdup(arg);
		break;
	case 1001:
		free(opt_cert);
		opt_cert = strdup(arg);
		break;
	case 1002:
		use_colors = false;
		break;
	case 1005:
		opt_benchmark = true;
		want_longpoll = false;
		want_stratum = false;
		have_stratum = false;
		break;
	case 1006:
		print_hash_tests();
		proper_exit(0);
		break;
	case 1003:
		want_longpoll = false;
		break;
	case 1007:
		want_stratum = false;
		break;
	case 1011:
		allow_gbt = false;
		break;
	case 'S':
	case 1008:
		applog(LOG_INFO, "Now logging to syslog...");
		use_syslog = true;
		if(arg && strlen(arg))
		{
			free(opt_syslog_pfx);
			opt_syslog_pfx = strdup(arg);
		}
		break;
	case 1020:
		v = atoi(arg);
		if(v < -1)
			v = -1;
		if(v >(1 << num_cpus) - 1)
			v = -1;
		opt_affinity = v;
		break;
	case 1021:
		v = atoi(arg);
		if(v < 0 || v > 5)	/* sanity check */
		{
			printf("cpu priority value out of range\n");
			exit(EXIT_FAILURE);
		}
		opt_priority = v;
		break;
	case 1022:
		opt_verify = false;
		break;
	case 1025: // cuda-schedule
		switch(atoi(arg))
		{
			case 0:
				cudaschedule = cudaDeviceScheduleBlockingSync;
				break;
			case 1:
				cudaschedule = cudaDeviceScheduleSpin;
				break;
			case 2:
				cudaschedule = cudaDeviceScheduleYield;
				break;
			default:
				applog(LOG_WARNING, "Warning: invalid value for --cuda-schedule option");
				cudaschedule = cudaDeviceScheduleBlockingSync;
		}
		break;
	case 'd': // CB
	{
		int i;
		bool gpu[32] = {false};
		int ngpus = cuda_num_devices();
		char * pch = strtok(arg, ",");
		opt_n_threads = 0;
		while(pch != NULL)
		{
			if(pch[0] >= '0' && pch[0] <= '9')
			{
				i = atoi(pch);
				if(i < ngpus && gpu[i] == false)
				{
					gpu[i] = true;
					device_map[opt_n_threads++] = i;
				}
				else
				{
					if(gpu[i] == true)
						applog(LOG_WARNING, "Selected gpu #%d more than once in -d option. This is not supported.\n", i);
					else
					{
						applog(LOG_ERR, "Non-existant CUDA device #%d specified in -d option\n", i);
						exit(1);
					}
				}
			}
			else
			{
				int device = cuda_finddevice(pch);
				if(device >= 0 && device < ngpus)
					device_map[opt_n_threads++] = device;
				else
				{
					applog(LOG_ERR, "Non-existant CUDA device '%s' specified in -d option\n", pch);
					exit(1);
				}
			}
			// set number of active gpus
			active_gpus = opt_n_threads;
			pch = strtok(NULL, ",");
		}
	}
	break;
	case 'f': // CH - Divisor for Difficulty
		d = atof(arg);
		if(d == 0)	/* sanity check */
		{
			printf("Error: diff factor can't be 0\n");
			exit(EXIT_FAILURE);
		}
		opt_difficulty = d;
		break;
	case 'm': // --diff-multiplier
		d = atof(arg);
		if(d <= 0.)
		{
			printf("Error: diff multiplier can't be zero or negative\n");
			exit(EXIT_FAILURE);
		}
		opt_difficulty = 1.0/d;
		break;
	case 'e':
		opt_extranonce = false;
		break;
	case 'V':
		show_version_and_exit();
	case 'h':
		printf(usage);
		exit(EXIT_SUCCESS);
	case 1070: /* --gpu-clock */
	{
		char *pch = strtok(arg, ",");
		int n = 0;
		while(pch != NULL && n < MAX_GPUS)
		{
			int dev_id = device_map[n++];
			device_gpu_clocks[dev_id] = atoi(pch);
			pch = strtok(NULL, ",");
		}
	}
	break;
	case 1071: /* --mem-clock */
	{
		char *pch = strtok(arg, ",");
		int n = 0;
		while(pch != NULL && n < MAX_GPUS)
		{
			int dev_id = device_map[n++];
			if(*pch == '+' || *pch == '-')
				device_mem_offsets[dev_id] = atoi(pch);
			else
				device_mem_clocks[dev_id] = atoi(pch);
			need_nvsettings = true;
			pch = strtok(NULL, ",");
		}
	}
	break;
	case 1072: /* --pstate */
	{
		char *pch = strtok(arg, ",");
		int n = 0;
		while(pch != NULL && n < MAX_GPUS)
		{
			int dev_id = device_map[n++];
			device_pstate[dev_id] = (int8_t)atoi(pch);
			pch = strtok(NULL, ",");
		}
	}
	break;
	case 1073: /* --plimit */
	{
		char *pch = strtok(arg, ",");
		int n = 0;
		while(pch != NULL && n < MAX_GPUS)
		{
			int dev_id = device_map[n++];
			device_plimit[dev_id] = atoi(pch);
			pch = strtok(NULL, ",");
		}
	}
	break;
	case 1074: /* --logfile */
	{
		if (strlen(arg) > 0)
		{
			logfilename = strdup(arg);
			logfilepointer = fopen(logfilename, "w");
			if (logfilepointer == NULL)
				printf("\nWarning: can't create file %s\nLogging to file is disabled\n", logfilename);
			else
			{
				printf("\nLogfile = %s\n", logfilename);
				opt_logfile = true;
			}
		}
		else
			printf("\nNo logfile name.\nLogging to file is disabled\n ");
	}
	break;
	default:
		printf(usage);
		exit(EXIT_FAILURE);
	}

	if(use_syslog)
		use_colors = false;
}

/**
* Parse json config file
*/
static void parse_config(void)
{
	int i;
	json_t *val;

	if(!json_is_object(opt_config))
		return;

	for(i = 0; i < ARRAY_SIZE(options); i++)
	{

		if(!options[i].name)
			break;
		if(!strcmp(options[i].name, "config"))
			continue;

		val = json_object_get(opt_config, options[i].name);
		if(!val)
			continue;

		if(options[i].has_arg && json_is_string(val))
		{
			char *s = strdup(json_string_value(val));
			if(!s)
				continue;
			parse_arg(options[i].val, s);
			free(s);
		}
		else if(options[i].has_arg && json_is_integer(val))
		{
			char buf[16];
			sprintf(buf, "%d", (int)json_integer_value(val));
			parse_arg(options[i].val, buf);
		}
		else if(options[i].has_arg && json_is_real(val))
		{
			char buf[16];
			sprintf(buf, "%f", json_real_value(val));
			parse_arg(options[i].val, buf);
		}
		else if(!options[i].has_arg)
		{
			if(json_is_true(val))
				parse_arg(options[i].val, (char*) "");
		}
		else
			applog(LOG_ERR, "JSON option %s invalid",
			options[i].name);
	}
}

static void parse_cmdline(int argc, char *argv[])
{
	int key;

	while(1)
	{
#if HAVE_GETOPT_LONG
		key = getopt_long(argc, argv, short_options, options, NULL);
#else
		key = getopt(argc, argv, short_options);
#endif
		if(key < 0)
			break;

		parse_arg(key, optarg);
	}
	if(optind < argc)
	{
		fprintf(stderr, "%s: unsupported non-option argument '%s'\n",
				argv[0], argv[optind]);
		show_usage_and_exit(1);
	}

	parse_config();

}

#ifndef WIN32
static void signal_handler(int sig)
{
	switch(sig)
	{
	case SIGHUP:
		applog(LOG_INFO, "SIGHUP received");
		break;
	case SIGINT:
		signal(sig, SIG_IGN);
		applog(LOG_INFO, "SIGINT received, exiting");
		proper_exit(2);
		break;
	case SIGTERM:
		applog(LOG_INFO, "SIGTERM received, exiting");
		proper_exit(2);
		break;
	}
}
#else
BOOL WINAPI ConsoleHandler(DWORD dwType)
{
	switch(dwType)
	{
	case CTRL_C_EVENT:
		applog(LOG_INFO, "CTRL_C_EVENT received, exiting");
		proper_exit(2);
		break;
	case CTRL_BREAK_EVENT:
		applog(LOG_INFO, "CTRL_BREAK_EVENT received, exiting");
		proper_exit(2);
		break;
	default:
		return false;
	}
	return true;
}
#endif

static int msver(void)
{
	int version;
#ifdef _MSC_VER
	switch(_MSC_VER)
	{
		case 1500: version = 2008; break;
		case 1600: version = 2010; break;
		case 1700: version = 2012; break;
		case 1800: version = 2013; break;
		case 1900: version = 2015; break;
		default: version = _MSC_VER / 100;
	}
	if(_MSC_VER >= 1910)
		version = 2017;
#else
	version = 0;
#endif
	return version;
}

bool strictaliasingtest(short *h, long *k)
{
	*h = 5;
	*k = 6;
	if(*h == 5)
		return true;
	else
		return false;
}

int main(int argc, char *argv[])
{
	struct thr_info *thr;
	int i;
	
	// strdup on char* to allow a common free() if used
	opt_syslog_pfx = strdup(PROGRAM_NAME);
	opt_api_allow = strdup("127.0.0.1"); /* 0.0.0.0 for all ips */

#if defined _WIN64 || defined _LP64
	printf("ccminer " PACKAGE_VERSION " (64bit) for nVidia GPUs\n");
#else
	printf("ccminer " PACKAGE_VERSION " (32bit) for nVidia GPUs\n");
#endif
#ifdef _MSC_VER
	printf("Compiled with Visual Studio %d ", msver());
#else
#ifdef __clang__
	printf("Compiled with Clang %s ", __clang_version__);
#else
#ifdef __GNUC__
	printf("Compiled with GCC %d.%d ", __GNUC__, __GNUC_MINOR__);
#else
	printf("Compiled with an unusual compiler ");
#endif
#endif
#endif
	printf("using Nvidia CUDA Toolkit %d.%d\n\n", CUDART_VERSION / 1000, (CUDART_VERSION % 1000) / 10);
	printf("Based on pooler cpuminer 2.3.2 and the tpruvot@github fork\n");
	printf("CUDA support by Christian Buchner, Christian H. and DJM34\n");
	printf("Includes optimizations implemented by sp-hash, klaust, tpruvot and tsiv.\n\n");

#ifdef WIN32
	if(CUDART_VERSION == 8000 && _MSC_VER > 1900)
		printf("WARNING! CUDA 8 is not compatible with Visual Studio versions newer than 2015\n\n");
#endif
#if !defined __clang__ && defined __GNUC__
	if(CUDART_VERSION == 8000 && __GNUC__ > 5)
	{
		printf("WARNING! GCC %d IS NOT COMPATIBLE WITH CUDA 8!\n", __GNUC__);
		printf("PLEASE USE GCC 5\n\n");
	}
	if((CUDART_VERSION == 9000 || CUDART_VERSION == 9010) && __GNUC__ > 6)
	{
		printf("WARNING! GCC %d IS NOT COMPATIBLE WITH CUDA 9!\n", __GNUC__);
		printf("PLEASE USE GCC 6\n\n");
	}
#endif

	long      sat[1];
	if(strictaliasingtest((short *)sat, sat))
	{
		printf("Warning! This build may produce wrong results or even crash!\n");
		printf("Please use the -fno-strict-aliasing compiler option!\n\n");
	}

	rpc_user = strdup("");
	rpc_pass = strdup("");

	for(int i = 0; i < MAX_GPUS; i++)
		device_pstate[i] = -1;

	// number of cpus for thread affinity
#if defined(WIN32)
	SYSTEM_INFO sysinfo;
	GetSystemInfo(&sysinfo);
	num_cpus = sysinfo.dwNumberOfProcessors;
#elif defined(_SC_NPROCESSORS_CONF)
	num_cpus = sysconf(_SC_NPROCESSORS_CONF);
#elif defined(CTL_HW) && defined(HW_NCPU)
	int req[] = { CTL_HW, HW_NCPU };
	size_t len = sizeof(num_cpus);
	sysc tl(req, 2, &num_cpus, &len, NULL, 0);
#else
	num_cpus = 1;
#endif
	// number of gpus
	active_gpus = cuda_num_devices();

	// default thread to device map
	for(i = 0; i < MAX_GPUS; i++)
	{
		device_map[i] = i;
	}

	for(int i = 0; i < active_gpus; i++)
	{
		int dev_id = device_map[i];
		cudaError_t err;
		cudaDeviceProp props;
		err = cudaGetDeviceProperties(&props, dev_id);
		if(err != cudaSuccess)
		{
			applog(LOG_ERR, "%s", cudaGetErrorString(err));
			exit(1);
		}
		device_name[dev_id] = strdup(props.name);
	}

	/* parse command line */
	parse_cmdline(argc, argv);
	if(opt_algo == ALGO_INVALID)
	{
		applog(LOG_ERR, "Error: no algo or invalid algo");
		exit(EXIT_FAILURE);
	}

	if(!opt_n_threads)
		opt_n_threads = active_gpus;

	cuda_get_device_sm();

	if(opt_protocol)
	{
		curl_version_info_data *info;

		info = curl_version_info(CURLVERSION_NOW);
		applog(LOG_DEBUG, "using libcurl %s", info->version);
		int features = info->features;
		if(features&CURL_VERSION_IPV6)
			applog(LOG_DEBUG, "libcurl supports IPv6");
		if(features&CURL_VERSION_SSL)
			applog(LOG_DEBUG, "libcurl supports SSL");
		if(features&CURL_VERSION_IDN)
			applog(LOG_DEBUG, "libcurl supports international domain names");
	}
	if(!opt_benchmark && !rpc_url)
	{
		fprintf(stderr, "%s: no URL supplied\n", argv[0]);
		show_usage_and_exit(1);
	}

	if(!rpc_userpass)
	{
		rpc_userpass = (char*)malloc(strlen(rpc_user) + strlen(rpc_pass) + 2);
		if(rpc_userpass == NULL)
		{
			applog(LOG_ERR, "Out of memory!");
			proper_exit(2);
		}
		sprintf(rpc_userpass, "%s:%s", rpc_user, rpc_pass);
	}

	/* init stratum data.. */
	memset(&stratum.url, 0, sizeof(stratum));

	pthread_mutex_init(&stratum.sock_lock, NULL);
	pthread_mutex_init(&stratum.work_lock, NULL);

	if(curl_global_init(CURL_GLOBAL_ALL))
	{
		applog(LOG_ERR, "CURL initialization failed");
		return 1;
	}

	if(opt_background)
	{
#ifndef WIN32
		i = fork();
		if(i < 0) proper_exit(EXIT_FAILURE);
		if(i > 0) proper_exit(EXIT_FAILURE);
		i = setsid();
		if(i < 0)
			applog(LOG_ERR, "setsid() failed (errno = %d)", errno);
		i = chdir("/");
		if(i < 0)
			applog(LOG_ERR, "chdir() failed (errno = %d)", errno);
		signal(SIGHUP, signal_handler);
		signal(SIGTERM, signal_handler);
#else
		HWND hcon = GetConsoleWindow();
		if(hcon)
		{
			// this method also hide parent command line window
			ShowWindow(hcon, SW_HIDE);
		}
		else
		{
			HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
			CloseHandle(h);
			FreeConsole();
		}
#endif
	}

#ifdef WIN32
	SetConsoleCtrlHandler((PHANDLER_ROUTINE)ConsoleHandler, TRUE);
	if(opt_priority > 0)
	{
		DWORD prio = NORMAL_PRIORITY_CLASS;
		//		SetPriorityClass(NULL, prio);
		switch(opt_priority)
		{
		case 1:
			prio = BELOW_NORMAL_PRIORITY_CLASS;
			break;
		case 3:
			prio = ABOVE_NORMAL_PRIORITY_CLASS;
			break;
		case 4:
			prio = HIGH_PRIORITY_CLASS;
			break;
		case 5:
			prio = REALTIME_PRIORITY_CLASS;
		}
		if(SetPriorityClass(GetCurrentProcess(), prio) == 0)
		{
			LPSTR messageBuffer = nullptr;
			size_t size = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
										NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPSTR)&messageBuffer, 0, NULL);
			applog(LOG_ERR, "Error while trying to set the priority:");
			applog(LOG_ERR, "%s", messageBuffer);
			LocalFree(messageBuffer);
		}
		prio = GetPriorityClass(GetCurrentProcess());
		switch(prio)
		{
		case NORMAL_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "normal");
			break;
		case BELOW_NORMAL_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "below normal");
			break;
		case ABOVE_NORMAL_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "above normal");
			break;
		case HIGH_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "high");
			break;
		case REALTIME_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "realtime");
			break;
		case IDLE_PRIORITY_CLASS:
			applog(LOG_INFO, "CPU priority: %s", "idle");
			break;
		default:
			applog(LOG_INFO, "CPU priority class: %d", prio);
		}
	}
#endif
	if(opt_affinity != -1)
	{
		if(!opt_quiet)
			applog(LOG_DEBUG, "Binding process to cpu mask %x", opt_affinity);
		affine_to_cpu_mask(-1, opt_affinity);
	}

#ifdef HAVE_SYSLOG_H
	if(use_syslog)
		openlog(opt_syslog_pfx, LOG_PID, LOG_USER);
#endif

	work_restart = (struct work_restart *)calloc(opt_n_threads, sizeof(*work_restart));
	if(work_restart == NULL)
	{
		applog(LOG_ERR, "Out of memory!");
		proper_exit(2);
	}

	thr_info = (struct thr_info *)calloc(opt_n_threads + 4, sizeof(*thr));
	if(!thr_info)
		return 1;

	/* init workio thread info */
	work_thr_id = opt_n_threads;
	thr = &thr_info[work_thr_id];
	thr->id = work_thr_id;
	thr->q = tq_new();
	if(!thr->q)
		return 1;

	for(int i = 0; i < MAX_GPUS; i++)
		mining_has_stopped[i] = true;

#ifdef WIN32
	timeBeginPeriod(1); // enable high timer precision
#endif

	/* start work I/O thread */
	if(pthread_create(&thr->pth, NULL, workio_thread, thr))
	{
		applog(LOG_ERR, "workio thread create failed");
		return 1;
	}

	if(want_longpoll && !have_stratum)
	{
		/* init longpoll thread info */
		longpoll_thr_id = opt_n_threads + 1;
		thr = &thr_info[longpoll_thr_id];
		thr->id = longpoll_thr_id;
		thr->q = tq_new();
		if(!thr->q)
			return 1;

		/* start longpoll thread */
		if(unlikely(pthread_create(&thr->pth, NULL, longpoll_thread, thr)))
		{
			applog(LOG_ERR, "longpoll thread create failed");
			return 1;
		}
	}

	if(want_stratum)
	{
		/* init stratum thread info */
		stratum_thr_id = opt_n_threads + 2;
		thr = &thr_info[stratum_thr_id];
		thr->id = stratum_thr_id;
		thr->q = tq_new();
		if(!thr->q)
			return 1;

		/* start stratum thread */
		if(unlikely(pthread_create(&thr->pth, NULL, stratum_thread, thr)))
		{
			applog(LOG_ERR, "stratum thread create failed");
			return 1;
		}

		if(have_stratum)
			tq_push(thr_info[stratum_thr_id].q, strdup(rpc_url));
	}


#ifdef __linux__
	if(need_nvsettings)
	{
		if(nvs_init() < 0)
			need_nvsettings = false;
	}
#endif

#ifdef USE_WRAPNVML
#if defined(__linux__) || defined(_WIN64)
	/* nvml is currently not the best choice on Windows (only in x64) */
	hnvml = nvml_create();
	if(hnvml)
	{
		bool gpu_reinit = (opt_cudaschedule >= 0); //false
		cuda_devicenames(); // refresh gpu vendor name
		if(!opt_quiet)
			applog(LOG_INFO, "NVML GPU monitoring enabled.");
		for(int n = 0; n < active_gpus; n++)
		{
			if(nvml_set_pstate(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if(nvml_set_plimit(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if(!is_windows() && nvml_set_clocks(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if(gpu_reinit)
			{
				cuda_reset_device(n, NULL);
			}
		}
	}
#endif
#ifdef WIN32
	if(nvapi_init() == 0)
	{
		if(!opt_quiet)
			applog(LOG_INFO, "NVAPI GPU monitoring enabled.");
		if(!hnvml)
		{
			cuda_devicenames(); // refresh gpu vendor name
		}
		nvapi_init_settings();
	}
#endif
	else if(!hnvml && !opt_quiet)
		applog(LOG_INFO, "GPU monitoring is not available.");

	// force reinit to set default device flags
	if(opt_cudaschedule >= 0 && !hnvml)
	{
		for(int n = 0; n < active_gpus; n++)
		{
			cuda_reset_device(n, NULL);
		}
	}
#endif

	if(opt_api_listen)
	{
		/* api thread */
		api_thr_id = opt_n_threads + 3;
		thr = &thr_info[api_thr_id];
		thr->id = api_thr_id;
		thr->q = tq_new();
		if(!thr->q)
			return 1;

		/* start stratum thread */
		if(unlikely(pthread_create(&thr->pth, NULL, api_thread, thr)))
		{
			applog(LOG_ERR, "api thread create failed");
			return 1;
		}
	}

	/* start mining threads */
	for(i = 0; i < opt_n_threads; i++)
	{
		thr = &thr_info[i];

		thr->id = i;
		thr->gpu.thr_id = i;
		thr->gpu.gpu_id = (uint8_t)device_map[i];
		thr->gpu.gpu_arch = (uint16_t)device_sm[device_map[i]];
		thr->q = tq_new();
		if(!thr->q)
			return 1;

		if(unlikely(pthread_create(&thr->pth, NULL, miner_thread, thr)))
		{
			applog(LOG_ERR, "thread %d create failed", i);
			return 1;
		}
	}

	applog(LOG_INFO, "%d miner thread%s started, "
		   "using '%s' algorithm.",
		   opt_n_threads, opt_n_threads > 1 ? "s" : "",
		   algo_names[opt_algo]);

	/* main loop - simply wait for workio thread to exit */
	pthread_join(thr_info[work_thr_id].pth, NULL);

	applog(LOG_INFO, "workio thread dead, exiting.");

	proper_exit(0);

	return 0;
}
