$Path = ".\Bin\AMD-NiceHashSGMiner\sgminer.c"
$Uri = "https://github.com/nicehash/sgminer/releases/download/5.6.1/sgminer-5.6.1-nicehash-51-windows-amd64.zip"

$Algorithms = [PSCustomObject]@{
    #Bitcore = "" #Bitcore
    #Blake2s = "" #Blake2s
    Blake = 'blake' #Blakecoin
    Vanilla = 'vanilla' #BlakeVanilla
    #Cryptonight = 'cryptonight' #Crpytonight
    Decred = 'decred' #Decred
    #Equihash = 'equihash' #Equihash
    #Ethash = 'ethash' #Ethash
    Groestlcoin = 'groestl' #Groestl
   "Myriadcoin-groestl" = "Myraidcoin-groestl" #MyriadGroestl
    #Hmq1725 = 'hmq1725' #hmq1725
    Maxcoin = 'maxcoin' #Keccak
    Lbry = 'lbry' #Lbry
    Lyra2rev2 = 'lyra2rev2' #Lyra2RE2
    #Lyra2z = 'lyra2z' #Lyra2z   
    Neoscrypt = 'neoscrypt' #NeoScrypt
    #Nist5 = 'nist5' #Nist5
    Pascal = 'pascal' #Pascal
    Qubitcoin = 'qubitcoin' #Qubit
    Zuikkis = 'zuikkis' #Scrypt
    Sia = 'sia' #Sia
    #Sib = 'sib' #Sib
    Skeincoin = 'skeincoin' #Skein
    #Timetravel = 'timetravel' #Timetravel
    "Darkcoin-mod" = "darkcoin-mod" #X11
    #X11evo = 'x11evo' #X11evo
    #X17 = 'x17' #X17
    Yescrypt = 'yescrypt' #Yescrypt
}

$Optimizations = [PSCustomObject]@{
    #Bitcore = "" #Bitcore
    #Blake2s = "" #Blake2s
    Blake = "" #Blakecoin
    Vanilla = " --intensity d" #BlakeVanilla
    #Cryptonight = " --gpu-threads 1 --worksize 8 --rawintensity 896" #Cryptonight
    Decred = "" #Decred
    #Equihash = " --gpu-threads 2 --worksize 256" #Equihash
    #Ethash = " --gpu-threads 1 --worksize 192 --xintensity 1024" #Ethash
    Groestlcoin = " --gpu-threads 2 --worksize 128 --intensity d" #Groestl
    #Hmq1725 = "" #hmq1725
    Maxcoin = "" #Keccak
    Lbry = "" #Lbry
    Lyra2rev2 = " --gpu-threads 2 --worksize 128 --intensity d" #Lyra2RE2
    #lyra2z = " --worksize 32 --intensity 18" #Lyra2z
    "Myriadcoin-groestl" = " --gpu-threads 2 --worksize 64 --intensity d" #MyriadGroestl
    Neoscrypt = " --gpu-threads 1 --worksize 64 --intensity 11 --thread-concurrency 64" #NeoScrypt
    #Nist5 = "" #Nist5
    Pascal = "" #Pascal
    Qubitcoin = " --gpu-threads 2 --worksize 128 --intensity d" #Qubit
    Zuikkis = "" #Scrypt
    Sia = "" #Sia
    #sib = "" #Sib
    Skeincoin = " --gpu-threads 2 --worksize 256 --intensity d" #Skein
    #Timetravel = "" #Timetravel
    "Darkcoin-mod" = " --gpu-threads 2 --worksize 128 --intensity d" #X11
    #X11evo = "" #X11evo
    #X17 = "" #X17
    Yescrypt = " --worksize 4 --rawintensity 256" #Yescrypt
}



$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Algorithms |Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($SelectedAlgo -eq $_)
   {
   [PSCustomObject]@{
        Type = "AMD"
	Minername = "sgminer"
        Path = $Path
        Arguments = "--api-listen -k $_ -o $($Pools.(Get-Algorithm($_)).Protocol)://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -u $($Pools.(Get-Algorithm($_)).User) -p $($Pools.(Get-Algorithm($_)).Pass)$($Optimizations.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Week}
        API = "Xgminer"
        Port = 4088
        Wrap = $false
        URI = $Uri
	Compiled = "Yes"
                    }
     }   
}
