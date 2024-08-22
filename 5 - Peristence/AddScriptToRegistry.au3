; Define reg key and value for startup
Local $sRegKey = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
Local $sRegName = "notmaliciousatall"
Local $sScriptPath = @ScriptFullPath

; Check if the script is already in the startup registry
Local $sOutputVar = RegRead($sRegKey, $sRegName)

If $sOutputVar = $sScriptPath Then
    ; If the script is already there, it will run this code, so put whatever here
    MsgBox(64, "Startup Status", "I'm In! Ribbit")
Else
    ; Add the script to the startup registry
    RegWrite($sRegKey, $sRegName, "REG_SZ", $sScriptPath)
EndIf

Exit
