# MM.Hash

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

POWERSHELL

wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0/powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo dpkg -i powershell_6.0.0-1.ubuntu.17.04_amd64.deb
sudo apt-get install -f

GITHUB LINK

https://github.com/MaynardMiner/MM.Hash.git

DEPENDENCIES

sudo apt-get install vim (For text editing)
sudo apt-get install libgmp3-dev

SETUP

First Move Mini Scripts To Your Bin Folder

cd MM.Hash
sudo mv miner.sh /bin
sudo mv builder.sh /bin

Now make them executable:

chmod +x miner.sh
chmod +x builder.sh

.NET Framework Install (2.0.6)

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-runtime-2.0.6


