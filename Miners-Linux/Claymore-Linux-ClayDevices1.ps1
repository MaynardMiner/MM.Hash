$Path = '.\Bin\Claymore-Linux-ClayDevices1\clay-NVIDIA1'
$Uri = 'https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/Claymore-Linux.zip'

$Build = "Zip"

if($ClayDevices1 -ne ''){$Devices = $ClayDevices1}
if($GPUDevices1 -ne '')
 {
  $GPUEDevices1 = $GPUDevices1 -replace ',',''
  $Devices = $GPUEDevices1
 }

 $Commands = [PSCustomObject]@{
    "ethash" = '-esm 2'
    "daggerhashimoto" = '-esm 3 -estale 0'
    }

    $Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

    $Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
     {
        [PSCustomObject]@{
                Symbol = (Get-Algorithm($_))
	        MinerName = "clay-NVIDIA1"
                Type = "NVIDIA1"
                Path = $Path
                Devices = $Devices
                DeviceCall = "claymore"
                Arguments = "-mport -3333 -mode 1 -allcoins 1 -allpools 1 -epool $($Pools.(Get-Algorithm($_)).Protocol)://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -ewal $($Pools.(Get-Algorithm($_)).User1) -epsw $($Pools.(Get-Algorithm($_)).Pass1) -wd 0 -dbg -1 -eres 1 $($Commands.$_)"
                HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
                Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
                API = "claymore"
                Port = 3333
	        MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
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
        MinerName = "clay-NVIDIA1"
        Type = "NVIDIA1"
        Path = $Path
        Devices = $Devices
        DeviceCall = "claymore"
        Arguments = "-mport -3333 -mode 1 -allcoins 1 -allpools 1 -epool $($_.Protocol)://$($_.Host):$($_.Port) -ewal $($_.User1) -epsw $($_.Pass1) -wd 0 -dbg -1 -eres 1 $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
        Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
	 MinerPool = "$($_.Name)"
        API = "claymore"
        Port = 3333
        Wrap = $false
        URI = $Uri
        BUILD = $Build
	 Algo = "$($_.Algorithm)"
       }
      }
     }
