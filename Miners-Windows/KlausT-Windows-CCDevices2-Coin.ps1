$Path = ".\Bin\KlausT-Windows-CCDevices2-Coin\ccminer.exe"
$Uri = "https://github.com/KlausT/ccminer/releases/download/8.21/ccminer-821-cuda91-x64.zip"
$Build = "Windows"
$Distro = "Windows"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
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
            Type = "NVIDIA2"
            Path = $Path
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
