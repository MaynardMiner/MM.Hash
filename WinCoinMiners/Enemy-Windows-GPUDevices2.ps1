. .\Include.ps1

$Path = '.\Bin\z-enemy-Windows-GPUDevices2\z-enemy.exe'
$URI = 'https://github.com/MaynardMiner/linux-enemy/releases/download/v1.0/z-enemy.1-11-public-final_v3.zip'

$Devices = $GPUDevices2

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
	Type = "NVIDIA2"
        Path = $Path
	Distro = $Distro
	PName = "z-enemy.exe"
	Devices = $Devices
       Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
	BUILD = $Build
      }
     }
    }
