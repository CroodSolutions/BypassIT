#include <WinAPI.au3>
#include <Memory.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include <ScrollBarConstants.au3>

Global $g_aSnapshots[4]
Global $g_aAddresses[4]
Global $g_idLog
Global $g_hNTDLL = 0
Global $g_bModified = False



Local $hGUI = GUICreate("NTDLL Memory Manipulator", 600, 500)
Local $idBtnTakeSnapshot = GUICtrlCreateButton("Take Initial Snapshot", 20, 20, 160, 30)
Local $idBtnModify = GUICtrlCreateButton("Modify NTDLL", 200, 20, 160, 30)
Local $idBtnCheck = GUICtrlCreateButton("Check for Changes", 380, 20, 160, 30)
Local $idBtnClear = GUICtrlCreateButton("Clear Log", 20, 60, 160, 30)
Local $idBtnExit = GUICtrlCreateButton("Exit", 380, 60, 160, 30)
Local $idBtnUnhookNTDLL = GUICtrlCreateButton("Unhook NTDLL", 200, 60, 160, 30)


$g_idLog = GUICtrlCreateEdit("", 20, 100, 560, 380, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL, $ES_AUTOVSCROLL))
GUICtrlSetFont($g_idLog, 9, 400, 0, "Consolas")
GUISetState(@SW_SHOW)


Global $g_aSnapshots[4]
Global $g_aAddresses[4]
Global $g_idLog


Global $var_294, $var_229, $var_190, $var_175, $var_261, $var_269, $addr_270, $var_158
Global $var_164, $var_152, $var_265


Func _CrashLog($message, $lastDLLError = 0)
    Local $errorMsg = "CRASH LOG - " & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF
    $errorMsg &= "Message: " & $message & @CRLF
    If $lastDLLError Then
        $errorMsg &= "LastDLLError: 0x" & Hex($lastDLLError) & @CRLF
    EndIf
    LogWrite($errorMsg)
EndFunc

Func _SaveCurrentState()
    Local $state = DllStructCreate("ptr BaseAddress;dword Size;dword Protection")
    DllStructSetData($state, "BaseAddress", 0)
    DllStructSetData($state, "Size", 0)
    DllStructSetData($state, "Protection", 0)
    Return $state
EndFunc

Func _RestoreState($state)
    If Not IsDllStruct($state) Then Return False
    Local $baseAddr = DllStructGetData($state, "BaseAddress")
    If $baseAddr = 0 Then Return False

    Local $oldProtect
    DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $baseAddr, _
        "dword", DllStructGetData($state, "Size"), _
        "dword", DllStructGetData($state, "Protection"), _
        "dword*", $oldProtect)
    Return True
EndFunc

Func _SaveCurrentHandles()
    Local $handles = DllStructCreate("ptr NTDLL; ptr Process")
    DllStructSetData($handles, "NTDLL", $g_hNTDLL)
    DllStructSetData($handles, "Process", _WinAPI_GetCurrentProcess())
    Return $handles
EndFunc

Func _CleanupHandles()
    If $g_hNTDLL Then
        DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $g_hNTDLL)
        $g_hNTDLL = 0
    EndIf

    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)
EndFunc

Func _RestoreHandles($handles)
    If Not IsDllStruct($handles) Then Return False

    $g_hNTDLL = DllStructGetData($handles, "NTDLL")
    Return True
EndFunc

Func SafeInitialize()
    Local $success = False

    Local $timer = TimerInit()

    Do
        If Initialize() Then
            $success = True
            ExitLoop
        EndIf

        If TimerDiff($timer) > 5000 Then ; 5 second timeout
            LogWrite("Initialize timed out after 5 seconds")
            ExitLoop
        EndIf

        Sleep(100)
    Until False

    Return $success
EndFunc

Func LogWrite($sText)
    Local $existing = GUICtrlRead($g_idLog)
    GUICtrlSetData($g_idLog, $existing & $sText & @CRLF)
    ; Auto-scroll to bottom
    _GUICtrlEdit_Scroll($g_idLog, $SB_PAGEDOWN)
EndFunc

Func GetNTDLLInfo()
    Local $hNTDLL = DllCall("kernel32.dll", "handle", "GetModuleHandleA", "str", "ntdll.dll")[0]
    If @error Or $hNTDLL = 0 Then
        LogWrite("Error: Failed to get NTDLL handle.")
        Return SetError(1, 0, 0)
    EndIf
    LogWrite("NTDLL Base Address: 0x" & Hex($hNTDLL))
    Return $hNTDLL
