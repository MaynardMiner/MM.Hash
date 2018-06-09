$Path = ".\Bin\KlausT-Windows-GPUDevices1\ccminer.exe"
$Uri = "https://github.com/KlausT/ccminer/releases/download/8.21/ccminer-821-cuda91-x64.zip"
$Build = "Windows"
$Distro = "Windows"

$Devices = $GPUDevices1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#NeoScrypt
#Groestl

$Commands = [PSCustomObject]@{
"GRS" = '' #Groestl
"AGN" = '' #Neoscrypt
"AIRIN" = '' #Neoscrypt
"BANQ" = '' #Neoscrypt
"CBS" = '' #Neoscrypt
"CRC" = '' #Neoscrypt
"CRZ" = '' #Neoscrypt
"CST" = '' #Neoscrypt
"CTF" = '' #Neoscrypt
"DIN" = '' #Neoscrypt
"DSR" = '' #Neoscrypt
"END" = '' #Neoscrypt
"FTC" = '' #Neoscrypt
"GBX" = '' #Neoscrypt
"GOA" = '' #Neoscrypt
"GUN" = '' #Neoscrypt
"HAL" = '' #Neoscrypt
"INN" = '' #Neoscrypt
"LUCKY" = '' #Neoscrypt
"MON" = '' #Neoscrypt
"NDASH" = '' #Neoscrypt
"NYX" = '' #Neoscrypt
"ONEX" = '' #Neoscrypt
"ORB" = '' #Neoscrypt
"PXC" = '' #Neoscrypt
"QBIC" = '' #Neoscrypt
"RAP" = '' #Neoscrypt
"SLC" = '' #Neoscrypt
"SNC" = '' #Neoscrypt
"SPLB" = '' #Neoscrypt
"STONE" = '' #Neoscrypt
"SUN" = '' #Neoscrypt
"TUN" = '' #Neoscrypt
"TZC" = '' #Neoscrypt
"UFO" = '' #Neoscrypt
"VIVO" = '' #Neoscrypt
"XZX" = '' #Neoscrypt
"ZCR" = '' #Neoscrypt
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
	PName = "ccminer.exe"
        Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4069 -u $($Pools.$_.User1) -p $($Pools.$_.Pass1) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
	API = "Ccminer"
        Port = 4069
        Wrap = $false
        URI = $Uri
	BUILD = $Build
	Tracker = $($Pools.$_.Tracker)
       }
    }
}
