$Path = '.\Bin\Tpruvot-Allium-Windows-CCDevices2-Algo\ccminer-x64.exe'
$Uri = 'https://t.co/lFAnmZ4q1Z'
$Build = "Zip"
$Distro = "Windows"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Allium

$Commands = [PSCustomObject]@{
    "Allium" = '' #Allium
    "Cryptonight" = '' #XMR
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
    {    
    [PSCustomObject]@{
    MinerName = "ccminer"
    Type = "NVIDIA2"
    Path = $Path
    Pname = "ccminer-x64.exe"
    Distro = $Distro
    Devices = $Devices
    Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algo($_)).User2) -p $($Pools.(Get-Algo($_)).Pass2) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
    Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
    Port = 4070
    API = "Ccminer"
    Wrap = $false
    URI = $Uri
    BUILD = $Build
    }
  }
}
