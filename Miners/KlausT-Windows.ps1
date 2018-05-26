$Path = ".\Bin\KlausT-Windows\ccminer.exe"
$Uri = "https://github.com/KlausT/ccminer/releases/download/8.21/ccminer-821-cuda91-x64.zip"
$Build = "Windows"
$Distro = "Windows"

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms = [PSCustomObject]@{
    #Lyra2z = 'lyra2z' #not supported
    #Equihash = 'equihash' #not supported
    #Cryptonight = 'cryptonight' #not supported
    #Ethash = 'ethash' #not supported
    #Sia = 'sia' #use TpruvoT
    #Yescrypt = 'yescrypt' #use TpruvoT
    #BlakeVanilla = 'vanilla'
    #Lyra2RE2 = 'lyra2v2' 
    #Skein = 'skein' #use TpruvoT
    #Qubit = 'qubit' #use TpruvoT
    NeoScrypt = 'neoscrypt'
    #X11 = 'x11' #use TpruvoT
    #MyriadGroestl = "myr-gr"
    Groestl = 'groestl'
    #Keccak = 'keccak' 
    #Scrypt = 'scrypt' #use TpruvoT
    #Nist5 = 'nist5'

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
    Nist5 = ''
}


$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA"
        Path = $Path
	Distro = $Distro
	PName = "ccminer.exe"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
	API = "Ccminer"
        Port = 4069
        Wrap = $false
        URI = $Uri
	BUILD = $Build
    }
}
