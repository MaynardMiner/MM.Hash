$Path = '.\Bin\z-enemy-Linux\4'
$Uri = 'https://github.com/MaynardMiner/linux-enemy/releases/download/v1.0/z-enemy.1-11-public-final_v3.zip'
$Build = "Linux-Zip"
$Distro = "Linux"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S
#Aergo

$Commands = [PSCustomObject]@{
"GRV" = '' #x16r
"PROTON" = '' #x16r
"RVN" = '' #x16r
"XMN" = '' #x16r
"BTNX" = '' #x16s
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
	Type = "NVIDIA2"
        Path = $Path
	Distro = $Distro
	PName = "z-enemy.exe"
	Devices = $Devices
       Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        Port = 4070
        Wrap = $false
        URI = $Uri
	BUILD = $Build
	Tracker = $($Pools.$_.Tracker)
      }
     }
    }
