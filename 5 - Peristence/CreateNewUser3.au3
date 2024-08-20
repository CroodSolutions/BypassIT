; AutoIt script to create a new local user account using the "net user" command

Func _CreateUser($sUsername, $sPassword, $sFullName)
    ; Command to create a new user
    Local $sCommand = 'net user "' & $sUsername & '" "' & $sPassword & '" /add /fullname:"' & $sFullName & '"'
    
    ; Run the command
    Local $iReturn = RunWait(@ComSpec & " /c " & $sCommand, "", @SW_HIDE)
    
    ; Check the result
    If $iReturn = 0 Then
        MsgBox(64, "Success", "The new local account was created successfully.")
    Else
        MsgBox(16, "Error", "Failed to create the new local account. Error code: " & $iReturn)
        Return $iReturn
    EndIf

    ; Command to add the user to the Administrators group
    $sCommand = 'net localgroup "Administrators" "' & $sUsername & '" /add'
    $iReturn = RunWait(@ComSpec & " /c " & $sCommand, "", @SW_HIDE)
    
    ; Check the result
    If $iReturn = 0 Then
        MsgBox(64, "Success", "The user was added to the Administrators group successfully.")
    Else
        MsgBox(16, "Error", "Failed to add the user to the Administrators group. Error code: " & $iReturn)
    EndIf
EndFunc

; Parameters for the new user
Local $sUsername = "NewUser"
Local $sPassword = "P@ssw0rd123!"
Local $sFullName = "New Local User"

; Create the user
_CreateUser($sUsername, $sPassword, $sFullName)
