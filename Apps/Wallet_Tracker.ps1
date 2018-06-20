param(
    [Parameter(Mandatory=$false)]
    [String]$Wallet1,
    [Parameter(Mandatory=$false)]
    [array]$Pool
	)

while ($true)
{
  Clear-Host
  
   $Wallet = $Wallet1
   
    if($Pool -eq "zergpool")
     {
    $GetWalletZergpool = Invoke-RestMethod http://zergpool.com/api/wallet?address=$Wallet -UseBasicParsing

    $GetWalletZergpool | foreach {

    $Get_Zerg_Currency = $_.currency
    $Get_Zerg_Unsold = $_.unsold
    $Get_Zerg_Balance = $_.balance
    $Get_Zerg_Unpaid = $_.unpaid
    $Get_Zerg_24h = $_.paid24h
    $Get_Zerg_Total = $_.total

    Write-Host "
    Zergpool $Wallet
    Currency = $Get_Zerg_Currency
    Unsold = $Get_Zerg_Unsold
    Balance = $Get_Zerg_Balance
    Unpaid = $Get_Zerg_Unpaid
    Total Paid  = $Get_Zerg_24h
    Total Earned = $Get_Zerg_Total"
    }
   }
   
  Start-Sleep -s 1
  
    if($Pool -eq "zpool")
     {
    $GetWalletZpool = Invoke-RestMethod https://www.zpool.ca/api/wallet?address=$Wallet -UseBasicParsing

    $GetWalletZpool | foreach {

    $Get_Z_Currency = $_.currency
    $Get_Z_Unsold = $_.unsold
    $Get_Z_Balance = $_.balance
    $Get_Z_Unpaid = $_.unpaid
    $Get_Z_24h = $_.paid24h
    $Get_Z_Total = $_.total

    Write-Host "
    Zpool $Wallet
    Currency = $Get_Z_Currency
    Unsold = $Get_Z_Unsold
    Balance = $Get_Z_Balance
    Unpaid = $Get_Z_Unpaid
    Total Paid  = $Get_Z_24h
    Total Earned = $Get_Z_Total"
    }
   }
  Start-Sleep -s 1 
  
    if($Pool -eq "phiphippool")
     {
    $GetWalletPhipool = Invoke-RestMethod https://www.phi-phi-pool.com/api/wallet?address=$Wallet -UseBasicParsing

    $GetWalletPhipool | foreach {

    $Get_Phi_Currency = $_.currency
    $Get_Phi_Unsold = $_.unsold
    $Get_Phi_Balance = $_.balance
    $Get_Phi_Unpaid = $_.unpaid
    $Get_Phi_24h = $_.paid24h
    $Get_Phi_Total = $_.total

    Write-Host "
    Phi-Phi-Pool $Wallet
    Currency = $Get_Phi_Currency
    Unsold = $Get_Phi_Unsold
    Balance = $Get_Phi_Balance
    Unpaid = $Get_Phi_Unpaid
    Total Paid  = $Get_Phi_24h
    Total Earned = $Get_Phi_Total"
    }
   }   
   
   Start-Sleep -s 1

  if($Pool -eq "Hashrefinery")
   {
    $GetWalletHashpool = Invoke-RestMethod http://pool.hashrefinery.com/api/wallet?address=$Wallet -UseBasicParsing

    $GetWalletHashpool | foreach {

    $Get_Hash_Currency = $_.currency
    $Get_Hash_Unsold = $_.unsold
    $Get_Hash_Balance = $_.balance
    $Get_Hash_Unpaid = $_.unpaid
    $Get_Hash_24h = $_.paid24h
    $Get_Hash_Total = $_.total

    Write-Host "
    Hashrefinery $Wallet
    Currency = $Get_Hash_Currency
    Unsold = $Get_Hash_Unsold
    Balance = $Get_Hash_Balance
    Unpaid = $Get_Hash_Unpaid
    Total Paid  = $Get_Hash_24h
    Total Earned = $Get_Hash_Total"
    }
   }
   
  if($Pool -eq "ahashpool")
   {
    $GetWalletApool = Invoke-RestMethod https://www.ahashpool.com/api/wallet/?address=$Wallet -UseBasicParsing

    $GetWalletApool | foreach {

    $Get_A_Currency = $_.currency
    $Get_A_Unsold = $_.unsold
    $Get_A_Balance = $_.balance
    $Get_A_Unpaid = $_.unpaid
    $Get_A_24h = $_.paid24h
    $Get_A_Total = $_.total

    Write-Host "
    ahashpool $Wallet
    Currency = $Get_A_Currency
    Unsold = $Get_A_Unsold
    Balance = $Get_A_Balance
    Unpaid = $Get_A_Unpaid
    Total Paid  = $Get_A_24h
    Total Earned = $Get_A_Total"
    }
   }
   
    Start-Sleep -s 300
}
