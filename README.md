# MM.Hash

MM.Hash is intended to be Unix/Linux Multi-Algo, Multi-Coin, Multi-Device, Multi-Pool Mining application, which will mine from NVIDIA GPU, AMD GPU, CPU, and eventually Hard Disk Drive (Lowest on the list to get done). Its based design is a heavily modified fork multi-miner known as SniffDogMiner, but currently does not support Linux/Unix systems. You can find the original Windows version here: https://github.com/Sniffdog/Sniffdogminer. Currently I do not intend to build a Windows version, as SniffDogMiner is excellent and always updated.

MM.Hash works by utlizing Powershell, which is now a cross-platform software that is constantly being developed. It will query the API of any pool you have your "Pools" folder, and get the current prices of the coins of the algorithms you have chose. Once it has gathered that data, it will then select the most profitable, and choose the best mining application to mine with, which are denoted as separate .ps1 filed in the "Miners" folder. If you have never used that particular miner before- MM.Hash will go into benchmark mode, which will record your hashrate. This means you can test miners to see which gives you the best hashrate! If MM.Hash detects the coin yields little/no value from mining- it will remove the miner from its list.

I originally built the mining application on a Linux VM, and did extensive testing and debugging. Currently this is not the full release of the miner- I am simply releasing it to demonstrate and give users the ability to play with the initial design. Right now, I have only built a miner file for CPU, but I will build more miner files along the way.

So Far I have been able to build the miner on an Ubuntu Mini, which means with enough effort- an image can easily be created to a flash stick, allowing MM.Hash to run directly off a flash drive. This has not been tested yet, but in theory it currently seems possible.

IF YOU WANT TO SEE FURTHER DEVELOPMENT- PLEASE LEAVE DONATION SET & CONSIDER DONATING TO DEVELOPER!

DONATION ADDRESS: BTC 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i

BUILDING UBUNTU/Install

Building the Ubuntu mini

sudo apt install lightdm
sudo apt install openbox
sudo apt install openbox-gnome-session
sudo apt install gnome-terminal

That's everything basic for GUI

CCMINER

sudo apt-get install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential
sudo apt-get install gcc-5 g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 1

NVIDIA DRIVERS

sudo apt-get install software-properties-common python-software-properties
sudo apt-get update
sudo apt-get install nvidia-390
sudo apt-mark hold nvidia-390
Here is a link for further details on installing CUDA Toolkit https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

POWERSHELL

wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo dpkg -i powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo apt-get install -f

GITHUB LINK

https://github.com/MaynardMiner/MM.Hash.git

DEPENDENCIES

sudo apt-get install vim (For text editing)
sudo apt-get install libgmp3-dev
sudo apt-get install xterm

SETUP

First Move Mini Scripts To Your bin Folder:

/MM.Hash
sudo mv BuildMiner /bin

Now make them executable:

chmod +x BuildMiner

Make Configuration File executable:

chmod +x StartMM

.NET Framework Install (2.0.6) (if powershell above doesn't work)

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-runtime-2.0.6


CONFIGURATION

Open StartMM:

vi ./StartMM

There is a list of options, with simple explanations as to how they work. As I build miner, I will eventually open a wiki on detailed function, but they are pretty easy to understand. Be sure to leave all '' and "" in each parameter where applicable! 


STARTING THE MINER

Naviagate to MM.Hash directory and run this command:

./StartMM

Miner will start! It takes a little bit for the miner to download and install and miners you want to use. I've found sometimes after they have finished building, I have to restart the miner. If the miner doesn't continue to the main screen, you can simple ctrl+c to close miner and then run ./startMM again.

Git That Lambo!


MAITENENCE/Issues

If you wish to reset all your stats- Simple delet the Stats folder, and start MM.Hash.
There is a Logs folder which lets you track MM.Hash's history
If you have issues installing a miner- delete .zip or 7z file from the Downloads folder & the new miner from the bin folder. Try it again. Ensure you have moved the mini builder.sh script to the /bin folder and have enabled it as an executable.


Ubuntu Mini Build may require more applications in order to work! I'm not sure if I was able to remember them all.
