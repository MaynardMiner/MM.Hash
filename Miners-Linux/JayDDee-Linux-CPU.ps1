$Path = "./Bin/JayDDee/1"
$Uri = "https://github.com/JayDDee/cpuminer-opt.git"

$Build =  "Linux-Clean"


#Algorithms
#Yescrypt
#YescryptR16
#Lyra2z
#M7M

$Commands = [PSCustomObject]@{
    "Yescrypt" = ''
    "YescryptR16" = ''
    "Lyra2z" = ''
    "M7M" = ''
    "cryptonightv7" = ''
    "lyra2re" = ''
    "hodl" = ''
    }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object {$Algorithm -eq $($Pools.(Get-Algorithm($_)).Coin)} | ForEach-Object {
 if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
    MinerName = "cpuminer"
    Type = "CPU"
    Path = $Path
    Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4048 -u $($Pools.(Get-Algorithm($_)).CPUser) -p $($Pools.(Get-Algorithm($_)).CPUpass) $($Commands.$_)"
    HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
    Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
    Port = 4048
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
     MinerName = "cpuminer"
     Type = "CPU"
     Path = $Path
     Distro = $Distro
     Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4048 -u $($_.CPUser) -p $($_.CPUpass) $($Commands.$($_.Algorithm))"
     HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
     API = "Ccminer"
     Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
     Port = 4048
     Wrap = $false
     URI = $Uri
     BUILD = $Build
     }
    }
   }
