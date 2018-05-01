# MM.Hash
#
#MM.Hash is intended to be Unix/Linux Multi-Algo, Multi-Coin, Multi-Device, Multi-Pool Mining application, which will mine from NVIDIA GPU, AMD GPU, CPU, and eventually Hard Disk Drive (Lowest on the list to get done). Its based design is a heavily modified fork multi-miner known as SniffDogMiner, but currently does not support Linux/Unix systems. You can find the original Windows version here: https://github.com/Sniffdog/Sniffdogminer. Currently I do not intend to build a Windows version, as SniffDogMiner is excellent and always updated.
#
#MM.Hash works by utlizing Powershell, which is now a cross-platform software that is constantly being developed. It will query the API of any pool you have your "Pools" folder, and get the current prices of the coins of the algorithms you have chose. Once it has gathered that data, it will then select the most profitable, and choose the best mining application to mine with, which are denoted as separate .ps1 filed in the "Miners" folder. If you have never used that particular miner before- MM.Hash will go into benchmark mode, which will record your hashrate. This means you can test miners to see which gives you the best hashrate! If MM.Hash detects the coin yields little/no value from mining- it will remove the miner from its list.
#
#I originally built the mining application on a Linux VM, and did extensive testing and debugging. Currently this is not the full release of the miner- I am simply releasing it to demonstrate and give users the ability to play with the initial design. Right now, I have only built a miner file for CPU, but I will build more miner files along the way.
#
#So Far I have been able to build the miner on an Ubuntu Mini, which means with enough effort- an image can easily be created to a flash stick, allowing MM.Hash to run directly off a flash drive. This has not been tested yet, but in theory it currently seems possible.
#
#IF YOU WANT TO SEE FURTHER DEVELOPMENT- PLEASE LEAVE DONATION SET & CONSIDER DONATING TO DEVELOPER!
#
#DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i
#
#BUILDING UBUNTU/Install
#
#Building the Ubuntu mini (NVIDIA SETUP AS EXAMPLE)
#
sudo apt install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings openbox obconf obmenu wicd ubuntu-drivers-common mesa-utils mesa-utils-extra compton xorg xserver-xorg nautilus gnome-terminal
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
apt-get install nvidia-cuda-dev nvidia-cuda-toolkit
#
#Navigate To Xorg Config Folder
cd /
cd /etc/X11
sudo xvidia-xonfig
#Recommended Overclock Settings: +100 Core +500 Memory, Fan Speed 70%, Max-Temp 70C
#
#
#
#CCMINER
#
sudo apt-get install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential
sudo apt-get install gcc-5 g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1
sudo apt-get install libgmp3-dev
sudo apt-get install curl
#
#
#
#POWERSHELL
#
wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo dpkg -i powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo apt-get install -f
#
#
#
#MM.Hash Dependencies
sudo apt-get install vim
sudo apt-get install xterm
sudo apt-get install p7zip-full
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
#First Move Mini Scripts To Your bin Folder:
cd MM.Hash
sudo mv BuildMiner /bin
#
#Now make them executable:
cd /
cd bin
chmod +x BuildMiner
#
#Make Configuration File executable:
chmod +x StartMM
#
#.NET FRAMEWORK INSTALL (2.0.6) (if powershell above doesn't work)
#
#
#
#CONFIGURATION
#
#Open StartMM:
#
#vi ./StartMM
#
#There is a list of options, with simple explanations as to how they work. As I build miner, I will eventually open a wiki on detailed function, but they are pretty easy to understand. Be sure to leave all '' and "" in each parameter where applicable! Basic edit commands: "i" lets you insert/edit file "esc" takes you to vi menu. While in vi menu, type :x to save, :q to quit.
#
#Ideal font size for gnome-terminal to show good display is 10pts. Edit - Profile Preferences - Custom Font.
#
#IMPORTANT: ENSURE POOL OFFERS EXCHANGE TO YOUR COIN SELECTED IN WALLET ADDRESS!
#
#STARTING THE MINER
#
#Naviagate to MM.Hash directory and run this command:
#
#./StartMM
#
#Miner will start! It takes a little bit for the miner to download and install and miners you want to use. I've found sometimes after they have finished building, I have to restart the miner. If the miner doesn't continue to the main screen, you can simple ctrl+c to close miner and then run ./startMM again.
#
#Git That Lambo!
#
#
#MAITENENCE/Issues
#
#If you wish to reset all your stats- Simple delet the Stats folder, and start MM.Hash. You can do this while it is running.
#If you wish to remove the benchmark of a particular miner/algo- delete its "hashrate".txt file. It will tell it to benchmark it again- You can do this while it is running.
#Navigating to the Miner files, and opening them with vi lets you configure miners. Putting a # turns off algo, removing # turns them on. Optimizations are added to the command line, so if you wish to increase its intensity for example, add -i [intensity] between the "" of the algo.
#You can add/edit miner files while miner is running. JUST MAKE SURE THEY ARE CORRECT BEFORE SAVING!
#There is a Logs folder which lets you track MM.Hash's history
#If you have issues installing a miner- delete .zip or 7z file from the Downloads folder & the new miner from the bin folder. Try it again. Ensure you have moved the mini builder.sh script to the /bin folder and have enabled it as an executable.
#You will likely have to restart MM.Hash mutliple times until all miners are loaded. This is a bug I am working on. I wanted to get a release out.
#Ubuntu Mini Build may require more applications in order to work! I'm not sure if I was able to remember them all.
#
#FUTURE UPDATES
#
#Putting link to your pool wallet address in miner.
#Getting "Active" to work.
#Adding CreepMiner for HDD/Burstcoin Mining (0-100 historical pool)
#Getting Realtime Price Data On Your Wallet Coin- Not Just BTC
#
