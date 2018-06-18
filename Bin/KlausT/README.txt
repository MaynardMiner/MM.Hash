ccMiner release 8.21(KlausT-mod) (March 15th, 2018)
---------------------------------------------------------------

***************************************************************
If you find this tool useful and like to support its continued 
          development, then consider a donation.

KlausT:
  BTC 1QDwdLPrPYSoPqS7pB2kGG84YX6hEcQ4JN
      bc1qpt7qnvjaqu8t24xqajgyfqan2v00hrdgrut0zq
  BCH 1AH1u7B4KtDTUBgmT6NrXyahNEgTac3fL7
      qpjupzv3nevqzlkyxx5d736xt78jvet7usm479kl73

tpruvot:
  BTC 1AJdfCpLWPNoAMDfHF1wD5y8VgKSSTHxPo

DJM34:
  BTC donation address: 1NENYmxwZGHsKFmyjTc5WferTn5VTFb7Ze

cbuchner:
  LTC donation address: LKS1WDKGED647msBQfLBHV3Ls8sveGncnm
  BTC donation address: 16hJF5mceSojnTD3ZTUDqdRhDyPJzoRakM

***************************************************************

>>> Introduction <<<

This is a CUDA accelerated mining application which handle :

Bitcoin
HeavyCoin & MjollnirCoin
FugueCoin
GroestlCoin & Myriad-Groestl
JackpotCoin
QuarkCoin family & AnimeCoin
TalkCoin
DarkCoin and other X11 coins
NEOS blake (256 14-rounds)
BlakeCoin (256 8-rounds)
Deep, Doom and Qubit
Keccak (Maxcoin)
Pentablake (Blake 512 x5)
S3 (OneCoin)
Skein (Skein + SHA)
Lyra2RE (new VertCoin algo)
Neoscrypt

where some of these coins have a VERY NOTABLE nVidia advantage
over competing AMD (OpenCL Only) implementations.

We did not take a big effort on improving usability, so please set
your parameters carefuly.

THIS PROGRAMM IS PROVIDED "AS-IS", USE IT AT YOUR OWN RISK!

If you're interessted and read the source-code, please excuse
that the most of our comments are in german.

>>> Command Line Interface <<<

