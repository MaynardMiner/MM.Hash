param(
        [Parameter(Mandatory=$false)]
        [String]$Type
     )

     Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
     $Log = Get-Content "$($Type).log"
$Log | Select -Last 100
