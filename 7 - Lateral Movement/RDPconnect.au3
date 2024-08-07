#comments-start 

You will need to update the address and username for this script to work.  While I tried to get this to pass along the password for a more seamless experience, that part did not really work, in the sense that it prompted for it anyway.  That said, it does not really matter, because if you are in this stage of an engagement it ment that credential access gave you what you needed to connect to another host, so typing it in again is probably not a big deal.  

#comments-end

#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

; Define the RDP connection settings
Global $sFullAddress = "URL:port"
Global $sUsername = "~\username"
Global $sPassword = "Password"
Global $sRdpFile = @ScriptDir & "\connection.rdp"

; Store the credentials using cmdkey
RunWait(@ComSpec & " /c cmdkey /generic:" & $sFullAddress & " /user:" & $sUsername & " /pass:" & $sPassword, "", @SW_HIDE)

; Create the RDP file content
Global $sRdpContent = "full address:s:" & $sFullAddress & @CRLF & _
    "prompt for credentials:i:0" & @CRLF & _
    "username:s:" & $sUsername & @CRLF

; Write the RDP file
Global $hFile = FileOpen($sRdpFile, $FO_OVERWRITE)
If $hFile = -1 Then
    MsgBox($MB_SYSTEMMODAL, "Error", "Unable to create the RDP file.")
    Exit
EndIf

FileWrite($hFile, $sRdpContent)
FileClose($hFile)

; Launch the RDP connection
Run("mstsc.exe " & $sRdpFile)

