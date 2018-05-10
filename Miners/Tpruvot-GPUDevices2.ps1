$Path = ".\Bin\tpruvot\3"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "CCMiner"


$Devices = "-d GPUDevices2"

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
  

$Algorithms = [PSCustomObject]@{
    #Lyra2z = 'lyra2z'
    #Equihash = 'equihash' #not supported
    #Cryptonight = 'cryptonight'
    #Ethash = 'ethash' #not supported
    #Sia = 'sia'
    #Yescrypt = 'yescrypt'
    BlakeVanilla = 'vanilla'
    Lyra2RE2 = 'lyra2v2'
    Skein = 'skein'
    Qubit = 'qubit'
    #NeoScrypt = 'neoscrypt'
    X11 = 'x11'
    MyriadGroestl = 'myr-gr'
    Groestl = 'groestl'
    Keccak = 'keccak'
    #Scrypt = 'scrypt'
    Bitcore = 'bitcore'
    Blake2s = 'blake2s'
    Sib = 'sib'
    X17 = 'x17'
    Quark = 'quark'
    #Hmq1725 = 'hmq1725'
    Veltor = 'veltor'
    X11evo = 'x11evo'
    Timetravel = 'timetravel'
    Blakecoin = 'blakecoin'
    #Lbry = 'lbry'
    #Jha = 'jha'
    Skunk = 'skunk'
    Tribus = 'tribus'
    Phi = 'phi'
    Hsr = 'hsr'
    #Polytimos = 'polytimos'
    #Decred = 'decred'
    #X16r = 'x16r'
    Keccakc = 'keccakc'
    #X16s = 'x16s'
    X12 = 'x12'
    C11 = 'c11'
    #Xevan = 'xevan'
    Nist5 = 'nist5'
}


$Optimizations = [PSCustomObject]@{
    Lyra2z = ' $Devices --api-remote --api-allow=0/0 --submit-stale'
    Equihash = ''
    Cryptonight = ' $Devices -i 10 --api-remote --api-allow=0/0'
    Ethash = ''
    Sia = ''
    Yescrypt = ''
    BlakeVanilla = ' $Devices'
    Lyra2RE2 = ' $Devices --api-remote --api-allow=0/0'
    Skein = ' $Devices'
    Qubit = ' $Devices --api-remote --api-allow=0/0'
    NeoScrypt = ''
    X11 = ' $Devices'
    MyriadGroestl = ' $Devices'
    Groestl = ' $Devices'
    Keccak = ' $Devices --api-remote --api-allow=0/0'
    Scrypt = ''
    Bitcore = ' $Devices --api-remote --api-allow=0/0'
    Blake2s = ''
    Sib = ' $Devices'
    X17 = ' $Devices'
    Quark = ''
    Hmq1725 = ' $Devices --api-remote --api-allow=0/0'
    Veltor = ' $Devices'
    X11evo = ' $Devices --api-remote --api-allow=0/0'
    Timetravel = ' $Devices --api-remote --api-allow=0/0'
    Blakecoin = ' $Devices'
    Lbry = ''
    Jha = ' $Devices --api-remote --api-allow=0/0'
    Skunk = ' $Devices --api-remote --api-allow=0/0'
    Tribus = ' $Devices --api-remote --api-allow=0/0'
    Phi = ' $Devices -i 23 --api-remote --api-allow=0/0'
    Hsr = ' $Devices --api-remote --api-allow=0/0'
    Polytimos = ' $Devices --api-remote --api-allow=0/0'
    Decred = ' $Devices --api-remote --api-allow=0/0'
    X16r = ' $Devices --api-remote --api-allow=0/0'
    Keccakc = ' $Devices --api-remote --api-allow=0/0'
    X16s = ' $Devices --api-remote --api-allow=0/0'
    X12 = ' $Devices --api-remote --api-allow=0/0'
    C11 = ' $Devices --api-remote --api-allow=0/0'
    Xevan = ' $Devices --api-remote --api-allow=0/0'
    Nist5 = ' $Devices --api-remote --api-allow=0/0'
}


$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA2"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User2) -p $($Pools.(Get-Algorithm($_)).Pass2) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
       }
      }
