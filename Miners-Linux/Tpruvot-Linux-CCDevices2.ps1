$Path = ".\Bin\tpruvot-Linux-CCDevices2\ccminer-NVIDIA2"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/tpruvot-9-1.zip"
$Build = "Zip"


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
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
   {
       [PSCustomObject]@{
        Symbol = (Get-Algorithm($_))
        MinerName = "ccminer-NVIDIA2"
        Type = "NVIDIA2"
        Path = $Path
        Devices = $Devices
        DeviceCall = "ccminer"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algorithm($_)).User2) -p $($Pools.(Get-Algorithm($_)).Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
        Port = 4069
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
        Symbol = $_.Symbol
       MinerName = "ccminer-NVIDIA2"
       Type = "NVIDIA2"
       Path = $Path
       Devices = $Devices
       DeviceCall = "ccminer"
       Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4069 -u $($_.User2) -p $($_.Pass2) $($Commands.$($_.Algorithm))"
       HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
       API = "Ccminer"
       Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
       Port = 4069
       Wrap = $false
       URI = $Uri
       BUILD = $Build
       }
      }
     }
    
  
