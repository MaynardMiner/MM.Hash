$Path = '.\Bin\z-enemy-Windows-CCDevices1-Algo\z-enemy.exe'
$URI = 'https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v2.0/z-enemy.1-12-cuda9.2-public.zip'
$Build = "Zip"

if($CCDevices1 -ne ''){$Devices = $CCDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#X16R
#X16S
#Aergo

$Commands = [PSCustomObject]@{
"x16r" = ''
"x16s" = ''
"aeriumX" = ''
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
  [PSCustomObject]@{
    MinerName = "z-enemy"
    Type = "NVIDIA1"
    Path = $Path
    Devices = $Devices
    DeviceCall = "ccminer"
    Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algorithm($_)).User1) -p $($Pools.(Get-Algorithm($_)).Pass1) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
    Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
          	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
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
   MinerName = "z-enemy"
   Type = "NVIDIA1"
   Path = $Path
   Devices = $Devices
   DeviceCall = "ccminer"
   Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4068 -u $($_.User1) -p $($_.Pass1) $($Commands.$($_.Algorithm))"
   HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
   API = "Ccminer"
   Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
                MinerPool = "$($_.Name)"
   Port = 4068
   Wrap = $false
   URI = $Uri
   BUILD = $Build
   }
  }
 }
