$Path = ".\Bin\CPU-JayDDee\ccminer.sln"
$Uri = "https://github.com/tpruvot/ccminer/archive/2.2.5-tpruvot.zip"



$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName


$Algorithms = [PSCustomObject]@{
    Qubit = 'qubit'
    #NeoScrypt = 'neoscrypt'
    X11 = 'x11'
    MyriadGroestl = 'myr-gr'
    #Groestl = 'groestl'
    #Keccak = 'keccak'
    Scrypt = 'scrypt'
    Bitcore = 'bitcore'
    Blake2s = 'blake2s'
    Sib = 'sib'
    #X17 = 'x17'
    Quark = 'quark'
    Hmq1725 = 'hmq1725'
    Veltor = 'veltor'
    X11evo = 'x11evo'
    #Timetravel = 'timetravel'
    Blakecoin = 'blakecoin'
    #Lbry = 'lbry'
    C11 = 'c11'
    Nist5 = 'nist5'
    Hsr = 'hsr' 
    BlakeVanilla = 'vanilla'
    Lyra2RE2 = 'lyra2v2'
    Lyra2z = 'lyra2z'
    Skein = 'skein'
    Skunk = 'skunk'
    Tribus = 'tribus'
    Phi = 'phi'
    Jha = 'jha'
    Decred = 'Decred'

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
    Lyra2z = ''
    Jha = ''
    Decred = ''
}



$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA"
        Path = $Path
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        API = "Ccminer"
        Port = 4068
        Wrap = $false
        URI = $Uri
    }
}
