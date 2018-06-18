$Path = ".\Bin\EWBF-Windows-EWBFDevices2-Algo\miner.exe"
$Uri = "https://github.com/nanopool/ewbf-miner/releases/download/v0.3.4b/Zec.miner.0.3.4b.zip"

$Devices = $EWBFDevices2


$Commands = [PSCustomObject]@{

"Equihash" = ''

}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
   if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
    {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA1"
        Path = $Path
	      Distro =  $Distro
	      Devices = $Devices
        Arguments = "--api 0.0.0.0:42002 --server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --fee 0 --solver 0 --eexit 1 --user $($Pools.(Get-Algo($_)).User2) --pass $($Pools.(Get-Algo($_)).Pass2)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Week}
        Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
        API = "EWBF"
        Port = 42002
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
}