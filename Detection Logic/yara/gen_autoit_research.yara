/*
   YARA Rule Set
   Author: BypassIT Research Team
   Date: 2024-08-04
   Identifier: downloads
   Reference: https://github.com/CroodSolutions/BypassIT
*/

/* Rule Set ----------------------------------------------------------------- */

import "pe"


rule sig_6115d0dc0349f7cbab3fe4b4b769b389a60aab336519d4b42952bb0f0501428f {
   meta:
      description = "downloads - file 6115d0dc0349f7cbab3fe4b4b769b389a60aab336519d4b42952bb0f0501428f.exe"
      author = "BypassIT Research Team"
      reference = "https://github.com/CroodSolutions/BypassIT"
      date = "2024-08-04"
      hash1 = "6115d0dc0349f7cbab3fe4b4b769b389a60aab336519d4b42952bb0f0501428f"
   strings:
      $x1 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '32.00'*/
      $s2 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '29.00'*/
      $s3 = "sfxelevation" fullword wide /* score: '20.00'*/
      $s4 = "ExecuteOnLoad" fullword wide /* score: '18.00'*/
      $s5 = "RunProgram=\"hidcon:c%Wider%%Dale%%Action%%Smooth%k%Action%%Wider%ove%Action%Vii%Action%Vii.bat%Action%&%Action%Vii.bat%Action%&" ascii /* score: '18.00'*/
      $s6 = "RunProgram=\"hidcon:c%Wider%%Dale%%Action%%Smooth%k%Action%%Wider%ove%Action%Vii%Action%Vii.bat%Action%&%Action%Vii.bat%Action%&" ascii /* score: '18.00'*/
      $s7 = "http://www.digicert.com/CPS0" fullword ascii /* score: '17.00'*/
      $s8 = "7http://cacerts.digicert.com/DigiCertAssuredIDRootCA.crt0E" fullword ascii /* score: '16.00'*/
      $s9 = "5http://cacerts.digicert.com/DigiCertTrustedRootG4.crt0C" fullword ascii /* score: '16.00'*/
      $s10 = "4http://crl3.digicert.com/DigiCertAssuredIDRootCA.crl0" fullword ascii /* score: '16.00'*/
      $s11 = "2http://crl3.digicert.com/DigiCertTrustedRootG4.crl0 " fullword ascii /* score: '16.00'*/
      $s12 = "2http://crl3.digicert.com/DigiCertTrustedRootG4.crl0" fullword ascii /* score: '16.00'*/
      $s13 = "Error in command line:" fullword ascii /* score: '15.00'*/
      $s14 = "7-Zip archiver - Copyright (c) 1999-2015 Igor Pavlov" fullword ascii /* score: '14.00'*/
      $s15 = " - Copyright (c) 2005-2016 " fullword ascii /* score: '14.00'*/
      $s16 = "<assemblyIdentity version=\"1.7.0.3900\" processorArchitecture=\"X86\" name=\"7-Zip.SfxMod\" type=\"win32\" />" fullword ascii /* score: '14.00'*/
      $s17 = " 7-Zip - Copyright (c) 1999-2015 " fullword ascii /* score: '14.00'*/
      $s18 = "SFX module - Copyright (c) 2005-2016 Oleg Scherbakov" fullword ascii /* score: '14.00'*/
      $s19 = "SfxVarSystemPlatform" fullword wide /* score: '14.00'*/
      $s20 = "http://ocsp.digicert.com0X" fullword ascii /* score: '14.00'*/
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      1 of ($x*) and 4 of them
}

