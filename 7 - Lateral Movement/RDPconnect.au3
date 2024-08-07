#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

; Define the RDP connection settings
Global $sFullAddress = "lab-fff5d028-cc36-476e-90f3-a7c38de9c749.eastus.cloudapp.azure.com:7054"
Global $sUsername = "~\gcuuser"
Global $sPassword = "Red.vine1"
Global $sRdpFile = @ScriptDir & "\connection.rdp"

; Store the credentials using cmdkey
RunWait(@ComSpec & " /c cmdkey /generic:" & $sFullAddress & " /user:" & $sUsername & " /pass:" & $sPassword, "", @SW_HIDE)

; Create the RDP file content
Global $sRdpContent = "full address:s:" & $sFullAddress & @CRLF & _
    "prompt for credentials:i:0" & @CRLF & _
    "username:s:" & $sUsername & @CRLF & _
    "enablecredsspsupport:i:1" & @CRLF & _
    "authentication level:i:2" & @CRLF

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

Func BinaryToHexString($binary)
    Local $hexString = ""
    For $i = 1 To StringLen($binary)
        $hexString &= Hex(BitAND(Asc(StringMid($binary, $i, 1)), 0xFF), 2)
    Next
    Return $hexString
EndFunc
