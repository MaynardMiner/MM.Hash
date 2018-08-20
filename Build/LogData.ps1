param(
        [Parameter(Mandatory=$true)]
        [String]$DeviceCall,
        [Parameter(Mandatory=$true)]
        [String]$Type,
        [Parameter(Mandatory=$true)]
        [array]$GPUS,
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
        $Convert = [string]$GPUS -replace (","," ")
        $GPU = $Convert -split ' '
        $HashArray = @()
	      $A = $null
        $A = Get-Content $HashPath
        for($i = 0; $i -lt $GPU.Count; $i++)
        {
           $Selected = $GPU | Select -skip $i | Select -First 1
           $B = $A | Select-String  "GPU #$($Selected):" | Select -Last 1
           if([regex]::match($B,"MH/s").success  -eq $true){$Hash = "MH/s"}
           else{$Hash = "kH/s"}
           $C = $B -replace (" ","") -split "-" -split "$Hash" | Select-String -SimpleMatch "."
           $C | foreach{$HashArray += $_}
        }
        $J = $HashArray | % {iex $_}
        $K = @()
        $J | foreach{if($Hash -eq "MH/s"){$K += $($_)*1000}else{$K += $_}}
        $K -join ' ' | Set-Content  ".\Build\hashrates.sh"
        Write-Host "Sending HashRates To Hive $($K)" -foregroundcolor green
        $KK = $A | Select-String "ms" | Select-String " OK " | Select -Last 1
        $LL = $KK -split "]" | Select-String "/"
        $MM = $LL -split " -" | Select -First 1
        $NN = $MM -replace (" ", "     ")
        $OO = $NN -split ("     ") | Select -Last 1
        [string]$Accepted = $OO -Split "/" | Select -First 1
        [string]$Rejected = $OO -Split "/" | Select -Last 1
        $Accepted | Set-Content  ".\Build\accepted.sh"
        $Rejected | Set-Content  ".\Build\rejected.sh"
        Write-Host "Sending Acc/Rejected to Hive $Accepted $Rejected"
          }
       else{$Hashrates = 0}
       Start-Sleep -S 1
       $MinerAlgo | Out-File ".\Build\algo.sh"
       Write-Host "Current Algorithm is $MinerAlgo"
       Start-Sleep -S 8
          }
    "ccminer"
      {
       Write-Host "Logging not needed for this miner" -foregroundcolor yellow
       Start-Sleep -S 10
      }
    "claymore"
      {
       Write-Host "Logging not needed for this miner" -foregroundcolor yellow
       Start-Sleep -S 10
      }
    "dstm"
      {
       Write-Host "Logging not needed for this miner" -foregroundcolor yellow
       Start-Sleep -S 10
      }
    "ewbf"
      {
       Write-Host "Logging not needed for this miner" -foregroundcolor yellow
       Start-Sleep -S 10
      }
    } 
  }