rule sig_6a7afd800f236e6bf6cdaa2fc93869daade49c2b5698bbb39c3d8ecc13d0fd9c {
   meta:
      description = "downloads - file 6a7afd800f236e6bf6cdaa2fc93869daade49c2b5698bbb39c3d8ecc13d0fd9c.exe"
      author = "BypassIT Research Team"
      reference = "https://github.com/CroodSolutions/BypassIT"
      date = "2024-08-04"
      hash1 = "6a7afd800f236e6bf6cdaa2fc93869daade49c2b5698bbb39c3d8ecc13d0fd9c"
   strings:
      $x1 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '32.00'*/
      $s2 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '29.00'*/
      $s3 = "sfxelevation" fullword wide /* score: '20.00'*/
      $s4 = "@setup.exe" fullword wide /* score: '19.00'*/
      $s5 = "ExecuteOnLoad" fullword wide /* score: '18.00'*/
      $s6 = "http://www.digicert.com/CPS0" fullword ascii /* score: '17.00'*/
      $s7 = "https://sectigo.com/CPS0" fullword ascii /* score: '17.00'*/
      $s8 = "3http://crt.usertrust.com/USERTrustRSAAddTrustCA.crt0%" fullword ascii /* score: '16.00'*/
      $s9 = "?http://crl.usertrust.com/USERTrustRSACertificationAuthority.crl0v" fullword ascii /* score: '16.00'*/
      $s10 = "Error in command line:" fullword ascii /* score: '15.00'*/
      $s11 = "7-Zip archiver - Copyright (c) 1999-2015 Igor Pavlov" fullword ascii /* score: '14.00'*/
      $s12 = " - Copyright (c) 2005-2016 " fullword ascii /* score: '14.00'*/
      $s13 = "http://ocsp.sectigo.com0" fullword ascii /* score: '14.00'*/
      $s14 = "<assemblyIdentity version=\"1.7.0.3900\" processorArchitecture=\"X86\" name=\"7-Zip.SfxMod\" type=\"win32\" />" fullword ascii /* score: '14.00'*/
      $s15 = " 7-Zip - Copyright (c) 1999-2015 " fullword ascii /* score: '14.00'*/
      $s16 = "SFX module - Copyright (c) 2005-2016 Oleg Scherbakov" fullword ascii /* score: '14.00'*/
      $s17 = "SfxVarSystemPlatform" fullword wide /* score: '14.00'*/
      $s18 = "RunProgram=\"hidcon:\"" fullword ascii /* score: '13.00'*/
      $s19 = "/http://crl4.digicert.com/sha2-assured-cs-g1.crl0K" fullword ascii /* score: '13.00'*/
      $s20 = "3http://crt.sectigo.com/SectigoRSATimeStampingCA.crt0#" fullword ascii /* score: '13.00'*/
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      1 of ($x*) and 4 of them
}

