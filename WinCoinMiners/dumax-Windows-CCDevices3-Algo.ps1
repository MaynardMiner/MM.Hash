$Path = '.\Bin\dumax-Windows-CCDevices3-Algo\ccminer.exe'
$Uri = 'https://github.com/DumaxFr/ccminer/releases/download/dumax-0.9.0/ccminer-dumax-0.9.0-w64.zip'
$Build = "Windows"
$Distro = "Windows"

$Devices = $CCDevices3

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#PHI2

$Commands = [PSCustomObject]@{
    "Phi2" = '' #LUX
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
