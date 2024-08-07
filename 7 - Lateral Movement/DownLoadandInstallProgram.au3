#comments-start

This is a simple script to install Putty on a host, but it can be easily modified to install some other simple program.  You will need to compile the AutoIT script to an executable and then run as administrator for this one. Note that the download locations for Putty will vary over time, so the basic idea is to alter this to fit what you are trying to install. 

#comments-end



#include <InetConstants.au3>
#include <MsgBoxConstants.au3>

; Define the URL for the PuTTY installer
Global $sURL = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.81-installer.msi"
Global $sInstallerPath = @ScriptDir & "\putty-installer.msi"

; Download the PuTTY installer
InetGet($sURL, $sInstallerPath, $INET_FORCERELOAD)

; Check if the download was successful
If FileExists($sInstallerPath) Then
    MsgBox($MB_SYSTEMMODAL, "Download Complete", "PuTTY installer downloaded successfully.")
Else
    MsgBox($MB_SYSTEMMODAL, "Download Failed", "Failed to download the PuTTY installer.")
    Exit
EndIf

; Install PuTTY
RunWait('msiexec.exe /i "' & $sInstallerPath & '" /quiet /norestart', @SystemDir)

; Check if the installation was successful
If FileExists(@ProgramFilesDir & "\PuTTY\putty.exe") Or FileExists(@ProgramFilesDir & "\PuTTY\putty.exe") Then
    MsgBox($MB_SYSTEMMODAL, "Installation Complete", "PuTTY installed successfully.")
Else
    MsgBox($MB_SYSTEMMODAL, "Installation Failed", "PuTTY installation failed.")
EndIf

Exit
