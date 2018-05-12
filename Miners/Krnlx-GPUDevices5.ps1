$Path = ".\Bin\krnlx\5"
$Uri = "https://github.com/krnlx/ccminer-xevan.git"
$Build = "CCMiner"

$Devices = $GPUDevices5

$Algorithms = [PSCustomObject]@{
    #Qubit = 'qubit'
    #NeoScrypt = 'neoscrypt'
    #X11 = 'x11'
    #MyriadGroestl = "myr-gr"
    #Groestl = 'groestl'
    #Keccak = 'keccak'
    #Keccakc = 'keccakc'
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
    #C11 = 'c11'
    #Nist5 = 'nist5'
    #Hsr = 'hsr' 
    #BlakeVanilla = 'vanilla'
    #Lyra2v2 = 'lyra2v2'
    #Lyra2z = 'lyra2z'
    #Skein = 'skein'
    #Skunk = 'skunk'
    #Tribus = 'tribus'
    #Phi = 'phi'
    #Jha = 'jha'
    #Decred = 'Decred'
    Xevan = 'xevan'

}

$Optimizations = [PSCustomObject]@{
    Lyra2z = ''
    Equihash = ''
    Cryptonight = ''
    Ethash = ''
    Sia = ''
    Yescrypt = ''
    BlakeVanilla = ''
    Lyra2RE2 = ''
    Skein = ''
    Qubit = ''
    NeoScrypt = ''
    X11 = ''
    MyriadGroestl = ''
    Groestl = ''
    Keccak = ''
    Keccakc = ''
    Scrypt = ''
    Bitcore = ''
    Blake2s = ''
    Sib = ''
    X17 = ''
    Quark = ''
    Hmq1725 = ''
    Veltor = ''
    X11evo = ''
    Timetravel = ''
    Blakecoin = ''
    Lbry = ''
    C11 = ''
    Nist5 = ''
    Hsr = ''
    Tribus = ''
    Phi = ''
    Jha = ''
    Decred = ''
    xevan = ''
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName


$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
	[PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA5"
        Path = $Path
	Devices = $Devices
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4073 -u $($Pools.(Get-Algorithm($_)).User5) -p $($Pools.(Get-Algorithm($_)).Pass5) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4073
        Wrap = $false
        URI = $Uri
     }
    }
