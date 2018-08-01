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
          Clear-Content ".\Build\hashrates.sh"
          $I -join ' ' | Out-File ".\Build\hashrates.sh"
          $HashType = $Hash -replace ("/s","s")
          Clear-Content ".\Build\hashtype.sh"
	  $HashType | Out-File ".\Build\hashtype.sh"
	
	  $BB = $A | Select-String "/s" | Select-String "-"
	  if([regex]::match($BB,"MH/s").success  -eq $True){$THash = "MH/s"}
	  else{$THash = "kH/s"}
          $CC = $BB -replace (" ","")
          $DD = $CC -split "-"
          $EE = $DD | Select-String "$($THash)" | Select -Last 1
          $FF = $EE -replace ("$($THash)","")
	  $GG = $FF
	  $FF | Out-File ".\Build\totalhash.sh"
	
	  $K = $A | Select-String "-"
          $L = $K -split "-"
          $M = $L | Select-String ":"
          $N = $M -split "]"
          $O = $N | Select-String "/"
          $P = $O -split "/"
          $Q = $P -replace (" ","")
          $R = $Q | Select -Last 2
          $Accepted = $R | Select -First 1
          $Rejected = $R | Select -Last 1 
          Clear-Content ".\Build\accepted.sh"
          $Accepted | Out-File ".\Build\accepted.sh"
          Clear-Content ".\Build\rejected.sh"
          $Rejected | Out-File ".\Build\rejected.sh"

	  Start-Sleep -S 10
          }
        }
      }
    } 
  }