rule sig_2afe2fed654c4514265a3d1b0f50cef25b9fc34351887a13d770457ba018492d {
   meta:
      description = "downloads - file 2afe2fed654c4514265a3d1b0f50cef25b9fc34351887a13d770457ba018492d.exe"
      author = "BypassIT Research Team"
      reference = "https://github.com/CroodSolutions/BypassIT"
      date = "2024-08-04"
      hash1 = "2afe2fed654c4514265a3d1b0f50cef25b9fc34351887a13d770457ba018492d"
   strings:
      $x1 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '32.00'*/
      $s2 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '29.00'*/
      $s3 = "PVVVVVVVh" fullword ascii /* base64 encoded string '=UUUUU' */ /* score: '24.00'*/
      $s4 = "sfxelevation" fullword wide /* score: '20.00'*/
      $s5 = "ExecuteOnLoad" fullword wide /* score: '18.00'*/
      $s6 = "http://www.digicert.com/CPS0" fullword ascii /* score: '17.00'*/
      $s7 = "7http://cacerts.digicert.com/DigiCertAssuredIDRootCA.crt0E" fullword ascii /* score: '16.00'*/
      $s8 = "5http://cacerts.digicert.com/DigiCertTrustedRootG4.crt0C" fullword ascii /* score: '16.00'*/
      $s9 = "4http://crl3.digicert.com/DigiCertAssuredIDRootCA.crl0" fullword ascii /* score: '16.00'*/
      $s10 = "2http://crl3.digicert.com/DigiCertTrustedRootG4.crl0 " fullword ascii /* score: '16.00'*/
      $s11 = "2http://crl3.digicert.com/DigiCertTrustedRootG4.crl0" fullword ascii /* score: '16.00'*/
      $s12 = "Error in command line:" fullword ascii /* score: '15.00'*/
      $s13 = "7-Zip archiver - Copyright (c) 1999-2015 Igor Pavlov" fullword ascii /* score: '14.00'*/
      $s14 = " - Copyright (c) 2005-2016 " fullword ascii /* score: '14.00'*/
      $s15 = "<assemblyIdentity version=\"1.7.0.3900\" processorArchitecture=\"X86\" name=\"7-Zip.SfxMod\" type=\"win32\" />" fullword ascii /* score: '14.00'*/
      $s16 = " 7-Zip - Copyright (c) 1999-2015 " fullword ascii /* score: '14.00'*/
      $s17 = "SFX module - Copyright (c) 2005-2016 Oleg Scherbakov" fullword ascii /* score: '14.00'*/
      $s18 = "SfxVarSystemPlatform" fullword wide /* score: '14.00'*/
      $s19 = "http://ocsp.digicert.com0X" fullword ascii /* score: '14.00'*/
      $s20 = "http://ocsp.digicert.com0\\" fullword ascii /* score: '14.00'*/
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      1 of ($x*) and 4 of them
}

rule sig_43c59cd33371691282d4f781b6f5d0b280da41d71fceeecc7b7052a1db11ac79 {
   meta:
      description = "downloads - file 43c59cd33371691282d4f781b6f5d0b280da41d71fceeecc7b7052a1db11ac79.exe"
      author = "BypassIT Research Team"
      reference = "https://github.com/CroodSolutions/BypassIT"
      date = "2024-08-04"
      hash1 = "43c59cd33371691282d4f781b6f5d0b280da41d71fceeecc7b7052a1db11ac79"
   strings:
      $x1 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '32.00'*/
      $s2 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '29.00'*/
      $s3 = "PVVVVVVVh" fullword ascii /* base64 encoded string '=UUUUU' */ /* score: '24.00'*/
      $s4 = "RunProgram=\"hidcon:c%Riders%%Nuke%%Prescription%%Catalogs%k%Prescription%%Riders%ove%Prescription%Ranke%Nuke%%Prescription%Rank" ascii /* score: '22.00'*/
      $s5 = "%Nuke%.bat%Prescription%&%Prescription%Ranke%Nuke%.bat%Prescription%&%Prescription%e%John%it\"" fullword ascii /* score: '21.00'*/
      $s6 = "sfxelevation" fullword wide /* score: '20.00'*/
      $s7 = "ExecuteOnLoad" fullword wide /* score: '18.00'*/
      $s8 = "Error in command line:" fullword ascii /* score: '15.00'*/
      $s9 = "RunProgram=\"hidcon:c%Riders%%Nuke%%Prescription%%Catalogs%k%Prescription%%Riders%ove%Prescription%Ranke%Nuke%%Prescription%Rank" ascii /* score: '15.00'*/
      $s10 = " - Copyright (c) 2005-2016 " fullword ascii /* score: '14.00'*/
      $s11 = "SFX module - Copyright (c) 2005-2016 Oleg Scherbakov" fullword ascii /* score: '14.00'*/
      $s12 = "SfxVarSystemPlatform" fullword wide /* score: '14.00'*/
      $s13 = "7-Zip archiver - Copyright (c) 1999-2016 Igor Pavlov" fullword ascii /* score: '14.00'*/
      $s14 = "<assemblyIdentity version=\"1.7.1.3901\" processorArchitecture=\"X86\" name=\"7-Zip.SfxMod\" type=\"win32\" />" fullword ascii /* score: '14.00'*/
      $s15 = " 7-Zip - Copyright (c) 1999-2016 " fullword ascii /* score: '14.00'*/
      $s16 = "SfxVarCmdLine1" fullword wide /* score: '13.00'*/
      $s17 = "SfxVarCmdLine0" fullword wide /* score: '13.00'*/
      $s18 = "The archive is corrupted, or invalid password was entered." fullword ascii /* score: '12.00'*/
      $s19 = " \"setup.exe\" " fullword ascii /* score: '11.00'*/
      $s20 = "*.sfx.config.*" fullword ascii /* score: '10.00'*/
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      1 of ($x*) and 4 of them
}

