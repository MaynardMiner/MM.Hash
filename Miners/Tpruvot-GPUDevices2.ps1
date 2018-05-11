$Path = ".\Bin\tpruvot\3"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "CCMiner"

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
    Lyra2z = '-d $GPUDevices2 --api-remote --api-allow=0/0 --submit-stale'
    Equihash = ''
    Cryptonight = '-d $GPUDevice2s -i 10 --api-remote --api-allow=0/0'
    Ethash = ''
    Sia = ''
    Yescrypt = ''
    BlakeVanilla = '-d $GPUDevices2'
    Lyra2RE2 = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Skein = '-d $GPUDevices2'
    Qubit = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    NeoScrypt = ''
    X11 = '-d $GPUDevices2'
    MyriadGroestl = '-d $GPUDevices2'
    Groestl = '-d $GPUDevices2'
    Keccak = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Scrypt = ''
    Bitcore = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Blake2s = ''
    Sib = '-d $GPUDevices2'
    X17 = '-d $GPUDevices2'
    Quark = ''
    Hmq1725 = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Veltor = '-d $GPUDevices2'
    X11evo = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Timetravel = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Blakecoin = '-d $GPUDevices2'
    Lbry = ''
    Jha = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Skunk = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Tribus = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Phi = '-d $GPUDevices2 -i 23 --api-remote --api-allow=0/0'
    Hsr = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Polytimos = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Decred = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    X16r = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Keccakc = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    X16s = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    X12 = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    C11 = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Xevan = '-d $GPUDevices2 --api-remote --api-allow=0/0'
    Nist5 = '-d $GPUDevices2 --api-remote --api-allow=0/0'
}


$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA2"
	GType = "NVIDIA"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User2) -p $($Pools.(Get-Algorithm($_)).Pass2) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
	BUILD = $Build
       }
      }
