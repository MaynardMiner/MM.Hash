$Path = ".\Bin\krnlx\5"
$Uri = "https://github.com/krnlx/ccminer-xevan.git"
$Build = "Linux"
$Distro = "Linux"

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CCDevices3 -ne ''){$Devices = $CCDevices3}
if($GPUDevices3 -ne ''){$Devices = $GPUDevices3}

#Algorithms:
#Xevan

$Commands = [PSCustomObject]@{
"Xevan" = ''
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
   {       
    [PSCustomObject]@{
    MinerName = "ccminer"
    Type = "NVIDIA3"
    Path = $Path
    Distro = $Distro
    Devices = $Devices
    Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4071 -u $($Pools.(Get-Algo($_)).User3) -p $($Pools.(Get-Algo($_)).Pass3) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
    Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
    Port = 4071
    API = "Ccminer"
    Wrap = $false
    URI = $Uri
    BUILD = $Build
    }
  }
}
