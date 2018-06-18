$Path = '.\Bin\z-enemy-Linux\1'
$Build = "Linux"
$Distro = "Linux"

$Devices = $CCDevices1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S
#Aergo

$Commands = [PSCustomObject]@{
"X16r" = ''
"X16s" = ''
"Aergo" = ''
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
    Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algo($_)).User1) -p $($Pools.(Get-Algo($_)).Pass1) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
    Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
    Port = 4069
    API = "Ccminer"
    Wrap = $false
    URI = $Uri
    BUILD = $Build
  }
  }
}