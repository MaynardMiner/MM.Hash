$Path = ".\Bin\EWBF-Linux-EWBFDevices1\miner"
$Uri = "https://github.com/nanopool/ewbf-miner/releases/download/v0.3.4b/Zec.miner.0.3.4b.Linux.Bin.tar.gz"
$Build = "Linux-Zip"
$Distro = "Linux-EWBF"

$Devices = $EWBFDevices1


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
            Arguments = "--api 0.0.0.0:42001 --server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --fee 0 --solver 0 --eexit 1 --user $($Pools.(Get-Algo($_)).User1) --pass $($Pools.(Get-Algo($_)).Pass1)$($Commands.$_)"
            HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
            Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
            API = "EWBF"
            Port = 42001
            Wrap = $false
            URI = $Uri
            BUILD = $Build
      }
    }
}
