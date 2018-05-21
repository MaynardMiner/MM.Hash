$Path = ".\Bin\EWBF-Linux\miner"
$Uri = "https://github.com/nanopool/ewbf-miner/releases/download/v0.3.4b/Zec.miner.0.3.4b.Linux.Bin.tar.gz"
$Build = "Linux-Zip"
$Distro = "Linux-EWBF"

$Devices = $EWBFDevices

$Algorithms = [PSCustomObject]@{
    #"bitcore" = "bitcore" #Bitcore
    #"blake2s" = "blake2s" #Blake2s
    #"blakecoin" = "blakecoin" #Blakecoin
    #"vanilla" = "vanilla" #BlakeVanilla
    #"cryptonight" = "cryptonight" #Cryptonight
    #"decred" = "decred" #Decred
    "equihash" = "equihash" #Equihash
    #"ethash" = "ethash" #Ethash
    #"groestl" = "groestl" #Groestl
    #"hmq1725" = "hmq1725" #hmq1725
    #"keccak" = "keccak" #Keccak
    #"lbry" = "lbry" #Lbry
    #"lyra2v2" = "lyra2v2" #Lyra2RE2
    #"lyra2z" = "lyra2z" #Lyra2z
    #"myr-gr" = "my-gr" #MyriadGroestl
    #"neoscrypt" = "neoscrypt" #NeoScrypt
    #"nist5" = "nist5" #Nist5
    #"pascal" = "pascal" #Pascal
    #"qubit" = "qubit" #Qubit
    #"scrypt" = "scrypt" #Scrypt
    #"sia" = "sia" #Sia
    #"sib" = "sib" #Sib
    #"skein" = "skein" #Skein
    #"timetravel" = "timetravel" #Timetravel
    #"x11" = "x11" #X11
    #"x11evo" = "x11evo" #X11evo
    #"x17" = "x17" #X17
    #"yescrypt" = "yescrypt" #Yescrypt
}

$Optimizations = [PSCustomObject]@{
    #"bitcore" = "" #Bitcore
    #"blake2s" = "" #Blake2s
    #"blakecoin" = "" #Blakecoin
    #"vanilla" = "" #BlakeVanilla
    #"cryptonight" = "" #Cryptonight
    #"decred" = "" #Decred
    "equihash" = "" #Equihash
    "ethash" = "" #Ethash
    #"groestl" = "" #Groestl
    #"hmq1725" = "" #hmq1725
    #"keccak" = "" #Keccak
    #"lbry" = "" #Lbry
    #"lyra2v2" = "" #Lyra2RE2
    #"lyra2z" = "" #Lyra2z
    #"myr-gr" = "" #MyriadGroestl
    #"neoscrypt" = "" #NeoScrypt
    #"nist5" = "" #Nist5
    #"pascal" = "" #Pascal
    #"qubit" = "" #Qubit
    #"scrypt" = "" #Scrypt
    #"sia" = "" #Sia
    #"sib" = "" #Sib
    #"skein" = "" #Skein
    #"timetravel" = "" #Timetravel
    #"x11" = "" #X11
    #"x11evo" = "" #X11evo
    #"x17" = "" #X17
    #"yescrypt" = "" #Yescrypt
}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
    [PSCustomObject]@{
	MinerName = "miner"
        Type = "NVIDIA"
        Path = $Path
	Distro =  $Distro
	Devices = $Devices
        Arguments = "--api 0.0.0.0:42000 --server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --fee 0 --solver 0 --eexit 1 --user $($Pools.(Get-Algorithm($_)).User) --pass $($Pools.(Get-Algorithm($_)).Pass)$($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Week}
        API = "EWBF"
        Port = 42000
        Wrap = $false
        URI = $Uri
	BUILD = $Build
    }
}
