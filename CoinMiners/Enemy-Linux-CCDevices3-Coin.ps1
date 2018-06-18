$Path = '.\Bin\z-enemy-Linux\6'
$Build = "Linux"
$Distro = "Linux"

$Devices = $CCDevices3

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S
#Aergo

$Commands = [PSCustomObject]@{
"PROTON" = '' #x16r
"RVN" = '' #x16r
"XMN" = '' #x16r
"CPR" = '' #x16s
"PGN" = '' #x16s
"RABBIT" = '' #x16s
"REDN" = '' #x16s
"AEX" = '' #Aergo

}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "z-enemy"
        Type = "NVIDIA3"
        Path = $Path
        Distro = $Distro
        Devices = $Devices
       Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4071 -u $($Pools.$_.User3) -p $($Pools.$_.Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        Port = 4071
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
     }
    }

