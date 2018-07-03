$Path = ".\Bin\tpruvot-Windows-CCDevices3-Algo\ccminer-x64.exe"
$Uri = "https://github.com/tpruvot/ccminer/releases/download/2.3-tpruvot/ccminer-2.3-cuda9.7z"


if($CCDevices3 -ne ''){$Devices = $CCDevices3}
if($GPUDevices3 -ne ''){$Devices = $GPUDevices3}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#Lyra2v2 
#Keccak
#Skunk
#Tribus
#Phi
#Keccakc
#Lyra2z
#Bitcore
#Hmq1725
#Timetravel

$Commands = [PSCustomObject]@{
"Lyra2v2" = '' 
"Keccak" = ''
"Skunk" = ''
"Tribus" = ''
"Phi" = ''
"Keccakc" = ''
"Lyra2z" = ''
"Bitcore" = ''
"Hmq1725" = ''
"Timetravel" = ''
"Sib" = ''
"Phi2" = ''
"Allium" = ''
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
