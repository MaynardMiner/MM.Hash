. .\IncludeCoin.ps1

    $AllStats = if(Test-Path "./Stats"){Get-ChildItemContent "./Stats"}

    $AllStats | ForEach-Object{
      if($_.Content.Live -eq 0)
       {
        $Removed = Join-Path "./Stats" "$($_.Name).txt"
        $Change = $($_.Name) -replace "HashRate","TIMEOUT"
        if(Test-Path (Join-Path "./Timeout" "$($Change).txt"))
        {Remove-Item (Join-Path "./Timeout" "$($Change).txt")
	}
	Remove-Item $Removed
        Write-Host "$($_.Name) Hashrate and Timeout Notification was Removed"
        }
       }
       Write-Host "Cleared Timeouts" -ForegroundColor Red
