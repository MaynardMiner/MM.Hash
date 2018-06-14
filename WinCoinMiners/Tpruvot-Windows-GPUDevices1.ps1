$Path = ".\Bin\tpruvot-Windows-GPUDevices1\ccminer-x64.exe"
$Uri = "https://github.com/tpruvot/ccminer/releases/download/2.2.4-tpruvot/ccminer-x64-2.2.4-cuda9.7z"


$Devices = $GPUDevices1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#Lyra2v2 
#Keccak
#Skunk
#Tribus
#Phi
#Keccakc
#Lyra2z
#Bitcore
#Hmq1725
#Timetravel

$Commands = [PSCustomObject]@{
    "ABS" = '' #Lryra2v2
    "ARG-lyra2v2" = '' #Lryra2v2
    "KREDS" = '' #Lyra2v2
    "LUNEX" = '' #Lyra2v2
    "MONA" = '' #Lyra2v2
    "MTI" = '' #Lyra2v2
    "ORE" = '' #Lyra2v2
    "RACE" = '' #Lyra2v2
    "RUP" = '' #Lyra2v2
    "STAK" = '' #Lyra2v2
    "UIS-lyra2v2" = '' #Lyra2v2
    "VTC" = '' #Lyra2v2
    "XSH-lyra2v2" = '' #Lyra2v2
    "XVG-Lyra2v2" = '' #Lyra2v2
    "MAX" = '' #Keccak
    "SMART" = '' #Keccak
    "COG" = '' #Skunk
    "MGT" = '' #Skunk
    "MUN" = '' #Skunk
    "BZL" = '' #Tribus
    "DNR" = '' #Tribus
    "SCRIV" = '' #Tribus
    "TIN" = '' #Tribus
    "ZULA" = '' #Tribus
    "FLM" = '' #Phi
    "LUX" = '' #Phi
    "SERA" = '' #Phi
    "CREA" = '' #Keccakc
    "ARG-myr-gr" = '' #myr-gr
    "AUR-myr-gr" = '' #myr-gr
    "DGB-myr-gr" = '' #myr-gr
    "XMY-myr-gr" = '' #myr-gr
    "XSH-myr-gr" = '' #myr-gr
    "XVG-myr-gr" = '' #myr-gr
    "ALPS" = '' #Lyra2z
    "CRS" = '' #Lyra2z
    "GIN" = '' #Lyra2z
    "IFX" = '' #Lyra2z
    "MANO" = '' #Lyra2z
    "PYRO" = '' #Lyra2z
    "TLR" = '' #Lyra2z
    "VTL" = '' #Lyra2z
    "BTX" = '' #Bitcore
    "BRAZ" = '' #Hmq1725
    "ERA" = '' #Hmq1725
    "ESP" = '' #Hmq1725
    "PLUS" = '' #Hmq1725
    "VEGI" = '' #Hmq1725
    "MAC" = '' #Timetravel
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "ccminer"
	    Type = "NVIDIA1"
        Path = $Path
	    Distro = $Distro
	    Devices = $Devices
        Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4069 -u $($Pools.$_.User1) -p $($Pools.$_.Pass1) $($Commands.$_)"
        HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Port = 4069
        Wrap = $false
        URI = $Uri
	    BUILD = $Build
       }
     }
    }