This code is based on the pooler cpuminer 2.3.2 release and inherits
its command line interface and options.

   -a, --algo=ALGO specify the hash algorithm to use
			bitcoin     Bitcoin
			blake       Blake 256 (SFR/NEOS)
			blakecoin   Fast Blake 256 (8 rounds)
			c11         X11 variant
			deep        Deepcoin
			dmd-gr      Diamond-Groestl
			fresh       Freshcoin (shavite 80)
			fugue256    Fuguecoin
			groestl     Groestlcoin
			jackpot     Jackpot
			keccak      Keccak-256 (Maxcoin)
			luffa       Doomcoin
			lyra2v2     VertCoin
			myr-gr      Myriad-Groestl
            neoscrypt   neoscrypt (FeatherCoin)
			nist5       NIST5 (TalkCoin)
			penta       Pentablake hash (5x Blake 512)
			quark       Quark
			qubit       Qubit
			sia         Siacoin (at pools compatible to siamining.com) 
			skein       Skein SHA2 (Skeincoin)
			s3          S3 (1Coin)
			spread      Spread
			x11         X11 (DarkCoin)
			x13         X13 (MaruCoin)
			x14         X14
			x15         X15
			x17         X17 (peoplecurrency)
			vanilla     Blake 256 8 rounds
			yescrypt    yescrypt
			whirl       Whirlcoin (old whirlpool)
			whirlpoolx  Vanillacoin 
  -d, --devices         Comma separated list of CUDA devices to use. 
                        Device IDs start counting from 0! Alternatively takes
                        string names of your cards like gtx780ti or gt640#2
                        (matching 2nd gt640 in the PC)
  -i  --intensity=N     GPU intensity 8-31 (default: auto) 
                        Decimals are allowed for fine tuning 
  -f, --diff-factor     Divide difficulty by this factor (default 1.0) 
  -m, --diff-multiplier Multiply difficulty by this value (default 1.0) 
  -v, --vote=VOTE       block reward vote (for HeavyCoin)
  -o, --url=URL         URL of mining server
  -O, --userpass=U:P    username:password pair for mining server
  -u, --user=USERNAME   username for mining server
  -p, --pass=PASSWORD   password for mining server
      --cert=FILE       certificate for mining server using SSL
  -x, --proxy=[PROTOCOL://]HOST[:PORT]  connect through a proxy
  -t, --threads=N       number of miner threads (default: number of nVidia GPUs)
  -r, --retries=N       number of times to retry if a network call fails
                          (default: retry indefinitely)
  -R, --retry-pause=N   time to pause between retries, in seconds (default: 30)
  -T, --timeout=N       network timeout, in seconds (default: 270)
  -s, --scantime=N      upper bound on time spent scanning current work when
                        long polling is unavailable, in seconds (default: 5)
  -n, --ndevs           list cuda devices
  -N, --statsavg        number of samples used to display hashrate (default: 30)
      --no-gbt          disable getblocktemplate support (height check in solo)
      --no-longpoll     disable X-Long-Polling support
      --no-stratum      disable X-Stratum support
  -e                    disable extranonce
  -q, --quiet           disable per-thread hashmeter output
      --no-color        disable colored output
  -D, --debug           enable debug output
  -P, --protocol-dump   verbose dump of protocol-level activities
      --cuda-schedule   set CUDA scheduling option:
                        0: BlockingSync (default)
                        1: Spin
                        2: Yield
                        This is influencing the hashing speed and CPU load
      --cpu-affinity    set process affinity to cpu core(s), mask 0x3 for cores 0 and 1
      --cpu-priority    set process priority (default: 0 idle, 2 normal to 5 highest)
  -b, --api-bind        IP/Port for the miner API (example: 127.0.0.1:4068)
      --logfile=filename Create a logfile
  -S, --syslog          use system log for output messages
      --syslog-prefix=... allow to change syslog tool name
  -B, --background      run the miner in the background
      --benchmark       run in offline benchmark mode
      --no-cpu-verify   don't verify the found results
  -c, --config=FILE     load a JSON-format configuration file
      --plimit=N        Set the gpu power limit to N Watt (driver version >=352.21)
                        (needs adminitrator rights under Windows)
  -V, --version         display version information and exit
  -h, --help            display this help text and exit\n"


>>> Examples <<<

Example for Fuguecoin solo-mining with 4 gpu's in your system and a Fuguecoin-wallet running on localhost
    ccminer -q -s 1 -t 4 -a fugue256 -o http://localhost:9089/ -u <<myusername>> -p <<mypassword>>


Example for Fuguecoin pool mining on dwarfpool.com with all your GPUs
    ccminer -q -a fugue256 -o stratum+tcp://erebor.dwarfpool.com:3340/ -u YOURWALLETADDRESS.1 -p YOUREMAILADDRESS


Example for Groestlcoin solo mining
    ccminer -q -s 1 -a groestl -o http://127.0.0.1:1441/ -u USERNAME -p PASSWORD


For solo-mining you typically use -o http://127.0.0.1:xxxx where xxxx represents
the rpcport number specified in your wallet's .conf file and you have to pass the same username
and password with -O (or -u -p) as specified in the wallet config.

The wallet must also be started with the -server option and/or with the server=1 flag in the .conf file


>>> API and Monitoring <<<

With the -b parameter you can open your ccminer to your network, use -b 0.0.0.0:4068 if required.
On windows, setting 0.0.0.0 will ask firewall permissions on the first launch. Its normal.

You can test this api on linux with "telnet <miner-ip> 4068" and type "help" to list the commands.
Default api format is delimited text. If required a php json wrapper is present in api/ folder.

>>> Additional Notes <<<

This code should be running on nVidia GPUs ranging from compute capability
3.0 up to compute capability 7.0. Support for Compute 2.0 has been dropped
so we can more efficiently implement new algorithms using the latest hardware
features.

>>> RELEASE HISTORY <<<

2015-02-01 Release 1.0, forked from tpruvot and sp-hash
2015-02-03 v1.01: bug fix for cards with compute capability 3.0 (untested)
2015-02-09 v1.02: various bug fixes and optimizations
2015-03-08 v2.00: added whirlpoolx algo (Vanillacoin), also various optimizations and bug fixes
2015-03-30 v3.00: added skein (for Myriadcoin for example)
2015-05-06 v4.00: added Neoscrypt
2015-05-15 v4.01: fixed crash after ctrl-c (Windows), fixed -g option
2015-07-06 v5.00: -g option removed, some bug fixes and optimizations
2015-07-08 v5.01: lyra2 optimization
2015-08-22 v6.00: remove Lyra2RE, add Lyra2REv2, remove Animecoin, remove yesscrypt
2016-05-03 v6.01: various bug fixes and optimizations
2016-05-12 v6.02: faster x17 and quark
2016-05-16 v7.00: added Vanillacoin, optimized blake and blakecoin,
                  added stratum methods used by yiimp.ccminer.org
2016-05-16 v7.01: stratum.get_stats bug fix
2016-06-02 v7.02: fix default intensity for Nist5
                  fix power usage statistics
2016-06-11 v7.03: faster lyra2v2
2016-06-18 v7.04: Neoscrypt optimization
                  Bug Fixes 
2016-08-11 v8.00: added Siacoin
2016-08-12 v8.01: increse default intensity for Sia
                  fix Linux build
2016-09-29 v8.02: change to CUDA 8.0 on Windows
                  various small changes
2016-12-08 v8.03: fix memory leak in Neoscrypt
2016-12-13 v8.04: fix illegal memory access in X11-X17
                  fix duplicate shares in skein
2016-12-17 v8.05: fix Skein bug
2017-03-12 v8.06: Heavy and Mjollnir algos removed
2017-05-18 v8.07: Bitcredit algo removed
                  fixed bugs in bitcoin and jackpot algo
2017-05-19 v8.08: fix Makefile and configure.ac for Linux
2017-06-07 v8.09: some minor bug fixes
2017-07-17 v8.10: fix Orbitcoin solo mining (Neoscrypt)
2017-07-25 v8.11: change some timeout values
                  fix Feathercoin solo mining (Neoscrypt)
                  show chance to find a block while solo mining
2017-08-17 v8.12: fix Myriad-Groestl speed bug
2017-08-26 v8.13: fix retry bug
                  faster neoscrypt for 1080/1080Ti
2017-11-07 v8.14: faster Neoscrypt for Titan Xp
                  fix bug that prevented a reconnect after a connection loss
2017-11-21 v8.15: support up to 16 GPUs
                  fix problem with not exiting when there's an error
2017-12-15 v8.16: add sm_71 (Titan cards) (CUDA 9 and newer versions)
2017-12-21 v8.17: fix possible problem with high intensities
                  fix bug in -d option
                  fix Linux build
2018-01-01 v8.18: more speed for Titan V with Lyra2v2 and possibly neoscrypt (untested)
                  Linux: better default intensity
                  some small bug fixes
2018-01-23 v8.19: fix x17 for Linux builds without NVML
                  show default intensity when not using the -i option
                  add gpu number to the cuda error messages
                  stratum: show reason of auth failure (when supported by the pool)
                  API is now disabled by default
                  Neoscrypt: Titan Xp fix
                  Windows: fix --background option
                  fixed: send a second share when we find it
                  enable stale share detection
                  send stale shares when the pool supports it
2018-02-03 v8.20: fix crash when using options --ndevs or --help
                  API: fix possible crash when checking cpu frequency under Linux
                  fix gpu name bug when using different cards in the same system
                  add some error messages
2018-03-15 v8.21: add option --cuda-schedule
                  add option --logfile
                  make ccminer compilable under OSX
                  Neoscrypt: detect  P104-100 and Tesla P100/V100
                  Linux: fix Lyra2v2 verification bug
                  fix for intensities between 8 and 9

>>> AUTHORS <<<

Notable contributors to this application are:

Christian Buchner, Christian H. (Germany): Initial CUDA implementation

djm34, tsiv, sp and KlausT for cuda algos implementation and optimisation

Tanguy Pruvot : 750Ti tuning, blake, colors, general code cleanup/opts
                API monitoring, linux Config/Makefile and vstudio stuff...

and also many thanks to anyone else who contributed to the original
cpuminer application (Jeff Garzik, pooler), it's original HVC-fork
and the HVC-fork available at hvc.1gh.com

Source code is included to satisfy GNU GPL V3 requirements.
