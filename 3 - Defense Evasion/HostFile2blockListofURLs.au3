#comments-start 

Note that this one needs to be compiled to an executable and only works if you run as administrator.  Some AV products may block attempts to supress their communicaiton via host file sinkhole, and even product by product exact settings could be a factor.  

#comments-end

#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

Global $sHostFile = @SystemDir & "\drivers\etc\hosts"
Global $aDomains = ["example1.com", "example2.com", "example3.com"] ; Add more domains as needed
Global $sRedirectIP = "127.0.0.1"

If Not FileExists($sHostFile) Then
    FileWrite($sHostFile, "")
EndIf

Global $hFile = FileOpen($sHostFile, $FO_APPEND)
If $hFile = -1 Then
    MsgBox($MB_SYSTEMMODAL, "Error", "Unable to open hosts file: " & $sHostFile)
    Exit
EndIf

For $i = 0 To UBound($aDomains) - 1
    FileWriteLine($hFile, $sRedirectIP & " " & $aDomains[$i])
    FileWriteLine($hFile, $sRedirectIP & " www." & $aDomains[$i])
Next

FileClose($hFile)

MsgBox($MB_SYSTEMMODAL, "Success", "Hosts file updated to redirect specified domains to 127.0.0.1")

Exit
