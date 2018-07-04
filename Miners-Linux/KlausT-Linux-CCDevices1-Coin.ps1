$Path = ".\Bin\KlausT\2"
$Uri = "https://github.com/KlausT/ccminer/archive/8.21.zip"
$Build = "Linux-Zip-Build"
$Distro = "Linux"

if($CCDevices1 -ne ''){$Devices = $CCDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#NeoScrypt
#Groestl

$Commands = [PSCustomObject]@{
"GRS" = '' #Groestl
"AGN" = '' #neoscrypt
"BANQ" = '' #neoscrypt
"CBS" = '' #neoscrypt
"CRC" = '' #neoscrypt
"CRZ" = '' #neoscrypt
"CST" = '' #neoscrypt
"CTF" = '' #neoscrypt
"DSR" = '' #neoscrypt
"END" = '' #neoscrypt
"FTC" = '' #neoscrypt
"GBX" = '' #neoscrypt
"GOA" = '' #neoscrypt
"GUN" = '' #neoscrypt
"HAL" = '' #neoscrypt
"HARC" = '' #neoscrypt
"INN" = '' #neoscrypt
"IQ" = '' #neoscrypt
"LBTC" = '' #neoscrypt
"LINC" = '' #neoscrypt
"LUCKY" = '' #neoscrypt
"MBC" = '' #neoscrypt
"MOC" = '' #neoscrypt
"MON" = '' #neoscrypt
"NDASH" = '' #neoscrypt
"NYX" = '' #neoscrypt
"ORB" = '' #neoscrypt
"PXC" = '' #neoscrypt
"QBIC" = '' #neoscrypt
"RAP" = '' #neoscrypt
"SLC" = '' #neoscrypt
"SPLB" = '' #neoscrypt
"STONE" = '' #neoscrypt
"SUN" = '' #neoscrypt
"TUN" = '' #neoscrypt
"TZC" = '' #neoscrypt
"UFO" = '' #neoscrypt
"VIVO" = '' #neoscrypt
"XZX" = '' #neoscrypt
"ZCR" = '' #neoscrypt
"ZOC" = '' #neoscrypt
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
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
	API = "Ccminer"
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        Port = 4069
        Wrap = $false
        URI = $Uri
	BUILD = $Build
       }
    }
}
