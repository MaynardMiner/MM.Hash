function Convert-DateString ([string]$Date, [string[]]$Format)
        {
          $result = New-Object DateTime

         $Convertible = [DateTime]::TryParseExact(
                $Date,
                $Format,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None,
                [ref]$result)

                if ($Convertible) { $result }
        }

Get-Process "vi" | Select -ExpandProperty StartTime | Out-String | foreach{
	
	  $StringDate = $_          
	  $Time = Convert-DateString -Date $StringDate -Format 'dd/MM\\yyyy HH:mm-ss'
	  Get-Date $Time

	   }
