param(
        [Parameter(Mandatory=$false)]
        [String]$Type
     )

     $Dir = (Split-Path $script:MyInvocation.MyCommand.Path)
     $LogStart = Join-Path (Split-Path $Dir) "Logs"
     Set-Location $LogStart
     $Log = Get-Content "$($Type).log"
     $Log | Select -Last 100
