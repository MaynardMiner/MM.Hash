param(
        [Parameter(Mandatory=$true)]
        [String]$DeviceCall,
        [Parameter(Mandatory=$true)]
        [String]$Type,
        [Parameter(Mandatory=$true)]
        [Int]$GPUS,
        [Parameter(Mandatory=$true)]
        [String]$WorkingDir,
        [Parameter(Mandatory=$true)]
        [String]$Miner_Algo
	
    )
 Set-Location $WorkingDir
 While($true)
 {
 $MinerAlgo = "$($Miner_Algo)"
 $HashPath = Join-Path ".\Build" "$($Type).log"
 switch($DeviceCall)
 {
  "TRex"
     {
     if(Test-Path $HashPath)
       {
	$A = $null
        $A = Get-Content $HashPath
        if([regex]::match($A,"/s").success -eq $true)
         {
          $B = $A | Select-String "GPU"
          if([regex]::match($B,"MH/s").success  -eq $true){$Hash = "MH/s"}
	  else{$Hash = "kH/s"}
          $T = $B | Select-String "$Hash"
          $D = $T -replace (" ","")
          $E = $D -split ":"
          $F = $E -split "$Hash"
          $G = $F | Select-String -SimpleMatch "."
	  $H = $G | Select -Last "$GPUS"
	  $I = @()
          $H | Foreach {$I += $_}
	  $J = $I | % {iex $_}
	  $K = @()
	  $J | foreach{if($Hash -eq "MH/s"){$K += $($_)*1000}else{$K += $_}}
          $K -join ' ' | Out-File ".\Build\hashrates.sh"
	  Write-Host "Sending HashRates To Hive $($K)"
	  $KK = $A | Select-String "-"
          $L = $KK -split "-"
          $M = $L | Select-String ":"
          $N = $M -split "] "
          $O = $N | Select-String "/"
          $P = $O -split "/"
          $Q = $P -replace (" ","")
          $R = $Q | Select -Last 2
          $Accepted = $R | Select -First 1
          $Rejected = $R | Select -Last 1 
          $Accepted | Out-File ".\Build\accepted.sh"
          $Rejected | Out-File ".\Build\rejected.sh"
       if(Test-Path $HashPath)
       {
        ##Total Hashrate
        $AA = Get-Content $HashPath
        if([regex]::match($AA,"/s").success -eq $true)
         {
          $BB = $AA | Select-String "/s" | Select-String "-"
	  if([regex]::match($BB,"MH/s").success  -eq $True){$Hash = "MH/s"}
	  else{$Hash = "kH/s"}
          $CC = $BB -replace (" ","")
          $DD = $CC -split "-"
          $EE = $DD | Select-String "$($Hash)" | Select -Last 1
          $FF = $EE -replace ("$($Hash)","")
	  try{$GG = [Double]$FF}
	  catch{$GG = 0}
	  if($Hash -eq "kH/s"){$Hashrates = $GG}
	  else{$Hashrates = [Double]$GG*1000}
          }
	else{$Hashrates = 0}
       }
       Start-Sleep -S 1
       Write-Host "Current Hashrate is $($Hashrates)"
       $Hashrates | Out-File ".\Build\totalhash.sh"
       Start-Sleep -S 1
       $MinerAlgo | Out-File ".\Build\algo.sh"
       Start-Sleep -S 8
          }
        }
      }
    } 
  }
