$Path = "./Bin/JayDDee-Windows-CPUAVX2-Algo/cpuminer-avx2.exe"
$Uri = "https://github.com/JayDDee/cpuminer-opt/files/1996977/cpuminer-opt-3.8.8.1-windows.zip"

#Algorithms
#Yescrypt
#YescryptR16
#Lyra2z
#M7M
#cryptonightv7
#hodl
#lyra2re

$Commands = [PSCustomObject]@{
"Yescrypt" = ''
"YescryptR16" = ''
"Lyra2z" = ''
"M7M" = ''
"cryptonightv7" = ''
"hodl" = ''
"lyra2re" = ''
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
     {
       [PSCustomObject]@{
       MinerName = "cpuminer"
       Type = "CPU"
       Path = $Path
       Distro = $Distro
       Devices = $Devices
       Arguments = "-t 2 -a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4048 -u $($Pools.(Get-Algo($_)).User1) -p $($Pools.(Get-Algo($_)).Pass1) $($Commands.$_)"
       HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
       Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
       Port = 4048
       API = "Ccminer"
       Wrap = $false
       URI = $Uri
       BUILD = $Build
      }
     }
   }