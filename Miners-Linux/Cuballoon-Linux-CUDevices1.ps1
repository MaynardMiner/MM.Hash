$Path = ".\Bin\Cuballoon-Linux\1"
$Uri = "https://github.com/Belgarion/cuballoon/archive/1.0.2.zip"
$Build = "Linux-Zip-Build"

if($CUDevices1 -ne ''){$Devices = $CUDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

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
    Type = "NVIDIA1"
    Path = $Path
    Devices = $Devices
    DeviceCall = "cuballon"
    Arguments = "-t 0 -a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algorithm($_)).User1) -p $($Pools.(Get-Algorithm($_)).Pass1) $($Commands.$_)"
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
   MinerName = "cuballoon"
   Type = "NVIDIA1"
   Path = $Path
   Devices = $Devices
   DeviceCall = "cuballoon"
   Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4068 -u $($_.User1) -p $($_.Pass1) $($Commands.$($_.Algorithm))"
   HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
   API = "Ccminer"
   Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
   Port = 4068
   Wrap = $false
   URI = $Uri
   BUILD = $Build
   }
  }
 }

