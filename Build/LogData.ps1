param(
        [Parameter(Mandatory=$true)]
        [String]$API,
        [Parameter(Mandatory=$true)]
        [String]$MinerPath,
        [Parameter(Mandatory=$true)]
        [Int]$GPUS,
        [Parameter(Mandatory=$true)]
        [String]$WorkingDir
    )
 Set-Location $WorkingDir

 While($true)
 {
 $HashPath = Join-Path $MinerPath "HashRate.log"
 switch($API)
 {
  "TRex"
     {
     if(Test-Path $MinerPath)
       {
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
	  Start-Sleep -S 10
          }
        }
      }
    } 
  }
