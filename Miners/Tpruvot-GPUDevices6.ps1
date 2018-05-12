$Path = ".\Bin\tpruvot\6"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "CCMiner"

$Devices = $GPUDevices6

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms = [PSCustomObject]@{
    #Lyra2z = 'lyra2z'
    #Equihash = 'equihash' #not supported
    #Cryptonight = 'cryptonight'
    #Ethash = 'ethash' #not supported
    #Sia = 'sia'
    #Yescrypt = 'yescrypt'
    #BlakeVanilla = 'vanilla'
    #Lyra2v2 = 'lyra2v2'
    #Skein = 'skein'
    Qubit = 'qubit'
    NeoScrypt = 'neoscrypt'
    X11 = 'x11'
    #MyriadGroestl = 'myr-gr'
    Groestl = 'groestl'
    Keccak = 'keccak'
    #Scrypt = 'scrypt'
    #Bitcore = 'bitcore'
    #Blake2s = 'blake2s'
    #Sib = 'sib'
    #X17 = 'x17'
    #Quark = 'quark'
    #Hmq1725 = 'hmq1725'
    #Veltor = 'veltor'
    #X11evo = 'x11evo'
    #Timetravel = 'timetravel'
    #Blakecoin = 'blakecoin'
    #Lbry = 'lbry'
    #Jha = 'jha'
    Skunk = 'skunk'
    Tribus = 'tribus'
    #Phi = 'phi'
    #Hsr = 'hsr'
    #Polytimos = 'polytimos'
    #Decred = 'decred'
    #X16r = 'x16r'
    Keccakc = 'keccakc'
    #X16s = 'x16s'
    X12 = 'x12'
    #C11 = 'c11'
    #Xevan = 'xevan'
    #Nist5 = 'nist5'
    Allium = 'allium'
}


$Optimizations = [PSCustomObject]@{
    Lyra2z = ''
    Equihash = ''
    Cryptonight = ''
    Ethash = ''
    Sia = ''
    Yescrypt = ''
    BlakeVanilla = ''
    Lyra2v2 = ''
    Skein = '-i 28'
    Qubit = ''
    NeoScrypt = '-i 15'
    X11 = ''
    MyriadGroestl = ''
    Groestl = ''
    Keccak = ''
    Scrypt = ''
    Bitcore = ''
    Blake2s = ''
    Sib = '-i 21'
    X17 = 'i 21.5'
    Quark = ''
    Hmq1725 = ''
    Veltor = ''
    X11evo = '-i 21'
    Timetravel = '-i 25'
    Blakecoin = ''
    Lbry = '-i 28'
    Jha = ''
    Skunk = ''
    Tribus = ''
    Phi = ''
    Hsr = ''
    Polytimos = ''
    Decred = ''
    X16r = ''
    Keccakc = ''
    X16s = ''
    X12 = ''
    C11 = '-i 20'
    Xevan = ''
    Nist5 = ''
    Allium = ''
}

$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA6"
        Path = $Path
	Devices = $Devices
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4074 -u $($Pools.(Get-Algorithm($_)).User6) -p $($Pools.(Get-Algorithm($_)).Pass6) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4074
        Wrap = $false
        URI = $Uri
	BUILD = $Build
     }
    }
