#include <Array.au3>
#include <File.au3>


; Define the output file path
Global $outputFilePath = @ScriptDir & "\output.txt"
FileDelete($outputFilePath) ; Delete the file if it already exists

; Run the systeminfo command and capture the output
Local $systemInfo = RunCommand("systeminfo")

; Run the arp -a command and capture the output
Local $arpInfo = RunCommand("arp -a")

; Combine the outputs
Local $results = "System Information:" & @CRLF & $systemInfo & @CRLF & @CRLF & "ARP Information:" & @CRLF & $arpInfo

; Write the results to the output file
FileWrite($outputFilePath, $results)

; Function to run a command and capture the output
Func RunCommand($cmd)
    Local $stdout = ""
    Local $handle = Run(@ComSpec & " /c " & $cmd, "", @SW_HIDE, $STDOUT_CHILD)
    If $handle = 0 Then
        MsgBox(16, "Error", "Failed to execute command: " & $cmd)
        Return ""
    EndIf
    While 1
        $data = StdoutRead($handle)
        If @error Then ExitLoop
        $stdout &= $data
    WEnd
    Return $stdout
EndFunc
