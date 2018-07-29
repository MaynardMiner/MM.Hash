$Path = ".\Bin\EWBF-Linux-EWBFDevices2\miner-NVIDIA2"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/EWBF_Equihash_miner_v0.zip"
$Build = "Zip"

if($EWBFDevices2 -ne ''){$Devices = $EWBFDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
 }

#Equihash192

$Commands = [PSCustomObject]@{
  "Equihash192" = '--algo 192_7 --pers ZERO_PoW' #Equihash192
  "Equihash144xsg" =  '--algo 144_5 --pers sngemPoW'
  "Equihash144btcz" = '--algo 144_5 --pers BitcoinZ'
  "Equihash144zel" = '--algo 144_5 --pers ZelProof'
  "Equihash-BTG" = '--algo 144_5 --pers BgoldPoW'
  "Equihash144safe" = '--algo 144_5 --pers Safecoin' 
  }


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
      Symbol = (Get-Algorithm($_))
	MinerName = "miner-NVIDIA2"
        Type = "NVIDIA2"
        Path = $Path
        Devices = $Devices
        DeviceCall = "ewbf"
        Arguments = "--api 0.0.0.0:42001 --server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User2) --pass $($Pools.(Get-Algorithm($_)).Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
        API = "EWBF"
        Port = 42001
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
    MinerName = "miner-NVIDIA2"
    Type = "NVIDIA2"
    Path = $Path
    Devices = $Devices
    DeviceCall = "ewbf"
    Arguments = "--api 0.0.0.0:42001 --server $($_.Host) --port $($_.Port) --user $($_.User2) --pass $($_.Pass2) $($Commands.$($_.Algorithm))"
    HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
    Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
	 MinerPool = "$($_.Name)"
    API = "EWBF"
    Port = 42001
    Wrap = $false
    URI = $Uri
    BUILD = $Build
   }
  }
 }
