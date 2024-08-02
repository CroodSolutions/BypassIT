#include <Array.au3>
#include <File.au3>

Global $documentsPath = @MyDocumentsDir
Global $contextLength = 30
Global $results = ""

; Regex patterns
Global $phoneRegex = "\(?\d{3}\)?[ .-]\d{3}[ .-]\d{4}"
Global $ssnRegex = "\b\d{3}-\d{2}-\d{4}\b"
Global $dobRegex = "\b(?:\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{4}[-/]\d{1,2}[-/]\d{1,2})\b"

; Search all .txt files in the Documents folder
Local $iFileList = _FileListToArrayRec($documentsPath, "*.txt", 1, 1, 0, 2)
Local $outputFilePath = @ScriptDir & "\output.txt"
FileDelete($outputFilePath) ; Delete the file if it already exists

If @error Then
    FileWrite($outputFilePath, "Error: No .txt files found." & @CRLF)
    Exit
EndIf

For $i = 1 To $iFileList[0]
    Local $filePath = $iFileList[$i]
    Local $fileContent = FileRead($filePath)
    If @error Then
        ContinueLoop
    EndIf
    Local $patterns = [$phoneRegex, $ssnRegex, $dobRegex]
    For $j = 0 To UBound($patterns) - 1
        Local $fileResults = _FindContext($fileContent, $patterns[$j], $contextLength)
        _AddResults($results, $filePath, $fileResults)
    Next
Next

; Write the results to a text file
FileWrite($outputFilePath, $results)

Func _FindContext($content, $pattern, $length)
    Local $resultArray[1] = [0]
    Local $matches = StringRegExp($content, $pattern, 3)
    For $i = 0 To UBound($matches) - 1
        Local $match = $matches[$i]
        Local $pos = StringInStr($content, $match, 0, 1)
        If $pos > 0 Then
            Local $startPos = $pos + StringLen($match)
            Local $context = StringMid($content, $startPos, $length)
            _ArrayAdd($resultArray, $match & ": " & $context)
        EndIf
    Next
    Return $resultArray
EndFunc

Func _AddResults(ByRef $results, $filePath, $fileResults)
    For $i = 1 To UBound($fileResults) - 1
        $results &= $filePath & ": " & $fileResults[$i] & @CRLF
    Next
EndFunc
