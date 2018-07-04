$Path = ".\Bin\Cuballoon-Windows-CUDevices3-Coin\cubal.oon.exe"
$Uri = "https://github.com/Belgarion/cuballoon/files/2143221/CuBalloon.1.0.2.Windows.zip"
$Build = "Zip"
$Distro = "Linux-Cu"

if($CUDevices3 -ne ''){$Devices = $CUDevices3}
if($GPUDevices3 -ne ''){$Devices = $GPUDevices3}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Balloon

$Commands = [PSCustomObject]@{
"DEFT" = '--cuda_threads 64 --cuda_blocks 48'
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.$_.Algorithm)")
  {
 [PSCustomObject]@{
     MinerName = "ccminer"
     Type = "NVIDIA3"
     Path = $Path
     Distro = $Distro
     Devices = $Devices
     Arguments = "-t 0 -a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4071 -u $($Pools.$_.User3) -p $($Pools.$_.Pass3) $($Commands.$_)"
     HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
     API = "Ccminer"
     Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
     Port = 4071
     Wrap = $false
     URI = $Uri
     BUILD = $Build
   Tracker = $($Pools.$_.Tracker)
    }
  }
}
