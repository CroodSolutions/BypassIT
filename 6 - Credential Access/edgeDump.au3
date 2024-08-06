#include <File.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

; Set the path to your Edge user data directory
Local $edgeDataPath = @LocalAppDataDir & "\Microsoft\Edge\User Data"

; Set the backup destination to the root directory in a folder called 'tmp'
Local $backupPath = "C:\tmp\EdgeBackup_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN

; Create the backup directory
DirCreate($backupPath)

; Function to copy a directory
Func _CopyDirectory($source, $destination)
    DirCreate($destination)
    FileCopy($source & "\*.*", $destination, $FC_OVERWRITE + $FC_CREATEPATH)

    Local $search = FileFindFirstFile($source & "\*.*")
    While 1
        Local $file = FileFindNextFile($search)
        If @error Then ExitLoop

        If @extended Then
            If $file <> "." And $file <> ".." Then
                _CopyDirectory($source & "\" & $file, $destination & "\" & $file)
            EndIf
        EndIf
    WEnd
    FileClose($search)
EndFunc

; Backup important Edge data
_CopyDirectory($edgeDataPath & "\Default", $backupPath & "\Default")

; Backup additional profiles if they exist
Local $search = FileFindFirstFile($edgeDataPath & "\Profile *")
While 1
    Local $profile = FileFindNextFile($search)
    If @error Then ExitLoop

    _CopyDirectory($edgeDataPath & "\" & $profile, $backupPath & "\" & $profile)
WEnd
FileClose($search)

; Backup the 'Local State' file
FileCopy($edgeDataPath & "\Local State", $backupPath & "\Local State", $FC_OVERWRITE)
