$Path = ".\Bin\tpruvot\4"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "Linux"
$Distro = "Linux"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#Lyra2v2 
#Keccak
#Skunk
#Tribus
#Phi
#Keccakc
#Sib

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
    "Sib" = '' #Sib
    "GRLC" = '' #Allium
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
	if($Algorithm -eq $Pools.$_.Algorithm)
	 {
        [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA2"
        Path = $Path
	Distro = $Distro
	Devices = $Devices
        Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
	Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
        BUILD = $Build
	}
       }
    }
