$Path = '.\Bin\Tpruvot-Allium-Windows-CCDevices1-Algo\ccminer-x64.exe'
$Uri = 'https://t.co/lFAnmZ4q1Z'
$Build = "Windows"
$Distro = "Windows"

$Devices = $CCDevices1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Allium
#XMR

$Commands = [PSCustomObject]@{
    "Allium" = '' #Allium
    "XMR" = ''
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
    {  
    [PSCustomObject]@{
    MinerName = "ccminer"
    Type = "NVIDIA1"
    Pname = "ccminer-x64.exe"
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

