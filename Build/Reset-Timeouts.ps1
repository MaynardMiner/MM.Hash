Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)

. .\IncludeCoin.ps1

$AllStats = if(Test-Path "/hive/custom/MM.Hash/Stats")
{
    Get-ChildItemContent "/hive/custom/MM.Hash/Stats" | ForEach {$_.Content | Add-Member @{Name = $_.Name} -PassThru} 
}

$Allstats | ForEach-Object{
    if($_.Live -eq 0)
     {
      $Removed = Join-Path "/hive/custom/MM.Hash/Stats" "$($_.Name).txt"
      $Change = $($_.Name) -replace "HashRate","TIMEOUT"
      if(Test-Path (Join-Path "/hive/custom/MM.Hash/Timeout" "$($Change).txt"))
       {
        Remove-Item (Join-Path "/hive/custom/MM.Hash/Timeout" "$($Change).txt")
       }
      Remove-Item $Removed
      $Message = "$($_.Name) Hashrate and Timeout Notification was Removed"
      $Message | Out-Host
     }
}

exit
