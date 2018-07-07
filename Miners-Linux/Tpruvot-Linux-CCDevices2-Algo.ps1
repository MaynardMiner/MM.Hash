$Path = ".\Bin\tpruvot\3"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "Linux"
$Distro = "Linux"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#Lyra2v2 
#Keccak
#Skunk
#Tribus
#Phi
#Keccakc
#X12
#Qubit (Not Used)
#Sib

$Commands = [PSCustomObject]@{
"Lyra2v2" = ''
"Qubit" = ''
"Keccak" = ''
"Blakecoin" = ''
"Skunk" = ''
"Tribus" = ''
"Phi" = ''
"Keccakc" = ''
"X12" = ''
"Sib" = ''
"Phi2" = ''
"Allium" = ''
"Nist5" = '-i 25'
"Hsr" = ''
"C11" = '-i 20'
"Quark" = ''
"Blake2s" = ''
"Skein" = '-i 28'
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
      if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
      { 
               [PSCustomObject]@{
                MinerName = "ccminer"
                Type = "NVIDIA2"
                Path = $Path
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