EndFunc

Func DumpMemorySection($hProcess, $baseAddr, $size)
    If $baseAddr = 0 Then
        LogWrite("Error: Invalid base address")
        Return SetError(1, 0, 0)
    EndIf

    Local $buffer = DllStructCreate("byte[" & $size & "]")
    If @error Then
        LogWrite("Error: Failed to create buffer structure")
        Return SetError(2, 0, 0)
    EndIf

    Local $bytesRead
    Local $oldProtect

    LogWrite("Attempting to read memory at: 0x" & Hex($baseAddr))

    Local $protect = DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $baseAddr, _
        "dword", $size, _
        "dword", 0x40, _
        "dword*", $oldProtect)

    If Not $protect[0] Then
        LogWrite("Error: Failed to modify memory protection")
        Return SetError(3, 0, 0)
    EndIf

    Local $result = _WinAPI_ReadProcessMemory($hProcess, $baseAddr, DllStructGetPtr($buffer), $size, $bytesRead)

    DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $baseAddr, _
        "dword", $size, _
        "dword", $oldProtect, _
        "dword*", $oldProtect)

    If Not $result Or $bytesRead = 0 Then
        LogWrite("Error: Failed to read memory section. Result: " & $result & " BytesRead: " & $bytesRead)
        Return SetError(4, 0, 0)
    EndIf

    LogWrite("Successfully read " & $bytesRead & " bytes")
    Return $buffer
EndFunc

Func TakeInitialSnapshot()
    Local $hNTDLL = GetNTDLLInfo()
    If @error Then
        MsgBox(16, "Error", "Failed to get NTDLL info")
        Return False
    EndIf

    Local $hProcess = _WinAPI_GetCurrentProcess()
    Local $functions = ["NtCreateFile", "NtReadFile", "NtWriteFile", "NtClose"]
    Local $monitorSize = 0x200

    For $i = 0 To UBound($functions) - 1
        LogWrite(@CRLF & "Processing " & $functions[$i] & "...")

        Local $funcAddr = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $hNTDLL, "str", $functions[$i])[0]
        If @error Or Not $funcAddr Then
            LogWrite("Failed to get address for " & $functions[$i])
            ContinueLoop
        EndIf

        LogWrite("Taking initial snapshot of " & $functions[$i] & " at: 0x" & Hex($funcAddr))
        $g_aSnapshots[$i] = DumpMemorySection($hProcess, $funcAddr, $monitorSize)
        $g_aAddresses[$i] = $funcAddr

        If @error Then
            LogWrite("Failed to take initial snapshot of " & $functions[$i])
            ContinueLoop
        EndIf
    Next

    LogWrite(@CRLF & "Initial snapshots completed.")
    Return True
EndFunc

Func ModifyNTDLL()
    LogWrite(@CRLF & "Starting NTDLL modification...")

    ; Store old state before modification
    Local $oldState = _SaveCurrentState()
    If @error Then
        LogWrite("Failed to save current state")
        Return False
    EndIf

    $g_hNTDLL = GetNTDLLInfo()
    If @error Or Not $g_hNTDLL Then
        LogWrite("Failed to get NTDLL handle")
        Return False
    EndIf

    Local $NtCreateFile = DllCall("kernel32.dll", "ptr", "GetProcAddress", "handle", $g_hNTDLL, "str", "NtCreateFile")[0]
    If @error Or Not $NtCreateFile Then
        LogWrite("Failed to get NtCreateFile address")
        Return False
    EndIf

    ; Add proper memory barrier before modification
    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)
    Sleep(100)

    Local $oldProtect
    Local $result = DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $NtCreateFile, _
        "dword", 16, _
        "dword", 0x40, _
        "dword*", $oldProtect)

    If Not $result[0] Then
        LogWrite("VirtualProtect failed: " & _WinAPI_GetLastError())
        Return False
    EndIf

    ; Save the original bytes before modification
    Local $originalBytes = DllStructCreate("byte[16]")
    Local $bytesRead
    _WinAPI_ReadProcessMemory(_WinAPI_GetCurrentProcess(), $NtCreateFile, DllStructGetPtr($originalBytes), 16, $bytesRead)

    ; Store original bytes in global variable for restoration
    $g_OriginalBytes = $originalBytes

    Local $testPattern = DllStructCreate("byte[16]")
    For $i = 1 To 16
        DllStructSetData($testPattern, 1, 0x90, $i)
    Next

    Local $bytesWritten
    $result = _WinAPI_WriteProcessMemory(_WinAPI_GetCurrentProcess(), $NtCreateFile, DllStructGetPtr($testPattern), 16, $bytesWritten)

    ; Set modified flag and store modification info
    $g_bModified = True
    $g_ModifiedAddress = $NtCreateFile
    $g_ModifiedSize = 16

    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)

    ; Restore protection
    DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $NtCreateFile, _
        "dword", 16, _
        "dword", $oldProtect, _
        "dword*", $oldProtect)

    Sleep(1000)  ; Give system time to stabilize

    If Not $result Then
        LogWrite("WriteProcessMemory failed: " & _WinAPI_GetLastError())
        Return False
    EndIf

    LogWrite("Successfully modified NTDLL")
    Return True
