#include <MsgBoxConstants.au3>
#include <Process.au3>

; Define the output file path
Global $outputFilePath = @ScriptDir & "\output.txt"
FileDelete($outputFilePath) ; Delete the file if it already exists

; PowerShell script content
Global $psScript = _
"function Test-Port {" & @CRLF & _
"    param (" & @CRLF & _
"        [string]$TargetHost," & @CRLF & _
"        [int]$Port" & @CRLF & _
"    )" & @CRLF & _
"    try {" & @CRLF & _
"        $tcpClient = New-Object System.Net.Sockets.TcpClient" & @CRLF & _
"        $tcpClient.Connect($TargetHost, $Port)" & @CRLF & _
"        $tcpClient.Close()" & @CRLF & _
"        return $true" & @CRLF & _
"    } catch {" & @CRLF & _
"        return $false" & @CRLF & _
"    }" & @CRLF & _
"}" & @CRLF & _
"" & @CRLF & _
"function Get-LocalNetworks {" & @CRLF & _
"    $networkInterfaces = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }" & @CRLF & _
"    $networks = @()" & @CRLF & _
"    foreach ($interface in $networkInterfaces) {" & @CRLF & _
"        if ($interface.IPAddress -ne $null -and $interface.IPSubnet -ne $null -and $interface.DefaultIPGateway -ne $null) {" & @CRLF & _
"            $network = New-Object PSObject -Property @{" & @CRLF & _
"                'Name' = $interface.Description" & @CRLF & _
"                'IPAddress' = $interface.IPAddress[0]" & @CRLF & _
"                'SubnetMask' = $interface.IPSubnet[0]" & @CRLF & _
"                'Gateway' = $interface.DefaultIPGateway[0]" & @CRLF & _
"            }" & @CRLF & _
"            $networks += $network" & @CRLF & _
"        }" & @CRLF & _
"    }" & @CRLF & _
"    return $networks" & @CRLF & _
"}" & @CRLF & _
"" & @CRLF & _
"# Define the output file path" & @CRLF & _
"$outputFilePath = Join-Path -Path (Get-Location) -ChildPath 'output.txt'" & @CRLF & _
"Remove-Item $outputFilePath -ErrorAction Ignore" & @CRLF & _
"" & @CRLF & _
"# Get local networks" & @CRLF & _
"$localNetworks = Get-LocalNetworks" & @CRLF & _
"" & @CRLF & _
"# Check if there are any active network interfaces" & @CRLF & _
"if ($localNetworks) {" & @CRLF & _
"    foreach ($network in $localNetworks) {" & @CRLF & _
"        $output = 'Scanning network interface: $($network.Name)`n'" & @CRLF & _
"        Add-Content -Path $outputFilePath -Value $output" & @CRLF & _
"        $targetIP = $network.IPAddress" & @CRLF & _
"        $openPorts = @()" & @CRLF & _
"        $portsToScan = 21,22,25,80,443,135,137,139,445,3389,8080,9000  # You can change the range of ports to scan here" & @CRLF & _
"        foreach ($port in $portsToScan) {" & @CRLF & _
"            $isOpen = Test-Port -TargetHost $targetIP -Port $port" & @CRLF & _
"            if ($isOpen) {" & @CRLF & _
"                $openPorts += $port" & @CRLF & _
"            }" & @CRLF & _
"        }" & @CRLF & _
"        $output = 'Host: $targetIP, Open Ports: $($openPorts -join ', ')`n'" & @CRLF & _
"        Add-Content -Path $outputFilePath -Value $output" & @CRLF & _
"    }" & @CRLF & _
"} else {" & @CRLF & _
"    Add-Content -Path $outputFilePath -Value 'No active network interfaces found. It seems you''re stranded in the network void!'" & @CRLF & _
"}"

; Save the PowerShell script to a temporary file
Global $psFile = @TempDir & "\network_scan.ps1"
FileDelete($psFile) ; Delete the file if it already exists
FileWrite($psFile, $psScript)

; Run the PowerShell script hidden
Local $iPID = Run(@ComSpec & " /c powershell -ExecutionPolicy Bypass -File " & $psFile, "", @SW_HIDE)

; Wait for the PowerShell script to complete by checking the process
While ProcessExists($iPID)
    Sleep(100)
WEnd

; Clean up the temporary PowerShell script file
FileDelete($psFile)

; Check if the output file was created
If FileExists($outputFilePath) Then
    MsgBox($MB_OK, "Success", "Network scan results have been written to " & $outputFilePath)
Else
    MsgBox($MB_OK, "Error", "Failed to write network scan results to " & $outputFilePath)
EndIf
