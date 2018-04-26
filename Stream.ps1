$Client = New-Object System.Net.Sockets.TcpClient localhost,4048
$Writer = New-Object System.IO.StreamWriter $Client.GetStream()
$Reader = New-Ojbect System.I0.StreamReader $Client.GetStream()

$Writer.WriteLine(summary)
$Request = $Reader.Readline()
