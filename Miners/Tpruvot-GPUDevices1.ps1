$Path = ".\Bin\tpruvot\1"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "CCMiner"


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Devices = "$GPUDevices1"

$Algorithms = [PSCustomObject]@{
    Lyra2z = 'lyra2z'
    #Equihash = 'equihash' #not supported
    #Cryptonight = 'cryptonight'
    #Ethash = 'ethash' #not supported
    #Sia = 'sia'
    #Yescrypt = 'yescrypt'
    BlakeVanilla = 'vanilla'
    #Lyra2RE2 = 'lyra2v2'
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
    Lyra2z = '-d $Devices --api-remote --api-allow=0/0 --submit-stale'
    Equihash = ''
    Cryptonight = '-d $Devices -i 10 --api-remote --api-allow=0/0'
    Ethash = ''
    Sia = ''
    Yescrypt = ''
    BlakeVanilla = '-d $Devices'
    Lyra2RE2 = '-d $Devices --api-remote --api-allow=0/0'
    Skein = '-d $Devices'
    Qubit = '-d $Devices --api-remote --api-allow=0/0'
    NeoScrypt = ''
    X11 = '-d $Devices'
    MyriadGroestl = '-d $Devices'
    Groestl = '-d $Devices'
    Keccak = '-d $Devices --api-remote --api-allow=0/0'
    Scrypt = ''
    Bitcore = '-d $Devices --api-remote --api-allow=0/0'
    Blake2s = ''
    Sib = '-d $Devices'
    X17 = '-d $Devices'
    Quark = ''
    Hmq1725 = '-d $Devices --api-remote --api-allow=0/0'
    Veltor = '-d $Devices'
    X11evo = '-d $Devices --api-remote --api-allow=0/0'
    Timetravel = '-d $Devices --api-remote --api-allow=0/0'
    Blakecoin = '-d $Devices'
    Lbry = ''
    Jha = '-d $Devices --api-remote --api-allow=0/0'
    Skunk = '-d $Devices --api-remote --api-allow=0/0'
    Tribus = '-d $Devices --api-remote --api-allow=0/0'
    Phi = '-d $Devices -i 23 --api-remote --api-allow=0/0'
    Hsr = '-d $Devices --api-remote --api-allow=0/0'
    Polytimos = '-d $Devices --api-remote --api-allow=0/0'
    Decred = '-d $Devices --api-remote --api-allow=0/0'
    X16r = '-d $Devices --api-remote --api-allow=0/0'
    Keccakc = '-d $Devices --api-remote --api-allow=0/0'
    X16s = '-d $Devices --api-remote --api-allow=0/0'
    X12 = '-d $Devices --api-remote --api-allow=0/0'
    C11 = '-d $Devices --api-remote --api-allow=0/0'
    Xevan = '-d $Devices --api-remote --api-allow=0/0'
    Nist5 = '-d $Devices --api-remote --api-allow=0/0'
}

$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA1"
	GType = "NVIDIA"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User1) -p $($Pools.(Get-Algorithm($_)).Pass1) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4069
        Wrap = $false
        URI = $Uri
	BUILD = $Build
     }
    }
