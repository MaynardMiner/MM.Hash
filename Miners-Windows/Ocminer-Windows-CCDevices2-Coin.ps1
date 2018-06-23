$Path = ".\Bin\ocminer-Windows-CCDevices3-Coin\ccminer.exe"
$Uri = "https://github.com/ocminer/suprminer/releases/download/1.5/suprminer-1.5.7z"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#x17
#X16r
#X16s

$Commands = [PSCustomObject]@{
    #"PROTON" = '' #x16r
    #"RVN" = '' #x16r
    #"XMN" = '' #x16r
    #"PGN" = '' #x16s
    #"RABBIT" = '' #x16s
    #"REDN" = '' #x16s
    "MLM" = '' #x17
    "XSH-x17" = '' #x17
    "XVG" = '' #x17
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "ccminer"
        Type = "NVIDIA2"
        Path = $Path
        Devices = $Devices
        Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
        BUILD = $Build
         }
     }
  }
