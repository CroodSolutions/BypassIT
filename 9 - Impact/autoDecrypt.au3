#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         BypassIT Research Team

 Script Function:
    Decrypts all encrypted files in the current user's Documents directory,
    including binary files like images. Prompts for password and logs operations.

#ce ----------------------------------------------------------------------------

#include <Crypt.au3>
#include <File.au3>
#include <Array.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <Date.au3>

; Set the folder path to current user's Documents directory
Local $folderPath = @MyDocumentsDir
Local $logFilePath = @ScriptDir & "\\decryption_log.txt"

; Function to log messages
Func LogMessage($message)
    Local $timestamp = _NowCalc()
    Local $logEntry = $timestamp & " - " & $message & @CRLF
    FileWrite($logFilePath, $logEntry)
    ConsoleWrite($logEntry) ; Also write to console for immediate feedback
EndFunc

; Prompt for password
Local $password = InputBox("Decryption Password", "Enter the decryption password:", "", "*")
If @error Then
    LogMessage("Decryption cancelled: No password entered")
    MsgBox($MB_ICONERROR, "Error", "Decryption cancelled: No password entered")
    Exit
EndIf

LogMessage("Decryption process started for directory: " & $folderPath)

; Function to recursively decrypt files in a directory
Func DecryptFiles($directory, ByRef $decryptedCount, ByRef $failedCount)
    Local $search = FileFindFirstFile($directory & "\\*")
    If $search = -1 Then
        LogMessage("No files found in: " & $directory)
        Return
    EndIf

    Local $file, $filePath
    While 1
        $file = FileFindNextFile($search)
        If @error Then ExitLoop

        $filePath = $directory & "\\" & $file

        ; If it's a directory, recursively decrypt its contents
        If StringInStr(FileGetAttrib($filePath), "D") Then
            DecryptFiles($filePath, $decryptedCount, $failedCount)
            ContinueLoop
        EndIf

        ; Only process .encrypted files
        If StringRight($file, 10) <> ".encrypted" Then
            ContinueLoop
        EndIf

        LogMessage("Attempting to decrypt: " & $filePath)

        ; Read the file as binary
        Local $encryptedContent = FileRead($filePath)
        If @error Then
            LogMessage("Error: Failed to read file: " & $filePath & " (Error code: " & @error & ")")
            $failedCount += 1
            ContinueLoop
        EndIf

        ; Decrypt the file content
        Local $decryptedContent = _Crypt_DecryptData($encryptedContent, $password, $CALG_AES_256)

        If @error Then
            LogMessage("Error: Failed to decrypt file: " & $filePath & " (Error code: " & @error & ")")
            $failedCount += 1
            ContinueLoop
        EndIf

        ; Write the decrypted content back to the file (without .encrypted extension)
        Local $originalFilePath = StringTrimRight($filePath, 10)
        If FileWrite($originalFilePath, $decryptedContent) Then
            ; Delete the encrypted file
            If FileDelete($filePath) Then
                $decryptedCount += 1
                LogMessage("Successfully decrypted and deleted encrypted file: " & $filePath)
            Else
                LogMessage("Error: Decrypted but failed to delete encrypted file: " & $filePath & " (Error code: " & @error & ")")
            EndIf
        Else
            LogMessage("Error: Failed to write decrypted file: " & $originalFilePath & " (Error code: " & @error & ")")
            $failedCount += 1
        EndIf
    WEnd

    FileClose($search)
EndFunc

; Initialize counters
Local $decryptedCount = 0
Local $failedCount = 0

; Decrypt all encrypted files in the current user's Documents directory
DecryptFiles($folderPath, $decryptedCount, $failedCount)

; Display success message
If $decryptedCount > 0 Or $failedCount > 0 Then
    LogMessage($decryptedCount & " file(s) decrypted successfully")
    If $failedCount > 0 Then
        LogMessage($failedCount & " file(s) failed to decrypt")
    EndIf
    ConsoleWrite(@CRLF & "Decryption Complete" & @CRLF)
    ConsoleWrite($decryptedCount & " file(s) in " & $folderPath & " have been decrypted." & @CRLF)
    If $failedCount > 0 Then
        ConsoleWrite($failedCount & " file(s) failed to decrypt. Check the log for details." & @CRLF)
    EndIf
Else
    LogMessage("Error: No files were decrypted")
    ConsoleWrite(@CRLF & "Error: No files were decrypted. Please check the log for details." & @CRLF)
EndIf

LogMessage("Decryption process completed")

MsgBox($MB_ICONINFORMATION, "Decryption Complete", $decryptedCount & " file(s) decrypted successfully." & @CRLF & _
    $failedCount & " file(s) failed to decrypt." & @CRLF & @CRLF & _
    "Please check the log file for details: " & @CRLF & $logFilePath)