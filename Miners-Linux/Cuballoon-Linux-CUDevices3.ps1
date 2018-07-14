$Path = ".\Bin\Cuballoon-Linux\3"
$Uri = "https://github.com/Belgarion/cuballoon/archive/1.0.2.zip"
$Build = "Linux-Zip-Build"

if($CUDevices3 -ne ''){$Devices = $CUDevices3}
if($GPUDevices3 -ne ''){$Devices = $GPUDevices3}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Balloon

$Commands = [PSCustomObject]@{
"Balloon" = '--cuda_threads 64 --cuda_blocks 48'
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
    MinerName = "cuballoon"
    Type = "NVIDIA3"
    Path = $Path
    Devices = $Devices
    DeviceCall = "cuballoon"
    Arguments = "-t 0 -a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algorithm($_)).User3) -p $($Pools.(Get-Algorithm($_)).Pass3) $($Commands.$_)"
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
   MinerName = "cuballoon"
   Type = "NVIDIA3"
   Path = $Path
   Devices = $Devices
   DeviceCal = "cuballoon"
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
