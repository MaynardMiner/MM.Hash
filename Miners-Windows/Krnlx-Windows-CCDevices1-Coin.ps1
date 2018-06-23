$Path = ".\Bin\krnlx-Windows-CCDevices1-Coin\ccminer_x86.exe"
$Uri = "https://github.com/MaynardMiner/Window-Krnlx/releases/download/v1.0/Ccminer_x86_krnlx.zip"


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CCDevices1 -ne ''){$Devices = $CCDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

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
            Type = "NVIDIA1"
            Path = $Path
            Devices = $Devices
            Arguments = "-d $Devices -a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4069 -u $($Pools.$_.User1) -p $($Pools.$_.Pass1) $($Commands.$_)"
            HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
            Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
            API = "Ccminer"
            Port = 4069
            Wrap = $false
            URI = $Uri
            BUILD = $Build
             }
         }
      }