$Path = ".\Bin\krnlx-Windows-CCDevices2-Coin\ccminer_x86.exe"
$Uri = "https://github.com/MaynardMiner/Window-Krnlx/releases/download/v1.0/Ccminer_x86_krnlx.zip"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Devices = $CCDevices2

#Algorithms:
#Xevan

$Commands = [PSCustomObject]@{
"BSD" = '-i 18' #Xevan
"ELLI" = '-i 18' #Xevan
"ELP" = '-i 18' #Xevan
"HASH" = '-i 18' #Xevan
"KRAIT" = '-i 18' #Xevan
"URALS" = '-i 18' #Xevan
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {  
        if($Algorithm -eq "$($Pools.$_.Algorithm)")
         {
        [PSCustomObject]@{
            MinerName = "ccminer"
            Type = "NVIDIA2"
            Path = $Path
            Devices = $Devices
            Arguments = "-d $Devices -a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
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