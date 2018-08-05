$Path = ".\Bin\tpruvot-Linux-CCDevices3\ccminer-NVIDIA3"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/tpruvot-9-1.zip"
$Build = "Zip"


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
"Qubit" = ''
"Keccak" = ''
"Blakecoin" = ''
"Skunk" = ''
"Keccakc" = ''
"X12" = ''
"Sib" = ''
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
   {
        [PSCustomObject]@{
        Symbol = (Get-Algorithm($_))
        MinerName = "ccminer-NVIDIA3"
        Type = "NVIDIA3"
        Path = $Path
        Devices = $Devices
        DeviceCall = "ccminer"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algorithm($_)).User3) -p $($Pools.(Get-Algorithm($_)).Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
        Port = 4070
        API = "Ccminer"
        Wrap = $false
        URI = $Uri
        BUILD = $Build
	Algo = "$($_)"
        }
       }
    }

     $Pools.PSObject.Properties.Value | Where-Object {$Commands."$($_.Algorithm)" -ne $null} | ForEach {
      if("$($_.Coin)" -eq "Yes")
      {
        [PSCustomObject]@{
          Symbol = $_.Symbol
         MinerName = "ccminer-NVIDIA3"
         Type = "NVIDIA3"
         Path = $Path
         Devices = $Devices
         DeviceCall = "ccminer"
         Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4070 -u $($_.User3) -p $($_.Pass3) $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "Ccminer"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
         Port = 4070
	 MinerPool = "$($_.Name)"
         Wrap = $false
         URI = $Uri
         BUILD = $Build
	 Algo = "$($_.Algorithm)"
         }
        }
       }
    
