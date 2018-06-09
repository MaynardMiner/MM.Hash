$Path = '.\Bin\Alexis78-Windows-GPUDevices2\ccminer.exe'
$Uri = 'https://github.com/nemosminer/ccminerAlexis78/releases/download/Alexis78-v1.2/ccminerAlexis78v1.2x64.7z'

$Devices=$GPUDevices2

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands = [PSCustomObject]@{
"AGNI" = '-i 25' #Nist5
"BWK" = '-i 25' #Nist5
"CXT" = '-i 25' #Nist5
"RGC" = '-i 25' #Nist5
"HSR" = '' #Hsr
"AXS" = '-i 20' #C11
"BHD" = '-i 20' #C11
"CHC" = '-i 20' #C11
"DXC" = '-i 20' #C11
"FLAX" = '-i 20' #C11
"IMC" = '-i 20' #C11
"ITZ" = '-i 20' #C11
"JLG" = '-i 20' #C11
"KGX" = '-i 20' #C11
"RCO" = '-i 20' #C11
"SPD" = '-i 20' #C11
"BTQ" = '-i 20' #Quark
"LOBS" = '' #Quark
"QRK" = '' #Quark
"XMX" = '' #Quark
"SIB" = '-i 21' #Sib
"NEVA" = '' #Blake2s
"TAJ" = '' #Blake2s
"XSH-blake2s" = '' #Blake2s
"XVG-blake2s" = '' #Blake2s
"ARGO" = '-i 28' #Skein
"AUR-skein" = '-i 28' #Skein
"BTPL" = '-i 28' #Skein
"CURV" = '-i 28' #Skein
"DGB-skein" = '-i 28' #Skein
"FRM" = '-i 28' #Skein
"LIZ" = '-i 28' #Skein
"PRTX" = '-i 28' #Skein
"SKC" = '-i 28' #Skein
"TIMEC" = '-i 28' #Skein
"UIS-skein" = '-i 28' #Skein
"ULT" = '-i 28' #Skein
"XMY-skein" = '-i 28' #Skein
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
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
	BUILD = $Build
         }
     }
  }