rule sig_7a3506f60a337bd104291e6f01bf18cbf3dad4058e9e79d7861fc2a1c11258c2 {
   meta:
      description = "downloads - file 7a3506f60a337bd104291e6f01bf18cbf3dad4058e9e79d7861fc2a1c11258c2.exe"
      author = "BypassIT Research Team"
      reference = "https://github.com/CroodSolutions/BypassIT"
      date = "2024-08-04"
      hash1 = "7a3506f60a337bd104291e6f01bf18cbf3dad4058e9e79d7861fc2a1c11258c2"
   strings:
      $x1 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '32.00'*/
      $s2 = "<assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" pu" ascii /* score: '29.00'*/
      $s3 = "PVVVVVVVh" fullword ascii /* base64 encoded string '=UUUUU' */ /* score: '24.00'*/
      $s4 = "sfxelevation" fullword wide /* score: '20.00'*/
      $s5 = "ExecuteOnLoad" fullword wide /* score: '18.00'*/
      $s6 = "Error in command line:" fullword ascii /* score: '15.00'*/
      $s7 = " - Copyright (c) 2005-2016 " fullword ascii /* score: '14.00'*/
      $s8 = "SFX module - Copyright (c) 2005-2016 Oleg Scherbakov" fullword ascii /* score: '14.00'*/
      $s9 = "SfxVarSystemPlatform" fullword wide /* score: '14.00'*/
      $s10 = "7-Zip archiver - Copyright (c) 1999-2016 Igor Pavlov" fullword ascii /* score: '14.00'*/
      $s11 = "<assemblyIdentity version=\"1.7.1.3901\" processorArchitecture=\"X86\" name=\"7-Zip.SfxMod\" type=\"win32\" />" fullword ascii /* score: '14.00'*/
      $s12 = " 7-Zip - Copyright (c) 1999-2016 " fullword ascii /* score: '14.00'*/
      $s13 = "RunProgram=\"hidcon:c%Bahrain%%Cf%%Care%%Ralph%k%Care%%Bahrain%ove%Care%Quantity%Care%Quantity.bat%Care%&%Care%Quantity.bat%Care" ascii /* score: '14.00'*/
      $s14 = "RunProgram=\"hidcon:c%Bahrain%%Cf%%Care%%Ralph%k%Care%%Bahrain%ove%Care%Quantity%Care%Quantity.bat%Care%&%Care%Quantity.bat%Care" ascii /* score: '14.00'*/
      $s15 = "SfxVarCmdLine1" fullword wide /* score: '13.00'*/
      $s16 = "SfxVarCmdLine0" fullword wide /* score: '13.00'*/
      $s17 = "The archive is corrupted, or invalid password was entered." fullword ascii /* score: '12.00'*/
      $s18 = " \"setup.exe\" " fullword ascii /* score: '11.00'*/
      $s19 = "*.sfx.config.*" fullword ascii /* score: '10.00'*/
      $s20 = ";Analyst Barcelona Kingston Replaced Pass Pass Awareness Robin " fullword ascii /* score: '10.00'*/
   condition:
      uint16(0) == 0x5a4d and filesize < 3000KB and
      1 of ($x*) and 4 of them
}
