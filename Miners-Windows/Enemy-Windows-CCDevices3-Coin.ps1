$Path = '.\Bin\z-enemy-Windows-CCDevices3-Coin\z-enemy.exe'
$URI = 'https://github.com/MaynardMiner/linux-enemy/releases/download/v1.0/z-enemy.1-11-public-final_v3.zip'

if($CCDevices3 -ne ''){$Devices = $CCDevices3}
if($GPUDevices3 -ne ''){$Devices = $GPUDevices3}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S

$Commands = [PSCustomObject]@{
"PROTON" = '' #x16r
"RVN" = '' #x16r
"XMN" = '' #x16r
"CPR" = '' #x16s
"PGN" = '' #x16s
"RABBIT" = '' #x16s
"REDN" = '' #x16s
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {  
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA3"
        Path = $Path
	Devices = $Devices
        Arguments = "-d $Devices -a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4071 -u $($Pools.$_.User3) -p $($Pools.$_.Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        API = "Ccminer"
        Port = 4071
        Wrap = $false
        URI = $Uri
	BUILD = $Build
         }
     }
  }
