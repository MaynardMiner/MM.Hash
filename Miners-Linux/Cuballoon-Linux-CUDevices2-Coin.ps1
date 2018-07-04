$Path = ".\Bin\Cuballoon-Linux\5"
$Uri = "https://github.com/Belgarion/cuballoon/archive/1.0.2.zip"
$Build = "Linux-Zip-Build"
$Distro = "Linux-Cu"

if($CUDevices2 -ne ''){$Devices = $CUDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Balloon

$Commands = [PSCustomObject]@{
"DEFT" = '--cuda_threads 64 --cuda_blocks 48'
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.$_.Algorithm))
  {
 [PSCustomObject]@{
     MinerName = "ccminer"
     Type = "NVIDIA2"
     Path = $Path
     Distro = $Distro
     Devices = $Devices
     Arguments = "-t 0 -a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
     HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
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