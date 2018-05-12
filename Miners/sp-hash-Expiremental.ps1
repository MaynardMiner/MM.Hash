$Path = ".\Bin\sp-hash\0"
$Uri = "https://github.com/sp-hash/ccminer.git"
$Build = "CCMiner"


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms = [PSCustomObject]@{
    #"bitcore" = "bitcore" #Bitcore
    #"blake2s" = "blake2s" #Blake2s
    #"blakecoin" = "blakecoin" #Blakecoin
    #"c11" = "c11" #C11
    #"vanilla" = "vanilla" #BlakeVanilla
    #"cryptonight" = "cryptonight" #Cryptonight
    #"decred" = "decred" #Decred
    #"equihash" = "" #Equihash
    #"ethash" = "" #Ethash
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
    #"phi" = "" #Phi
}

$Optimizations = [PSCustomObject]@{
    "bitcore" = "" #Bitcore
    "blake2s" = "" #Blake2s
    "blakecoin" = "" #Blakecoin
    "c11" = "" #C11
    "vanilla" = "" #BlakeVanilla
    "cryptonight" = "" #Cryptonight
    "decred" = "" #Decred
    "equihash" = "" #Equihash
    "ethash" = "" #Ethash
    "groestl" = "" #Groestl
    "hmq1725" = "" #hmq1725
    "keccak" = "" #Keccak
    "lbry" = "" #Lbry
    "lyra2v2" = "" #Lyra2RE2
    "lyra2z" = "" #Lyra2z
    "myr-gr" = "" #MyriadGroestl
    "neoscrypt" = "" #NeoScrypt
    "nist5" = "" #Nist5
    "pascal" = "" #Pascal
    "qubit" = "" #Qubit
    "scrypt" = "" #Scrypt
    "sia" = "" #Sia
    "sib" = "" #Sib
    "skein" = "" #Skein
    "timetravel" = "" #Timetravel
    "x11" = "" #X11
    "x11evo" = "" #X11evo
    "x17" = "" #X17
    "yescrypt" = "" #Yescrypt
    "phi" = "" #Phi
}

$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4068
        Wrap = $false
        URI = $Uri
	BUILD = $Build
     }
}
