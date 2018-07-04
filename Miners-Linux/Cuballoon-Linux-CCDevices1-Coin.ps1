$Path = ".\Bin\Cuballoon-Linux\4"
$Uri = "https://github.com/Belgarion/cuballoon/archive/1.0.2.zip"
$Build = "Linux-Zip-Build"
$Distro = "Linux-Cu"

if($CCDevices1 -ne ''){$Devices = $CCDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

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
     Tracker = $($Pools.$_.Tracker)
    }
  }
}