**MM.Hash**

**Profit Switching Miner For HiveOS & Windows.** [![GitHub version](https://badge.fury.io/gh/MaynardMiner%2FMM.Hash.svg)](https://badge.fury.io/gh/MaynardMiner%2FMM.Hash)

MM.Hash is a powershell/bash hybrid miner that is meant to work in both windows and HiveOS mining systems. It has the capability of switching between mutliple pools, and multiple algorithms, as well as calucating the most profitable algorithm to mine. It can also perform coin profit switching as well, on pools that can do so. MM.Hash fully integrates with HiveOS, sending stats directly to HiveOS with little/no issues. It accepts remote commands, and can be updated remotely as well. The HiveOS version means you can use all the features of HiveOS, including hashrate monitoring, possible GPU failure detection, miner configuration, all while doing it remotely.

**Important**

MM.Hash is schedule to updates almost daily/weekly, due to the violitiliy of mining, and mining trends. I highly encourage users that are interested to join the discord channel:

https://discord.gg/5YXE6cu

**Features**

-Backs up initial benchmarks, making updating or recovery a charm.

-Shows real time hashrates from miners, along with previous hashrates.

-HiveOS full integration.

-Displays close to real-time monitoring, directly from miners to HiveOS website. Allows for HiveOS monitoring and graph data.

-Every part of the code has a double-checking feature, to ensure real time monitoring.

-More hard drive integration, less storage on RAM.

-Latest miners, updated frequently.

-Windows Miners Cuda 9.2

-HiveOS Miners Cuda 9.1, including miners which github can no longer compile.

-HiveOS commands to open new windows to view stats, miner history, real-time data.

-Coin profit switching. (Not recommended on slower rigs/usb)

-Algorithm profit switching.

-Miner notifies users of benchmarking timeouts

-Easy to setup.

-HiveOS version is dedicated to creating a solid environment that corrects itself if mistakes are made.

-Hashrates monitoring via logging for miners that require it.

-New miners than HiveOS.

-Strong support via discord. Users with rig setups of 100s of GPU's are using and troubleshooting as updates are released.



**Algorithms** (As defined and required by miners)

```
nist5
blake2s
skein
ethash
daggerhashimoto
lyra2v2
lyra2z
phi2
allium
equihash
x16r
x16s
aeriumx (aergo)
equihash192
equihash144
yescrypt
yescryptR16
m7m
cryptonightv7
lyra2re
hodl
neoscrypt
groestl
xevan
bitcore
hmq1725
timetravel
x17
keccak
blakecoin
skunk
keccakc
x12
sib
tribus
phi
c11
hsr
```


**Pools**
```
nicehash
miningpoolhub (mph)
zergpool_coin
zergpool_algo
blockmasters
starpool
ahashpool
blazepool
hashrefinery
phiphipool
zpool
```

**Miners**
```
CryptoDredge
Alexis78
MSFT
Krnlx
OCminer/suprminer
Tpruvot
T-rex
Enemy
Claymore
Dstm
EWBF (new version)
JayDDee
```

Simple Install Instructions (HIVEOS):

Use ```gparted``` to expand your HiveOS partition to maximum size. MM.Hash requires at least 1 gb of data extra to download all miner files, and store logs. ```gparted``` is very easy to use. Should take 30 seconds. Do not use ```gparted``` or attempt to install ```gparted``` in the initial loading screen. You have to righ click >>> ```terminal emulator``` and use that window.

```sudo apt-get install gparted```

To Run:

```gparted```

This is an example of how to remote install/update miner. It is the fastest way to get going. Simply enter tar.gz file name from latest release. Then insert link for tar.gz. Lastly, your setup arguments go in the last box, labeled extra config <a href="https://github.com/MaynardMiner/MM.Hash/wiki/Arguments-(Miner-Configuration)">arguments</a>. After that, you are are good to go! See wiki on proper argument use. Here is a photo of setup:

![alt text](https://raw.githubusercontent.com/MaynardMiner/MM.Hash/master/Build/Data/Setup.png)


**Known Issues**

-T-Rex miner API does not work in Unix. In order to attain hashrates, MM.Hash must read data from logs. This creates a small latency between MM.Hash and T-Rex. It cannot be avoided. Please contact/bribe developer and inform him you wish a working API version for Unix. There has been other issues in particular with T-Rex regarding hashrates. For the most part, however- It works most of the time. If you experience issues, the only thing that can be done is to reboot, which will clear logs.

-Autofan: HiveOS considers MM.Hash as a single miner. Therefor when MM.Hash switches to another miner, HiveOS may occasionally take a min. to switch to the API of the new miner in question. Occasionally this causes the error due to the fact that HiveOS didn't realize the miner switched. It a latency issues between HiveOS and MM.Hash. It cannot be corrected.



**CONTACT**

Discord Channel For MM.Hash- 
https://discord.gg/5YXE6cu

**DONATE TO SUPPORT!**

BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i

RVN RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H

Thanks To:

Sniffdog

Nemosminer

Uselessguru

Aaronsace

They were the pioneers to powershell scriptmining. Their scripts helped me to piece together a buggy but workable linux miner, which was the original purpose of MM.Hash, since none of them did so at the time. Since then it has grown to what it is today.