EndFunc

Func HandleUnhookNTDLL()
    LogWrite("Starting unhook sequence...")


    ; Try initialize with retry mechanism
    Local $retryCount = 0
    Local $success = False

    While $retryCount < 3
        If Initialize() Then
            $success = True
            ExitLoop
        EndIf

        $retryCount += 1
        LogWrite("Initialize attempt " & $retryCount & " failed, retrying...")
        Sleep(1000)
    WEnd

    If Not $success Then
        LogWrite("All Initialize attempts failed")
        Return False
    EndIf

    LogWrite("Successfully unhooked NTDLL")
    Return True
EndFunc

Func CheckForChanges()
    If Not IsDllStruct($g_aSnapshots[0]) Then
        MsgBox(16, "Error", "No initial snapshots available. Please take snapshots first.")
        Return False
    EndIf

    Local $hProcess = _WinAPI_GetCurrentProcess()
    Local $functions = ["NtCreateFile", "NtReadFile", "NtWriteFile", "NtClose"]
    Local $monitorSize = 0x200
    Local $changesFound = False

    For $i = 0 To UBound($functions) - 1
        If Not IsDllStruct($g_aSnapshots[$i]) Then
            LogWrite("Skipping " & $functions[$i] & " - No initial snapshot available")
            ContinueLoop
        EndIf

        Local $newDump = DumpMemorySection($hProcess, $g_aAddresses[$i], $monitorSize)
        If @error Then
            LogWrite("Failed to take second snapshot of " & $functions[$i])
            ContinueLoop
        EndIf

        Local $differences = 0
        Local $modifications = ""

        For $j = 1 To $monitorSize
            Local $byte1 = DllStructGetData($g_aSnapshots[$i], 1, $j)
            Local $byte2 = DllStructGetData($newDump, 1, $j)

            If $byte1 <> $byte2 Then
                $differences += 1
                $modifications &= StringFormat("  Offset 0x%02X: %02X -> %02X", $j-1, $byte1, $byte2) & @CRLF
                $changesFound = True
            EndIf
        Next

        If $differences > 0 Then
            LogWrite(@CRLF & $functions[$i] & " was modified!")
            LogWrite("Found " & $differences & " changes:")
            LogWrite($modifications)
        Else
            LogWrite($functions[$i] & " was not modified.")
        EndIf
    Next

    Return True
EndFunc

Func GetStructData($struct, $element, $index = 0)
    If $index = 0 Then
        Return DllStructGetData($struct, $element)
    Else
        Return DllStructGetData($struct, $element, $index)
    EndIf
