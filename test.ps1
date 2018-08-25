$ActiveMinerPrograms | foreach {
if(($BestMiners_Combo | Where Name -EQ $_.Name | Where Path -EQ $_.Path | Where Arguments -EQ $_.Arguments | Where Type -EQ $_.Type).count -gt 0)
{
 Write-Host "$_"
}
}