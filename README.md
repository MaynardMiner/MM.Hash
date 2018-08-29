**MM.Hash**

**Profit Switching Miner For HiveOS & Windows.**

MM.Hash is a powershell/bash hyrbid miner that is meant to work in both windows and HiveOS mining systems. It has the capability of switching between mutliple pools, and multiple algorithms, as well as calucating the most profitable algorithm to mine. It can also perform coin profit switching as well, on pools that can do so. MM.Hash fully integrates with HiveOS, sending stats directly to HiveOS with little/no issues. It accepts remote commands, and can be updated remotely as well. The HiveOS version means you can use all the features of HiveOS, including hashrate monitoring, possible GPU failure detection, miner configuration, all while doing it remotely.

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
aeriumx
polytimos
hex
sonoa
equihash96
equihash192
equihash144xsg
equihash144btcz
equihash144zel
equihash-BTG
equihash144safe
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
EWBF
JayDDee
```

Simple Install Instructions (HIVEOS):

Use ```gparted``` to expand your HiveOS partition to maximum size. MM.Hash requires at least 1 gb of data extra to download all miner files, and store logs. ```gparted``` is very easy to use. Should take 30 seconds. Do not use ```gparted``` or attempt to install ```gparted``` in the initial loading screen. You have to righ click >>> ```terminal emulator``` and use that window.

```sudo apt-get install gparted```

To Run:

```gparted```

This is an example of how to remote install/update miner. It is the fastest way to get going. Simply enter tar.gz file name from latest release. Then insert link for tar.gz. Lastly, your setup arguments go in the last box, labeled extra config <a href="https://github.com/MaynardMiner/MM.Hash/wiki/Arguments-(Miner-Configuration)">arguments</a>. After that, you are are good to go! See wiki on proper argument use. Here is a photo of setup:

![alt text](https://raw.githubusercontent.com/MaynardMiner/MM.Hash/master/Build/Data/First_Step.png)


![alt text](https://raw.githubusercontent.com/MaynardMiner/MM.Hash/master/Build/Data/Second_Step.png)

**Note**

You may need to Rocket Launch/Reboot in order to have Agent restart and start recieving data from MM.Hash

**Known Issues**

-Algorithms: Since HiveOS 2.0 update, algorithms are slow to show on HiveOS website. ```agent``` is clearly sending the algo, but it registers on HiveOS at a severe delay, messing up the stats on HiveOS. This is has been occurring since HiveOS 2.0, and it is website related. It cannot be fixed on my end.

-AMD: AMD miner are new to MM.Hash as of 1.4.0b. The dev isn't familiar with AMD, but is trying to learn quickly to get more miners and settings correct. Currently AMD is at a beta-level. If you use AMD or are familiar with AMD and want to see more developed- Please beta-test, join discord, and offer suggestions on miners/settings/improvements.

**CONTACT**

Discord Channel For MM.Hash- 
https://discord.gg/5YXE6cu

**DONATE TO SUPPORT!**

BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i

RVN RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H

Special Thanks To Discord Users:
Alexander
Stoogie
GravityMaster
Zirillian

For their help pointing out bugs and issues, and helping to keep program running well.

Thanks To:

Sniffdog

Nemosminer

Uselessguru

Aaronsace

They were the pioneers to powershell scriptmining. Their scripts helped me to piece together a buggy but workable linux miner, which was the original purpose of MM.Hash, since none of them did so at the time. Since then it has grown to what it is today.