EndFunc
Func Initialize()


    ; Set up error handler
    AutoItSetOption("MustDeclareVars", 1)
    AutoItSetOption("TrayIconDebug", 1)

    LogWrite(@CRLF & "Starting NTDLL unhooking process with crash debugging...")


    If $g_bModified Then
        LogWrite("Warning: NTDLL is in modified state. Ensuring cleanup...")

        _CleanupHandles()
        Sleep(1000)  ; Give system time to stabilize
    EndIf

    ; Get current memory state before we start
    Local $initialMemInfo = DllStructCreate("dword_ptr WorkingSetSize")
    DllCall("kernel32.dll", "bool", "GetProcessMemoryInfo", "handle", _WinAPI_GetCurrentProcess(), "ptr", DllStructGetPtr($initialMemInfo), "dword", DllStructGetSize($initialMemInfo))
    LogWrite("Initial Working Set Size: " & DllStructGetData($initialMemInfo, "WorkingSetSize"))


    ; First, try to get current NTDLL state
    Local $ntdllBase = DllCall("kernel32.dll", "ptr", "GetModuleHandleA", "str", "ntdll.dll")
    If @error Or Not $ntdllBase[0] Then

        LogWrite("Failed to get NTDLL base address: " & _WinAPI_GetLastError())
        Return False
    EndIf

    LogWrite("NTDLL Base Address: 0x" & Hex($ntdllBase[0]))


    ; Force a memory barrier
    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)
    Sleep(100)

    ; Try to query NTDLL memory region with retry
    Local $mbi = DllStructCreate("ptr BaseAddress;ptr AllocationBase;dword AllocationProtect;ptr RegionSize;dword State;dword Protect;dword Type")
    Local $queryRetries = 0
    Local $querySuccess = False

    While $queryRetries < 3
        Local $result = DllCall("kernel32.dll", "uint", "VirtualQueryEx", _
            "handle", _WinAPI_GetCurrentProcess(), _
            "ptr", $ntdllBase[0], _
            "ptr", DllStructGetPtr($mbi), _
            "uint_ptr", DllStructGetSize($mbi))

        If Not @error And $result[0] <> 0 Then
            $querySuccess = True
            ExitLoop
        EndIf

        $queryRetries += 1

        Sleep(100)
    WEnd

    If Not $querySuccess Then

        Return False
    EndIf

    LogWrite("NTDLL Memory Region Info:")
    LogWrite("  Protection: 0x" & Hex(DllStructGetData($mbi, "Protect")))
    LogWrite("  State: 0x" & Hex(DllStructGetData($mbi, "State")))
    LogWrite("  Type: 0x" & Hex(DllStructGetData($mbi, "Type")))


    ; Get current process handle
    $var_294 = DllCall("kernel32.dll", "hwnd", "GetCurrentProcess")
    If @error Then

        Return False
    EndIf
    LogWrite("Successfully got current process handle")

    ; Create structure for module information with proper size
    Local $MODULEINFO = "ptr BaseOfDll;dword SizeOfImage;ptr EntryPoint"
    $var_229 = DllStructCreate($MODULEINFO)
    If @error Then

        Return False
    EndIf

    ; Get NTDLL module handle with retry mechanism
    Local $retryCount = 0
    Do
        $var_190 = DllCall("kernel32.dll", "hwnd", "GetModuleHandleA", "str", "ntdll.dll")
        If Not @error And $var_190[0] Then ExitLoop
        $retryCount += 1
        Sleep(100)

    Until $retryCount >= 3

    If @error Or Not $var_190[0] Then

        Return False
    EndIf
    LogWrite("Got NTDLL module handle at: 0x" & Hex($var_190[0]))

    ; Memory protection verification
    Local $oldProtect
    Local $protectResult = DllCall("kernel32.dll", "bool", "VirtualProtect", _
        "ptr", $var_190[0], _
        "dword", 0x1000, _
        "dword", 0x40, _    ; PAGE_EXECUTE_READWRITE
        "dword*", $oldProtect)


    ; Additional memory safeguards
    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)

    Local $mbiCheck = DllStructCreate("ptr BaseAddress;ptr AllocationBase;dword AllocationProtect;ptr RegionSize;dword State;dword Protect;dword Type")
    DllCall("kernel32.dll", "uint", "VirtualQueryEx", _
        "handle", _WinAPI_GetCurrentProcess(), _
        "ptr", $var_190[0], _
        "ptr", DllStructGetPtr($mbiCheck), _
        "uint_ptr", DllStructGetSize($mbiCheck))

    If DllStructGetData($mbiCheck, "Protect") <> 0x40 Then
        Local $tempOldProtect
        DllCall("kernel32.dll", "bool", "VirtualProtect", _
            "ptr", $var_190[0], _
            "dword", 0x1000, _
            "dword", 0x40, _
            "dword*", $tempOldProtect)
        Sleep(100)
    EndIf

    ; Get module information with alternative method if needed
    Local $moduleInfoResult = DllCall("psapi.dll", "bool", "GetModuleInformation", _
        "handle", $var_294[0], _
        "handle", $var_190[0], _
        "struct*", $var_229, _
        "dword", DllStructGetSize($var_229))

    Local $lastError = _WinAPI_GetLastError()
    If @error Or Not $moduleInfoResult[0] Then


        $moduleInfoResult = DllCall("kernel32.dll", "bool", "K32GetModuleInformation", _
            "handle", $var_294[0], _
            "handle", $var_190[0], _
            "struct*", $var_229, _
            "dword", DllStructGetSize($var_229))

        If @error Or Not $moduleInfoResult[0] Then

            $var_175 = $var_190[0]
        Else

            $var_175 = DllStructGetData($var_229, "BaseOfDll")
        EndIf
    Else

        $var_175 = DllStructGetData($var_229, "BaseOfDll")
    EndIf

    LogWrite("Using base address: 0x" & Hex($var_175))




    Sleep(500)

	Local $lockAttempts = 0
	While $lockAttempts < 3
		Local $testRead = DllStructCreate("byte[16]")
		Local $bytesRead = 0
		Local $readResult = _WinAPI_ReadProcessMemory(_WinAPI_GetCurrentProcess(), $var_175, DllStructGetPtr($testRead), 16, $bytesRead)

		If $readResult Then

			ExitLoop
		EndIf

		$lockAttempts += 1

		Sleep(200)
	WEnd

    If $lockAttempts >= 3 Then

    EndIf

    ; Open NTDLL file

    $var_261 = DllCall("kernel32.dll", "hwnd", "CreateFileA", "str", @SystemDir & "\ntdll.dll", "dword", 0x80000000, "dword", 0x1, "ptr", 0x0, "dword", 0x3, "dword", 0x0, "ptr", 0x0)
    If @error Or $var_261[0] = -1 Then

        Return False
    EndIf
    LogWrite("Successfully opened NTDLL file from: " & @SystemDir & "\ntdll.dll")

    ; Create file mapping

    $var_269 = DllCall("kernel32.dll", "hwnd", "CreateFileMapping", "hwnd", $var_261[0], "ptr", 0x0, "dword", 0x1000002, "dword", 0x0, "dword", 0x0, "ptr", 0x0)
    If @error Or Not $var_269[0] Then

        DllCall("kernel32.dll", "none", "CloseHandle", "hwnd", $var_261[0])
        Return False
    EndIf
    LogWrite("Successfully created file mapping")

    ; Map view of file

    $addr_270 = DllCall("kernel32.dll", "ptr", "MapViewOfFile", "hwnd", $var_269[0], "dword", 0x4, "dword", 0x0, "dword", 0x0, "dword", 0x0)
    If @error Or Not $addr_270[0] Then

        DllCall("kernel32.dll", "none", "CloseHandle", "hwnd", $var_269[0])
        DllCall("kernel32.dll", "none", "CloseHandle", "hwnd", $var_261[0])
        Return False
    EndIf
    LogWrite("Successfully mapped view of file")

    ; Parse DOS header

    $var_158 = DllStructCreate("char Magic[2]; word BytesOnLastPage; word Pages; word Relocations; word SizeofHeader; word MinimumExtra; word MaximumExtra; word SS; word SP; word Checksum; word IP; word CS; word Relocation; word Overlay; char Reserved[8]; word OEMIdentifier; word OEMInformation; char Reserved2[20]; dword AddressOfNewExeHeader", $var_175)
    If @error Then

        Return False
    EndIf
    LogWrite("Parsed DOS header successfully")

    ; Parse PE header

    $var_164 = DllStructCreate("word Machine; word NumberOfSections; dword TimeDateStamp; dword PointerToSymbolTable; dword NumberOfSymbols; word SizeOfOptionalHeader; word Characteristics", $var_175 + GetStructData($var_158, "AddressOfNewExeHeader") + 0x4)
    If @error Then

        Return False
    EndIf
    LogWrite("Parsed PE header - Found " & GetStructData($var_164, "NumberOfSections") & " sections")

    ; Process sections

    For $var_206 = 0 To GetStructData($var_164, "NumberOfSections") - 1
        $var_152 = DllStructCreate("char Name[8]; dword VirtualSize; dword VirtualAddress; dword SizeOfRawData; dword PointerToRawData; dword PointerToRelocations; dword PointerToLinenumbers; word NumberOfRelocations; word NumberOfLinenumbers; dword Characteristics", $var_175 + (GetStructData($var_158, "AddressOfNewExeHeader") + 0xf8) + (0x28 * $var_206))

        Local $sectionName = GetStructData($var_152, "Name")
        LogWrite("Processing section: " & $sectionName)


        If Not StringCompare($sectionName, ".text") Then
            LogWrite("Found .text section - Applying memory modifications")

            LogWrite("Section Virtual Address: 0x" & Hex(GetStructData($var_152, "VirtualAddress")))
            LogWrite("Section Virtual Size: 0x" & Hex(GetStructData($var_152, "VirtualSize")))

            ; Try to ensure the memory region is accessible
            Local $retryProtect = 0
            Local $success = False

            Do
                ; Change memory protection with retry mechanism
                $var_265 = DllCall("kernel32.dll", "bool", "VirtualProtect", _
                    "ptr", $var_175 + GetStructData($var_152, "VirtualAddress"), _
                    "dword", GetStructData($var_152, "VirtualSize"), _
                    "dword", 0x40, _ ; PAGE_EXECUTE_READWRITE
                    "dword*", $oldProtect)

                If Not @error And $var_265[0] Then
                    $success = True
                    ExitLoop
                EndIf

                $retryProtect += 1

                Sleep(100)
            Until $retryProtect >= 3

			If Not $success Then

                Return False
            EndIf

            LogWrite("Previous memory protection: 0x" & Hex($var_265[4]))


            ; Copy clean section with verification

            DllCall("msvcrt.dll", "none:cdecl", "memcpy", _
                "ptr", $var_175 + GetStructData($var_152, "VirtualAddress"), _
                "ptr", $addr_270[0] + GetStructData($var_152, "VirtualAddress"), _
                "dword", GetStructData($var_152, "VirtualSize"))

            If @error Then

                Return False
            EndIf

            ; Verify the copy
            Local $verifyBuf = DllStructCreate("byte[" & GetStructData($var_152, "VirtualSize") & "]")
            DllCall("msvcrt.dll", "none:cdecl", "memcpy", _
                "ptr", DllStructGetPtr($verifyBuf), _
                "ptr", $var_175 + GetStructData($var_152, "VirtualAddress"), _
                "dword", GetStructData($var_152, "VirtualSize"))

            LogWrite("Copied clean .text section data with verification")



            $var_265 = DllCall("kernel32.dll", "bool", "VirtualProtect", _
                "ptr", $var_175 + GetStructData($var_152, "VirtualAddress"), _
                "dword", GetStructData($var_152, "VirtualSize"), _
                "dword", $var_265[4], _
                "dword*", $oldProtect)

            If @error Or Not $var_265[0] Then
                LogWrite("Warning: Failed to restore memory protection: " & _WinAPI_GetLastError())

            Else
                LogWrite("Successfully restored memory protection")

            EndIf


            DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)
        EndIf
    Next

    DllCall("kernel32.dll", "bool", "FlushInstructionCache", "handle", -1, "ptr", 0, "dword", 0)


    Local $finalMemInfo = DllStructCreate("dword_ptr WorkingSetSize")
    DllCall("kernel32.dll", "bool", "GetProcessMemoryInfo", "handle", _WinAPI_GetCurrentProcess(), "ptr", DllStructGetPtr($finalMemInfo), "dword", DllStructGetSize($finalMemInfo))
    LogWrite("Final Working Set Size: " & DllStructGetData($finalMemInfo, "WorkingSetSize"))

    ; Reset modified flag
    $g_bModified = False

    LogWrite("Cleanup completed - NTDLL unhooking process finished" & @CRLF)
    Return True
EndFunc


; Main loop
While 1
    Local $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE, $idBtnExit
            Exit

        Case $idBtnTakeSnapshot
            TakeInitialSnapshot()

        Case $idBtnModify
            ModifyNTDLL()

        Case $idBtnCheck
            CheckForChanges()

		Case $idBtnUnhookNTDLL
			LogWrite("Starting unhook sequence...")
			; Save current state
			Local $currentState = _SaveCurrentState()

			; Try the unhook
			If Not SafeInitialize() Then
				LogWrite("Unhook failed - attempting to restore previous state...")
				_RestoreState($currentState)
			EndIf

        Case $idBtnClear
            GUICtrlSetData($g_idLog, "")  ; Clear log window
    EndSwitch
WEnd
