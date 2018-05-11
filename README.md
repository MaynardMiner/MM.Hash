# MM.Hash
#
#
#DEVELOPER-NOTE: THIS PRODUCT IS IN BETA TESTING- BUG REPORTS ARE HELPFULL.
#
#
#MM.Hash is intended to be Unix/Linux Multi-Algo, Multi-Coin, Multi-Device, Multi-Pool Mining application, which will mine from NVIDIA GPU, AMD GPU, CPU, and eventually Hard Disk Drive (Lowest on the list to get done). Its based design is a heavily modified fork multi-miner known as SniffDogMiner, but currently does not support Linux/Unix systems. You can find the original Windows version here: https://github.com/Sniffdog/Sniffdogminer. Currently I do not intend to build a Windows version, as SniffDogMiner is excellent and always updated. I highly recommend if you prefer mining in Windows, to check it out.
#
#The uses for MM.Hash- is pretty vast, being that it works in linux/unix environment. Hypothetically, with the right setup- MM.Hash can work in any device that can boot linux. This means you can mine from your PS4, Tablet, PC, Microcontrollers, etc. when are not using them, and you are not losing the massive hashrate from browser mining/and or further fees you do not know if you are or aren't paying. Furthermore- you can do this all through building a minimal Ubuntu OS, and load directly off a USB!
#
#MM.Hash works by utlizing Powershell, which is now a cross-platform software that is constantly being developed. It will query the API of any pool you have your "Pools" folder, and get the current prices of the coins of the algorithms you have chose. Once it has gathered that data, it will then select the most profitable, and choose the best mining application to mine with, which are denoted as separate .ps1 filed in the "Miners" folder. If you have never used that particular miner before- MM.Hash will go into benchmark mode, which will record your hashrate. This means you can test miners to see which gives you the best hashrate! If MM.Hash detects the coin yields little/no value from mining- it will remove the miner from its list.
#
#I originally built the mining application on a Linux VM, and did extensive testing and debugging. Currently this is not the full release of the miner- I am simply releasing it to demonstrate and give users the ability to play with the initial design. Right now, I have only built miner files for NVIDIA & CPU, but I will build more miner files along the way.
#
#So Far I have been able to build the miner on an Ubuntu Minimal installation, and have tested on USB-Stick. This means you can run MM.Hash directly off a flash drive.
#
#IF YOU WANT TO SEE FURTHER DEVELOPMENT- PLEASE LEAVE DONATION SET & CONSIDER DONATING TO DEVELOPER!
#
#DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i
#
#BUILDING UBUNTU MINI/INSTALL
#
#Building the Ubuntu mini (NVIDIA SETUP AS EXAMPLE)
#
sudo apt install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings openbox obconf obmenu wicd ubuntu-drivers-common mesa-utils mesa-utils-extra compton xorg xserver-xorg nautilus gnome-terminal
#
sudo apt-get install gcc-5 g++-5
#
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1
#
sudo apt-get update
#
sudo apt-get purge nvidia* 
#
sudo apt-get install software-properties-common python-software-properties
#
sudo add-apt-repository ppa:graphics-drivers/ppa
#
sudo apt-get update
#
sudo apt-get install nvidia-390
#
sudo apt-mark hold nvidia-390
#
wget https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda-repo-ubuntu1704-9-1-local_9.1.85-1_amd64
#
sudo dpkg -i cuda-repo-ubuntu1704-9-1-local_9.1.85-1_amd64.deb
#
sudo apt-key add /var/cuda-repo-<version>/7fa2af80.pub
#
sudo apt-get update
#
sudo apt-get install cuda
#
#Navigate To Xorg Config Folder
#
cd /
#
cd /etc/X11
#
sudo xvidia-xonfig
#
#Recommended Overclock Settings: +100 Core +1000 Memory, Fan Speed 70% (Fan State Locked), Max-Temp 70C (Has been pretty stable for me- Some Algos are pretty power hungry, bare in mind crashes likely result from not enough power...If you experience crashing issues, try turning maximum watts down on cards, and see if it performs better). Advise to set persistance power state to ON, and ensure each card is set to its maximum performance level. I'm not going to write out how to do that, because it really varies between your preferences, and what model card you are using. 
#
#
#
#CCMINER
#
sudo apt-get install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential
#
sudo apt-get install libgmp3-dev
#
sudo apt-get install curl
#
#
#
#POWERSHELL
#
sudo apt-get install libunwind8
#
wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb
#
sudo dpkg -i powershell_6.0.0-1.ubuntu.17.04_amd64.deb
#
sudo apt-get install -f
#
#
#
#MM.Hash DEPENDENCIES (NEED IN ORDER TO FUNCTION/OPERATE/INSTALL)
#
sudo apt-get install vim
#
sudo apt-get install xterm
#
sudo apt-get install p7zip-full
#
sudo apt-get install git
#
#
#
#GITHUB LINK
#
git clone https://github.com/MaynardMiner/MM.Hash.git
#
#
#
#SETUP
#
#Make Configuration File executable:
#
chmod +x StartMM
#
#CONFIGURATION
#
#Open StartMM:
#
vi ./StartMM
#
#There is a list of options, with simple explanations as to how they work. As I build miner, I will eventually open a wiki on detailed function, but they are pretty easy to understand if you are aware how mining works. Be sure to leave all '' and "" in each parameter where applicable! Basic edit commands: "i" lets you insert/edit file "esc" takes you to vi menu. While in vi menu, type :x to save, :q to quit. If you are new to mining- It would probably be good at looking at CCminer setup articles to understand the principle operation, as well as browsing some of the pool sites listed in the pools folder. If you do not have a large mining setup- I would highly reccomend using on one or two pools, or it will take a very long time to recieve your mining rewards. This is because of the pools themselves- It is out of my control.
#
#Ideal font size for gnome-terminal to show good display is 10pts. Edit - Profile Preferences - Custom Font. Reccommend changing before starting! Also it's a good idea to run at full screen, and change the layer terminal settings to "Always on Bottom" so when you click on it- the mining windows do not disappear behind the terminal.
#
#
#
#ADVANCED SETTINGS
#
#Advanced Settings allow you to control multiple GPU devices in groups, and you are able to set each group with an individual wallet- Meaning you can mine for different coins at the same time. To use- You first must swap Type Parameter- You do this by placing # in front of Type in "Normal Settings" and removing the # in front the time in the Advanced configuration. Type allows you declare which groups are active. You must add a numerical value behind each device you are using, starting with "1", i.e. 
#
Type=NVIDIA1,NVIDIA2 (You can still use CPU, but no CPU1,CPU2,CPU3 (There is no support for multi-cpu). Just use CPU.)
#
#The next step is setting up each group. GPUDevices correspond to the numerical value set of the device type. If you are using NVIDIA1, you must remove the # in front of the GPUDevices1, Wallet1, and PasswordCurrency1 parameters to make them active. It is important you keep all "" and '' or '""' where present! Set your wallet, and the corresponding coin symbol. Once you have set all your devices- You must go down to the Command section, and find the # between advanced commands. First you must delete the " in front of the # in order to extend the command. Then you must remove the # sign, and either delete it if you are using all 8 groups, or move it in front of the first group you are not using. Lastly, you must add the " that you have removed at the last character of the command line that you are now using.
#
#IMPORTANT: ENSURE POOL OFFERS EXCHANGE TO YOUR COIN SELECTED IN WALLET ADDRESS!
#
#
#
#STARTING THE MINER
#
#Naviagate to MM.Hash directory and run this command:
#
./StartMM
#
#Miner will start! It takes a little bit for the miner to download and install and miners you want to use. If you are running on a very slow drive- it may look like the screen has frozen, but it takes awhile to start the configure process to build. If the miner doesn't continue to the main screen, you can simple ctrl+c to close miner, delete the newly created "Bin" folder, re-clone then try and run MM.Hash again. If a miner fails to install- either your gpu settings/install are not correct, you are missing a dependency, or the owner of the miner recently committed to his code, and there was issues. MM.Hash pull the actual code source directly from github, configures, and builds the miner into an executable program! Currently it only has the capabilities to do this to the programs in which their source code is open to download. Because of this- I have included some already ready-to-run mining application in the Bin folder.
#
#GIT THAT LAMBO!
#
#
#OPTIMIZATIONS
#
#By opening mining files, you can optimize miners by adding arguments under the aglo in the mining file. For example- If you wanted to mine x16r with and gpu intensity of 21, you would amend x16r in the optimizations section to = "-i 21". It can accept any argument the miner being used would normally accept. This includes API settings, if required.
#
#
#
#MAITENENCE/Issues
#
#-If you wish to reset all your stats- Simple delet the Stats folder, and start MM.Hash. You can do this while it is running.
#-If you wish to remove the benchmark of a particular miner/algo- delete its "hashrate".txt file. It will tell it to benchmark it again- You can do this while it is running.
#Navigating to the Miner files, and opening them with vi lets you configure miners. Putting a # turns off algo, removing # turns them on. Optimizations are added to the command line, so if you wish to increase its intensity for example, add -i [intensity] between the "" of the algo.
#-You can add/edit miner files while miner is running. JUST MAKE SURE THEY ARE CORRECT BEFORE SAVING!
#-There is a Logs folder which lets you track MM.Hash's history
#-If you have issues installing a miner- delete .zip or 7z file from the Downloads folder & the new miner from the bin folder. Try it again. Ensure you have moved the mini builder.sh script to the /bin folder and have enabled it as an executable.
#-Ubuntu Mini Build may require more applications in order to work! I'm not sure if I was able to remember them all.
#-NVIDIA graphic card settings are fairly tedious to set-up, especially if you are used to the simplicity of Windows Afterburner. However, they are difficult because they are much more accurate and have far more options. It may take awhile of tweaking your card settings to get optimal conditions, but generally you get better performance and less issues once they compared to Windows miners.
#I suggest looking into ssh and/or remote viewer so you can login into your miner remotely. It is also good to edit your boot settings to have your GPUs automatically configure, and your miner autostart. Lastly, it's good to invest in a watchdog/restarting device in case of pc crashes, but ensure that if you are getting one for a usb miner- It uses pinging to determine if cpu is working, rather than hdd activity!
#
#PS4 MINING
#I have not attempted enough mining with PS4 as of yet to confirm it is successful to do so. However, if you are interested- You would have to find mining programs that run AMD, and setup the Ubuntu minimal installation as if you are setting up the PS4 to run Steam. There are lots of guides to which show you how to install linux gpu drivers compatible for AMD. MM.Hash has Normal settings built to run AMD devices- I simply haven't made or fully tested and AMD miners to add them to the mining program.
#
#MICROCONTROLLER MINING
#JayDDee CPUminer support ARM core procesors, which means you simply need to load the miner into and Ubuntu minimal installation, then run in the microcontroller. You simply just need to confirm the microcontroller you are using is confirmed to run Ubuntu.
#
#HDD MINING
#I am an avid Burstcoin miner, and quite interested in adding a feature to mine Burstcoin. However, my experience with Burstcoin mining is with Windows via Blago miner. I am slowly getting an understanding of Linux Burstcoin mining, and will add HDD mining to the miner, which will allow people to auto-start mining once they have built their plots, and set their reward address. At this time- I have not added this feature.
# 
#FUTURE UPDATES
#
#Putting link to your pool wallet address in miner.
#Adding CreepMiner for HDD/Burstcoin Mining (0-100 historical pool)
#Getting Realtime Price Data On Your Wallet Coin- Not Just BTC
#Building a bash script command to clear folders to reset miners (for troubleshooting)
#Building a script to pull a "Cheat Sheet" for mining statistics to quick-track with PuTTy
#AMD GPU SUPPORT (SGMINER)! COMING VERY SOON!
#
#
#
CONTACT
#
#This is beta release- post issues or questions you have through github.
#
#Discord Channel For MM.Hash- https://discord.gg/xVB5MqR
#
#I am having trouble searching repositories, and finding working linux CCminers. Everyone has been abadoning support for Linux since there has been no Multi-Miners. If you know devs- Tell them make a miner that can be compiled in linux, or make a compiled linux version like CCMiner- and I can load the mining file into the next release! I will also try to save non-working or older mining files in the OldMiners folder included in this repository. If you can send me benchmarking statistics, and prove the miner is faster- I will update mining files.
#
#
#
DONATE TO SUPPORT!
#
#DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i
#DONATION ADDRESS: RVN RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#Donate to original creator of powershell script, and see his Windows version: https://github.com/Sniffdog/Sniffdogminer
