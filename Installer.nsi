!define APPNAME "NWJS Runtime"
!define COMPANYNAME "DARKGuy / Alemar"
!define DESCRIPTION "NWJS Runtime"

!define VERSIONMAJOR 0
!define VERSIONMINOR 12
!define VERSIONBUILD 3

!define INSTALLSIZE 88774

RequestExecutionLevel admin

InstallDir  "$PROGRAMFILES\NWJS"

LicenseData "License.txt"
Name "${APPNAME}"
Icon "Installer.ico"
outFile "${APPNAME} ${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD} Setup.exe"

!include LogicLib.nsh
!include "FileAssociation.nsh"

# Just three pages - license agreement, install location, and installation
page license
page directory
Page instfiles

###########################################################################################
# Initialization
###########################################################################################

!macro VerifyUserIsAdmin
	UserInfo::GetAccountType
	pop $0
	${If} $0 != "admin" ;Require admin rights on NT4+
	        messageBox mb_iconstop "Error: Administrator privileges are required"
	        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
	        quit
	${EndIf}
!macroend

###########################################################################################
# Installer
###########################################################################################

function .onInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd

section "install"
	setOutPath $INSTDIR
	File /r Files\*
	File Installer.ico	
	!insertmacro APP_ASSOCIATE "nw" "nwjs.package" "NW.JS Package File" "$INSTDIR\nw.exe,0" "Run" "$INSTDIR\nw.exe $\"%1$\""
	writeUninstaller "$INSTDIR\Uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime" "DisplayName" "${APPNAME} ${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime" "DisplayIcon" "$\"$INSTDIR\Installer.ico$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime" "NoRepair" 1
sectionEnd

###########################################################################################
# Uninstaller
###########################################################################################

function un.onInit
	SetShellVarContext all
	MessageBox MB_OKCANCEL "Do you really want to uninstall ${APPNAME}?" IDOK next
		Abort
	next:
	!insertmacro VerifyUserIsAdmin
functionEnd

section "uninstall"
	# Remove files	
	ExecWait "taskkill /f /im node.exe"
	Sleep 2500
	ExecWait "taskkill /f /im nw.exe"
	Sleep 2500
	!insertmacro APP_UNASSOCIATE "nw" "nwjs.package"
	rmDir /r "$INSTDIR\*"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NWJSRuntime"
sectionEnd
