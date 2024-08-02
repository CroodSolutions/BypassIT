#include <Array.au3>
#include <File.au3>

Global $documentsPath = @MyDocumentsDir
Global $searchTerms = ["Secret", "Password"]
Global $contextLength = 30
Global $results = ""

; Search all .txt files in the Documents folder
Local $iFileList = _FileListToArrayRec($documentsPath, "*.txt", 1, 1, 0, 2)
If @error Then
    MsgBox(0, "Error", "No .txt files found.")
    Exit
EndIf

For $i = 1 To $iFileList[0]
    Local $filePath = $iFileList[$i]
    Local $fileContent = FileRead($filePath)
    If @error Then
        ContinueLoop
    EndIf
    Local $fileResults = _FindContext($fileContent, $searchTerms, $contextLength)
    For $j = 1 To UBound($fileResults) - 1
        $results &= $filePath & ": " & $fileResults[$j] & @CRLF
    Next
Next

; Write the results to a text file
Local $outputFilePath = @ScriptDir & "\output.txt"
FileDelete($outputFilePath) ; Delete the file if it already exists
FileWrite($outputFilePath, $results)

MsgBox(0, "Results", "Results written to " & $outputFilePath)

Func _FindContext($content, $terms, $length)
    Local $resultArray[1] = [0]
    For $i = 0 To UBound($terms) - 1
        Local $term = $terms[$i]
        Local $pos = 1
        While $pos > 0
            $pos = StringInStr($content, $term, 0, $pos)
            If $pos > 0 Then
                Local $startPos = $pos + StringLen($term)
                Local $context = StringMid($content, $startPos, $length)
                _ArrayAdd($resultArray, $term & ": " & $context)
                $pos = $startPos
            EndIf
        WEnd
    Next
    Return $resultArray
EndFunc
