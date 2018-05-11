$Path = ".\Bin\tpruvot\4"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "CCMiner"

[string]$Devices = $GPUDevices4

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms = [PSCustomObject]@{
    Lyra2z = 'lyra2z'
    #Equihash = 'equihash' #not supported
    #Cryptonight = 'cryptonight'
    #Ethash = 'ethash' #not supported
    #Sia = 'sia'
    #Yescrypt = 'yescrypt'
    BlakeVanilla = 'vanilla'
    Lyra2REv2 = 'lyra2v2'
    Skein = 'skein'
    Qubit = 'qubit'
    NeoScrypt = 'neoscrypt'
    X11 = 'x11'
    MyriadGroestl = 'myr-gr'
    Groestl = 'groestl'
    Keccak = 'keccak'
    #Scrypt = 'scrypt'
    Bitcore = 'bitcore'
    Blake2s = 'blake2s'
    Sib = 'sib'
    #X17 = 'x17'
    Quark = 'quark'
    Hmq1725 = 'hmq1725'
    Veltor = 'veltor'
    X11evo = 'x11evo'
    Timetravel = 'timetravel'
    Blakecoin = 'blakecoin'
    #Lbry = 'lbry'
    #Jha = 'jha'
    Skunk = 'skunk'
    Tribus = 'tribus'
    #Phi = 'phi'
    Hsr = 'hsr'
    #Polytimos = 'polytimos'
    Decred = 'decred'
    #X16r = 'x16r'
    Keccakc = 'keccakc'
    #X16s = 'x16s'
    X12 = 'x12'
    C11 = 'c11'
    #Xevan = 'xevan'
    Nist5 = 'nist5'
}


$Optimizations = [PSCustomObject]@{
    Lyra2z = [string]"-d $Devices --api-remote --api-allow=0/0 --submit-stale"
    Equihash = [string]"-d $Devices --api-remote --api-allow=0/0"
    Cryptonight = [string]"-d $Devices --api-remote --api-allow=0/0"
    Ethash = [string]"-d $Devices --api-remote --api-allow=0/0"
    Sia = [string]"-d $Devices --api-remote --api-allow=0/0"
    Yescrypt = [string]"-d $Devices --api-remote --api-allow=0/0"
    BlakeVanilla = [string]"-d $Devices --api-remote --api-allow=0/0"
    Lyra2REv2 = [string]"-d $Devices --api-remote --api-allow=0/0"
    Skein = [string]"-i 28 -d $Devices --api-remote --api-allow=0/0"
    Qubit = [string]"-d $Devices --api-remote --api-allow=0/0"
    NeoScrypt = [string]"-i 15 -d $Devices --api-remote --api-allow=0/0"
    X11 = [string]"-d $Devices --api-remote --api-allow=0/0"
    MyriadGroestl = [string]"-d $Devices --api-remote --api-allow=0/0"
    Groestl = [string]"-d $Devices --api-remote --api-allow=0/0"
    Keccak = [string]"-d $Devices --api-remote --api-allow=0/0"
    Scrypt = [string]"-d $Devices --api-remote --api-allow=0/0"
    Bitcore = [string]"-d $Devices --api-remote --api-allow=0/0"
    Blake2s = [string]"-d $Devices --api-remote --api-allow=0/0"
    Sib = [string]"-i 21 -d $Devices --api-remote --api-allow=0/0"
    X17 = [string]"i 21.5 -d $Devices --api-remote --api-allow=0/0"
    Quark = [string]"-d $Devices --api-remote --api-allow=0/0"
    Hmq1725 = [string]"-d $Devices --api-remote --api-allow=0/0"
    Veltor = [string]"-d $Devices --api-remote --api-allow=0/0"
    X11evo = [string]"-i 21 -d $Devices --api-remote --api-allow=0/0"
    Timetravel = [string]"-i 25 -d $Devices --api-remote --api-allow=0/0"
    Blakecoin = [string]"-d $Devices --api-remote --api-allow=0/0"
    Lbry = [string]"-i 28 -d $Devices --api-remote --api-allow=0/0"
    Jha = [string]"-d $Devices --api-remote --api-allow=0/0"
    Skunk = [string]"-d $Devices --api-remote --api-allow=0/0"
    Tribus = [string]"-d $Devices --api-remote --api-allow=0/0"
    Phi = [string]"-d $Devices --api-remote --api-allow=0/0"
    Hsr = [string]"-d $Devices --api-remote --api-allow=0/0"
    Polytimos = [string]"-d $Devices --api-remote --api-allow=0/0"
    Decred = [string]"-d $Devices --api-remote --api-allow=0/0"
    X16r = [string]"-d $Devices --api-remote --api-allow=0/0"
    Keccakc = [string]"-d $Devices --api-remote --api-allow=0/0"
    X16s = [string]"-d $Devices --api-remote --api-allow=0/0"
    X12 = [string]"-d $Devices --api-remote --api-allow=0/0"
    C11 = [string]"-i 20 -d $Devices --api-remote --api-allow=0/0"
    Xevan = [string]"-d $Devices --api-remote --api-allow=0/0"
    Nist5 = [string]"-d $Devices --api-remote --api-allow=0/0"
}

$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA4"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4072 -u $($Pools.(Get-Algorithm($_)).User4) -p $($Pools.(Get-Algorithm($_)).Pass4) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4072
        Wrap = $false
        URI = $Uri
	BUILD = $Build
     }
    }
