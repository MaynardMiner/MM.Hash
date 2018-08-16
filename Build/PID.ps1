param(
      [Parameter(Mandatory=$true)]
      [Array]$Name
   )

While($true)
 {
  $Name | foreach {
  if($_ -eq "miner"){$Title = "MM.Hash"}
  else{$Title = "$($_)"}
  Write-Host "Checking To See if Miner $($_) Is Running"
  $MinerTestPath = Test-Path ".\PID\$($_)_PID.txt"
  if($MinerTestPath)
   {
    $MinerContent = Get-Content ".\PID\$($_)_PID.txt"
    if($MinerContent -ne $null)
     {
      Write-Host "Miner Name is $Title"
      Write-Host "Miner Process Id is Currently $($MinerContent)" -foregroundcolor yellow
      $MinerProcess = Get-Process -Id $MinerContent -ErrorAction SilentlyContinue
      if($MinerProcess -ne $null -or $MinerProcess.HasExited -eq $false)
       {
       Write-Host "$($Title) Status: Is Currently Running" -foregroundcolor green
       }
      else
       {
        $Status = "Failed"
        if($Title -eq "MM.Hash")
        {
         Start-Process "screen" -ArgumentList "-S NVIDIA1 -X quit"
         Start-Process "screen" -ArgumentList "-S NVIDIA2 -X quit"
         Start-Process "screen" -ArgumentList "-S NVIDIA3 -X quit"
         Start-Process "screen" -ArgumentList "-S CPU -X quit"
         Start-Process "screen" -ArgumentList "-S miner -X quit"
         Start-Process "screen" -ArgumentList "-S LogData -X quit"
         Start-Process "screen" -ArgumentList "-S PIDInfo -X quit"
       }
     }
    }
    else
     {
      $Status = "Failed"
      Write-Host "$($Title) Status: Miner Is Not Running!" -foregroundcolor red
      if($Title -eq "MM.Hash")
       {
        Start-Process "screen" -ArgumentList "-S NVIDIA1 -X quit"
        Start-Process "screen" -ArgumentList "-S NVIDIA2 -X quit"
        Start-Process "screen" -ArgumentList "-S NVIDIA3 -X quit"
        Start-Process "screen" -ArgumentList "-S CPU -X quit"
        Start-Process "screen" -ArgumentList "-S miner -X quit"
        Start-Process "screen" -ArgumentList "-S LogData -X quit"
        Start-Process "screen" -ArgumentList "-S PIDInfo -X quit"
       }
     }
    }
  }
 Start-Sleep -S 5
 }

