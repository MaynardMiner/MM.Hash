**MM.Hash**

**MULTI-ALGO, MULTI-POOL, MULTI-DEVICE, MULTI-COIN, AUTO-PROFIT SWITCHING MINING ADMINISTRATION APPLICATION FOR UNIX & WINDOWS SYSTEMS.**

This is a new mining concept which combines Auto-Algo & Auto-Coin Switching simultaneuosly. It also has a Linux version, which is new as well as far as script miners. Both of these items are constantly being developed, and MM.Hash is but a fraction of what it can currently has the potential to be- The process can only move so fast as realtime testing is required with each new feature/implementation. Join discord by following link at bottom to be a part of the development process.

NOTE- MM.HASH works for windows. Edit .Bat files and run the various scripts that come in MM.Hash to use. Will write more documentation on uses and support as I finish final 1.1.9-Full.

MM.Hash is intended to be Unix/Windows mining application, which will mine from NVIDIA GPU, AMD GPU, CPU devices. AMD is built into the code, but at this time I do NOT have any miners or settings loaded into MM.Hash. I am working on it- I don't own any AMD devices. The program is based off of various powershell mining applications available in Windows, in which I have used to invent a new way to mine. I made the base script fully compatible with UNIX, and then added UNIX specific features along with many other changes. After requests from users- I decided to make a Windows version.

The uses for MM.Hash- is pretty vast, being that it works in linux/unix environment. Hypothetically, with the right setup- MM.Hash can work in any device that can boot UNIX or Windows.

MM.Hash works by utlizing Powershell, which is now a cross-platform software that is constantly being developed. It will query the API of any pool you have your "Pools" folder, and get the current prices of the coins/algorithms you have chosen. Once it has gathered that data, it will then select the most profitable, and choose the best mining application to mine with, which are denoted as separate .ps1 filed in the "Miners" folder. If you have never used that particular miner before- MM.Hash will go into benchmark mode, which will record your hashrate. This means you can test miners to see which gives you the best hashrate! If MM.Hash detects the coin yields little/no value from mining- it will remove the miner from its list.

Spend the extra dollar and get a USB 3.0 Stick: 16GB if you plan to try to build USB miner. I highly reccomend not using usb 2.0...It works, but takes forever to build.

IF YOU WANT TO SEE FURTHER DEVELOPMENT- PLEASE LEAVE DONATION SET & CONSIDER DONATING TO DEVELOPER!

DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i

**UNIX Dependencies**
This is what you need to run/dependencies. It is essentially everything you need to compile ccminers, powershell, as well as a script editor to edit starting script file:
```
libcurl4-openssl-dev
libssl-dev
libjansson-dev
automake
autotools-dev
build-essential
libgmp3-dev
curl
libunwind8
gcc-5 g++-5 (and set as default  
libicu55_55.1-7ubuntu0.4_amd64.deb
powershell
nvidia-396
cuda 9.12toolkit
vim/nano
xterm
p7zip-full
reccommended- NVCLOCK setup for overclocking and fan speed increase.
```

It requires xterm, so you will need some form of a display manager. I reccommend and use lightdm.

**ADVANCED SETTINGS**

Advanced Settings allow you to control multiple GPU devices in groups, and you are able to set each group with an individual wallet- Meaning you can auto-exchange mine for different coins at the same time (up to 8). To use- First consult the Help file located in the MM.Hash directory. It gives a full list of all arguments, as well as detailed explanations of their use. I wrote a seperate Devices paramaters for those who have larger mining systems, as I know it can be tedious to set them up.

IMPORTANT: ENSURE POOL OFFERS EXCHANGE TO YOUR COIN SELECTED IN WALLET ADDRESS!

**STARTING THE MINER (UNIX)**

Naviagate to MM.Hash directory and open this file:
```
vi ./StartMM.Coin
```
Edit with your wallet information. File is written with the most basic settings needed to run miner. See help file for additional settings as well as how to further customize.

**Windows**

Edit the StartMM.bat with your wallet information. File is written with the most basic settings needed to run miner. There is also a .bat file for nicehash and cpu. You can add arguments to the file, see the Help.txt in order to see full argument list and setttings.

If you are running on a very slow drive- it may look like the screen has frozen, but it takes awhile to start the configure process to build. If the miner doesn't continue to the main screen, you can simple ctrl+c to close miner, delete the newly created "Bin" folder, re-clone then try and run MM.Hash again. If a miner fails to install- either your gpu settings/install are not correct, you are missing a dependency. The Unix version of MM.Hash clones the actual code source directly from github, configures, and builds the miner into an executable program where it is needed to do so. This process can take awhile.

GIT THAT LAMBO!


**OPTIMIZATIONS**

By opening mining files, you can optimize miners by adding arguments under the aglo in the mining file. For example- If you wanted to mine x16r with and gpu intensity of 21, you would amend x16r in the optimizations section to = "-i 21". It can accept any argument the miner being used would normally accept. This includes API settings, if required.


**MAITENENCE/Issues**

-Do to the instability of coins, miner will constantly shut-off coins, and set hashrate to zero. This originally made benchmarking tedious. Also, if a coin was disabled while you were mining, or autotrade was removed- The miner would detect no hashrate, and set coin to zero. To solve this- I implemented a timeout system. It notifies user of when the miner sets a hashrate to 0 because of issues by setting a **Coin**_TIMEOUT.txt file in your backup folder. This allows miner to continue mining. After benchmarking, it is good to check if there is timeouts there, and use that to solve issues with the mining application/settings individually. When you wish to reset all files in your Stats and Backup folder that were set to 0: I made a script to do so:

```
sudo bash Reset.Timeouts
```

-If you wish to reset all your benchmark stats- type the following while in MM.Hash Apps directory:

```
sudo bash ClearProfits.sh
```

-If you wish to remove the benchmark of a particular miner/algo- delete its "hashrate".txt file. If you want to reset all benchmarks, use:

```
sudo bash ResetBenchmarks.sh
```

-If you wish to clear your Logs

```
sudo bash RemoveLogs.sh
```

-If you wish to track your wallet, navigate to Apps directory and type:

```
vi Wallet_Tracker.sh
```
Then edit with your wallet and pool. When finished save and exit and then type:
```
sudo bash Wallet_Tracker.sh
```

Navigating to the Miner files, and opening them with vi lets you configure miners. Putting a # turns off algo/coin, removing # turns them on. Optimizations are added to the command line, so if you wish to increase its intensity for example, add -i [intensity] between the "" of the algo.
-You can add/edit miner files while miner is running. JUST MAKE SURE THEY ARE CORRECT BEFORE SAVING!
-There is a Logs folder which lets you track MM.Hash's history
-If you have issues installing a miner- delete .zip or 7z file from the Downloads folder & the new miner from the bin folder. Try it again. Ensure you have moved the mini builder.sh script to the /bin folder and have enabled it as an executable.

Open DevNotes.txt to see other notes on using MM.Hash, along with new changes, and future changes.

CONTACT

Discord Channel For MM.Hash- 
https://discord.gg/xVB5MqR

DONATE TO SUPPORT!

DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i
DONATION ADDRESS: RVN RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H

Thanks To:

Sniffdog
Nemosminer
Uselessguru

They were the pioneers to powershell scriptmining. Their scripts helped me to piece together a buggy but workable linux miner, which was the original purpose of MM.Hash, since none of them did so at the time. Since then it has grown to what it is today.
