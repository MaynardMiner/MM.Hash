. .\Include.ps1

$Path = '.\Bin\z-enemy-Linux\1'
$Build = "Linux"
$Distro = "Linux"

$Devices = $GPUDevices1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S

$Commands = [PSCustomObject]@{
"PROTON" = '' #x16r
"RVN" = '' #x16r
"XMN" = '' #x16r
"PGN" = '' #x16s
"RABBIT" = '' #x16s
"REDN" = '' #x16s
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "z-enemy"
	Type = "NVIDIA1"
        Path = $Path
	Distro = $Distro
	PName = "z-enemy.exe"
	Devices = $Devices
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
