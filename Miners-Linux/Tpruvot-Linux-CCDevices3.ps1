$Path = ".\Bin\tpruvot\3"
$Uri = "https://github.com/tpruvot/ccminer.git"
$Build = "Linux"

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
"Keccakc" = ''
"X12" = ''
"Phi" = ''
"Sib" = ''
"Allium" = ''
"Phi2" = ''
"Nist5" = ''
"Hsr" = ''
"C11" = ''
"Quark" = ''
"Blake2s" = ''
"Skein" = ''
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Coin)")
   {
        [PSCustomObject]@{
        MinerName = "ccminer"
        Type = "NVIDIA3"
        Path = $Path
        Devices = $Devices
        DeviceCall = "ccminer"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algorithm($_)).User3) -p $($Pools.(Get-Algorithm($_)).Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
        Port = 4070
        API = "Ccminer"
        Wrap = $false
        URI = $Uri
        BUILD = $Build
        }
       }
    }

     $Pools.PSObject.Properties.Value | Where-Object {$Commands."$($_.Algorithm)" -ne $null} | ForEach {
      if("$($_.Coin)" -eq "Yes")
      {
        [PSCustomObject]@{
         MinerName = "ccminer"
         Type = "NVIDIA3"
         Path = $Path
         Devices = $Devices
         DeviceCall = "ccminer"
         Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4070 -u $($_.User3) -p $($_.Pass3) $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "Ccminer"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
         Port = 4070
         Wrap = $false
         URI = $Uri
         BUILD = $Build
         }
        }
       }
    
