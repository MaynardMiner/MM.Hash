param(
        [Parameter(Mandatory=$false)]
        [String]$DeviceCall,
        [Parameter(Mandatory=$false)]
        [String]$Type,
        [Parameter(Mandatory=$false)]
        [array]$GPUS,
        [Parameter(Mandatory=$false)]
        [String]$WorkingDir,
        [Parameter(Mandatory=$false)]
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
        $Hash = @()
	      $A = $null
        $A = Get-Content $HashPath
        for($i = 0; $i -lt $GPU.Count; $i++)
        {
           $Selected = $GPU | Select -skip $i | Select -First 1
           $B = $A | Select-String  "GPU #$($Selected):" | Select -Last 1
           if($B -ne $null)
            {
             if([regex]::match($B,"MH/s").success  -eq $true){$CHash = "MH/s"}
             else{$CHash = "kH/s"}
             if([regex]::match($B,"MH/s").success  -eq $true){$Hash += "MH/s"}
             else{$Hash += "kH/s"}
             $C = $B -replace (" ","") -split "-" -split "$CHash" | Select-String -SimpleMatch "."
             $C | foreach{$HashArray += $_}
            }
           else
            {
             $Hash += "kH/s"
             $HashArray += 0
            }
        }
        $J = $HashArray | % {iex $_}
        $K = @()
        for($i = 0; $i -lt $Hash.Count; $i++)
          {
           $SelectedHash = $Hash | Select -skip $i | Select -First 1
           $SelectedPattern = $J | Select -skip $i | Select -First 1
           $SelectedPattern | foreach { if ($SelectedHash -eq "MH/s"){$K += $($_)*1000}else{$K += $_}}
          }
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
