$Path = ".\Bin\KlausT\2"
$Uri = "https://github.com/KlausT/ccminer"
$Build = "CCMiner"

$Devices = $GPUDevices2

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
    #NeoScrypt = 'neoscrypt'
    #X11 = 'x11' #use TpruvoT
    #MyriadGroestl = "myr-gr"
    #Groestl = 'groestl'
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
	Type = "NVIDIA2"
        Path = $Path
	Devices = $Devices
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algorithm($_)).User2) -p $($Pools.(Get-Algorithm($_)).Pass2) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
	API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
	BUILD = $Build
    }
}
