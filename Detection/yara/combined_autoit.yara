rule Combined_AutoIt_Detection
{
    meta:
        description = "Combined rule to detect AutoIt scripts and compiled executables"
        author = "BypassIT Research Group"
    
    strings:
        // AutoIt v3.26+ strings
        $str1 = "This is a third-party compiled AutoIt script."
        $str2 = "AU3!EA06"
        $str3 = ">>>AUTOIT NO CMDEXECUTE<<<" wide
        $str4 = "AutoIt v3" wide
        $magic_v326 = { A3 48 4B BE 98 6C 4A A9 99 4C 53 0A 86 D6 48 7D 41 55 33 21 45 41 30 36 }

        // AutoIt v3.00 strings
        $str5 = "AU3_GetPluginDetails"
        $str6 = "AU3!EA05"
        $str7 = "OnAutoItStart" wide
        $str8 = "AutoIt script files (*.au3, *.a3x)" wide
        $magic_v300 = { A3 48 4B BE 98 6C 4A A9 99 4C 53 0A 86 D6 48 7D 41 55 33 21 45 41 30 35 }

        // Generic AutoIt strings
        $str9 = "AV researchers please email avsupport@autoitscript.com for support."
        $str10 = "#OnAutoItStartRegister"
        $str11 = "#pragma compile"
        $str12 = "/AutoIt3ExecuteLine"
        $str13 = "/AutoIt3ExecuteScript"
        $str14 = "/AutoIt3OutputDebug"
        $str15 = ">>>AUTOIT SCRIPT<<<"

        // Import AutoIt functions
        $imp1 = "#include\s+<\w+\.(au3|a3x)\>" nocase wide ascii fullword 

        // Common AutoIt functions
        $func1 = "NoTrayIcon" nocase wide ascii fullword
        $func2 = "iniread" nocase wide ascii fullword
        $func3 = "fileinstall" nocase wide ascii fullword
        $func4 = "EndFunc" nocase wide ascii fullword
        $func5 = "FileRead" nocase wide ascii fullword
        $func6 = "DllStructSetData" nocase wide ascii fullword
        $func7 = "Global Const" nocase wide ascii fullword
        $func8 = "Run(@AutoItExe" nocase wide ascii fullword
        $func9 = "StringReplace" nocase wide ascii fullword
        $func10 = "filewrite" nocase wide ascii fullword

    condition:
        (
            // Match compiled executables
            (uint16(0) == 0x5A4D and (
                $magic_v326 or
                $magic_v300 or
                3 of ($str1, $str2, $str3, $str4, $str5, $str6, $str7, $str8) or
                any of ($str9, $str10, $str11, $str12, $str13, $str14, $str15)
            ))
        ) or (
            // Match scripts
            (uint16(0) != 0x5A4D and (
                any of ($str1, $str2, $str3, $str4, $str5, $str6, $str7, $str8, $str9, $str10, $str11, $str12, $str13, $str14, $str15) or
                4 of ($func1, $func2, $func3, $func4, $func5, $func6, $func7, $func8, $func9, $func10)
            ))
        ) or (
           $imp1  
        )

}