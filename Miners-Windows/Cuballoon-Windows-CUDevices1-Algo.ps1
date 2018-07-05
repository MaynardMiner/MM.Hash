$Path = ".\Bin\Cuballoon-Windows-CUDevices1-Algo\cuballoon.exe"
$Uri = "https://github.com/Belgarion/cuballoon/files/2143221/CuBalloon.1.0.2.Windows.zip"
$Build = "Zip"
$Distro = "Linux-Cu"

if($CUDevices1 -ne ''){$Devices = $CUDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Balloon

$Commands = [PSCustomObject]@{
"Balloon" = '--cuda_threads 64 --cuda_blocks 48'
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
   {
    [PSCustomObject]@{
    MinerName = "ccminer"
    Type = "NVIDIA1"
    Path = $Path
    Distro = $Distro
    Devices = $Devices
    Arguments = "-t 0 -a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algo($_)).User1) -p $($Pools.(Get-Algo($_)).Pass1) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
    Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
    Port = 4069
    API = "cuballoon"
    Wrap = $false
    URI = $Uri
    BUILD = $Build
    }
  }
}
