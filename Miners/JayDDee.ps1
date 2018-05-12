$Path = "./Bin/JayDDee\0"
$Uri = "https://github.com/JayDDee/cpuminer-opt.git"
$Build =  "CPUMiner"

$Algorithms = [PSCustomObject]@{
    #Bitcore = 'bitcore' #Bitcore
    #Blake2s = 'blake2s' #Blake2s
    #Blakecoin = 'blakecoin' #Blakecoin
    #Vanilla = 'vanilla' #BlakeVanilla
    #Cryptonight = 'cryptonight' #Cryptonight
    #Decred = 'decred' #Decred
    #Equihash = 'equihash' #Equihash
    #Ethash = 'ethash' #Ethash
    #Groestl = 'groestl' #Groestl
    #Hmq1725 = 'hmq1725' #hmq1725
    #Keccak = 'keccak' #Keccak
    #Lbry = 'lbry' #Lbry
    #Lyra2v2 = 'lyra2v2' #Lyra2RE2
     Lyra2z = 'lyra2z' #Lyra2z
    #MyriadGroestl = "myr-gr" #MyriadGroestl
    #Neoscrypt = 'neoscrypt' #NeoScrypt
    #Nist5 = 'nist5' #Nist5
    #Pascal = 'pascal' #Pascal
    #Qubit = 'qubit' #Qubit
    #Scrypt = 'scrypt' #Scrypt
    #Sia = 'sia' #Sia
    #Sib = 'sib' #Sib
    #Skein = 'skein' #Skein
    #Timetravel = 'timetravel' #Timetravel
    #X11 = 'x11' #X11
    #X11evo = 'x11evo' #X11evo
    #X17 = 'x17' #X17
     Yescrypt = 'yescrypt' #Yescrypt
    #M7m = 'm7m' #M7M
    #Lyra2h = 'lyra2h' #Lyra2h
    #Yescryptr8 = 'yescryptr8' #Yescryptr8
    #X16r = 'x16r' #Ravencoin
     YescryptR16 = 'yescryptr16' #Yenten
     X16s = 'x16s' #Pigeoncoin
}

$Optimizations = [PSCustomObject]@{
    Bitcore = ''
    Blake2s = ''
    Blakecoin = '' 
    Vanilla = ''
    Cryptonight = ''
    Decred = '' 
    Equihash = ''
    Ethash = '' 
    Groestl = ''
    Hmq1725 = ''
    Keccak = '' 
    Lbry = '' 
    Lyra2v2 = '' 
    Lyra2z = '' 
    Myriadgroest = ''
    Neoscrypt = '' 
    Nist5 = ''
    Pascal = ''
    Qubit = '' 
    Scrypt = ''
    Sia = '' 
    Sib = ''
    Skein = ''
    Timetravel = ''
    X11 = '' 
    X11evo = '' 
    X17 = '' 
    Yescrypt = '' 
    M7m = ''
    Lyra2h = ''
    Yescryptr8 = ''
    X16r  = '' 
    YescryptR16 = ''
    X16s = '' 
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    [PSCustomObject]@{
        MinerName = "cpuminer"
	Type = "CPU"
        Path = $Path
	Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass) $($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}      
        API = "Ccminer"
        Port = 4048
        Wrap = $false
        URI = $Uri
	BUILD = $Build
	}
     }
