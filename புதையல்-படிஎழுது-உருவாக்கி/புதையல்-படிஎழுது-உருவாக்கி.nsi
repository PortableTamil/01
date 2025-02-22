﻿!define பெயர் "புதையல்-படிஎழுது-உருவாக்கி"
!define பதிப்பு "0.0.0.5"
!define DISTRO "persistent file"
!define PTYPE "$CasperName"
!include ..\பொது-துணைநிரல்கள்\தலைப்பு.நிரல்

!include "Sections.nsh"


; Interface settings
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\அகர\அணிகலன்\யாதும் ஊரே-தலைப்பு.bmp" 
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_HEADERIMAGE_RIGHT

; License page
!define MUI_TEXT_LICENSE_SUBTITLE $(License_Subtitle)
!define MUI_LICENSEPAGE_TEXT_TOP $(License_Top)
!define MUI_LICENSEPAGE_TEXT_BOTTOM $(License_Bottom)
!insertmacro MUI_PAGE_LICENSE "..\அகர\பகவன்\உரிமை.உரை"

; Variables
Var PageDescr
Var DriveSelect
Var DestDriveTxt
Var DestDrive
Var Casper
Var SizeOfCasper
Var CasperSelection
Var CasperSlider
Var SlideSpot

Var casper_rw
Var writable
Var checkpt
Var RemainingSpace
Var MaxPersist
Var FSType

Var CasperNameSelect
Var CasperName
Var COMSPEC
Var PERCENT
Var VolName
Var Capacity 
Var JustDrive
Var Letters
Var BDir
Var DestDisk
Var JustISOName

; USB Drive and Casper Slider Selections Page
Page custom SelectionsPage

; Install Files Page
!define MUI_INSTFILESPAGE_COLORS "00FF00 000000" ;Green and Black
!define MUI_TEXT_INSTALLING_TITLE $(Install_Title)
!define MUI_TEXT_INSTALLING_SUBTITLE $(Install_SubTitle)
!define MUI_TEXT_FINISH_SUBTITLE $(Install_Finish_Sucess)
!insertmacro MUI_PAGE_INSTFILES

; தமிழ் மொழி உரைகள்
!insertmacro MUI_LANGUAGE "Tamil" ; தமிழே முதல் மொழி
LangString License_Subtitle ${LANG_TAMIL} "${பெயர்} தொடர்வதற்கு முன் உரிம விதிமுறைகளை மதிப்பாய்வு செய்யவும் ."
LangString License_Top ${LANG_TAMIL} "இந்த நிரலில் உள்ள மென்பொருள் பின்வரும் உரிமங்களின் கீழ் வருகிறது."
LangString License_Bottom ${LANG_TAMIL} "இந்த ${பெயர்} பயன்பாட்டை இயக்க இந்த உரிம ஒப்பந்தத்தின் விதிமுறைகளை நீங்கள் ஏற்க வேண்டும். நீங்கள் ஒப்புக்கொண்டால், ஒப்புதல் என்பதைக் சொடுக்கு."
LangString DrivePage_Title ${LANG_TAMIL} "மின்வெட்டொளி இயக்கதைத் தேர்ந்தெடுக்கவும்"
LangString DrivePage_Title2 ${LANG_TAMIL} "மின்வெட்டொளி இயக்கதைத் தேர்ந்தெடுக்கவும் in which to install a ${DISTRO}."
LangString DrivePage_Text ${LANG_TAMIL} "This simple tool can be used to create a ${DISTRO} on your select USB drive, enabling you to save and restore changes on Live Ubuntu based Distributions and Remixes."
LangString CasperName_Input ${LANG_TAMIL} "படி 2: Select Your Persistence File பெயர்"
LangString DrivePage_Input ${LANG_TAMIL} "படி 1: மின்வெட்டொளி இயக்கதைத் தேர்ந்தெடுக்கவும்"
LangString Casper_Text ${LANG_TAMIL} "படி 3: Drag the Slider to Set a File Size to use for storing changes."
LangString Install_Title ${LANG_TAMIL} "Installing a ${PTYPE} ${DISTRO}"
LangString Install_SubTitle ${LANG_TAMIL} "Please wait while ${பெயர்} creates and installs a ${PTYPE} ${DISTRO} on $DestDrive"
LangString Install_Finish_Sucess ${LANG_TAMIL} "${பெயர்} sucessfully created and installed a ${PTYPE} ${DISTRO} on $DestDrive"

!include ..\பொது-துணைநிரல்கள்\தகவல்.நிரல்

Function SelectionsPage
  !insertmacro MUI_HEADER_TEXT $(DrivePage_Title) $(DrivePage_Title2)
  nsDialogs::Create 1018
  
  ${If} $DestDrive == ""
   GetDlgItem $6 $HWNDPARENT 1 ; Get "Next" control handle
   EnableWindow $6 0 ; disable "Next" control
  ${EndIf}
  
  ${NSD_CreateLabel} 0 0 100% 40 $(DrivePage_Text)
  Pop $PageDescr
  
  ${NSD_CreateLabel} 0 45 40% 15 $(DrivePage_Input)
  Pop $DriveSelect  

; Droplist for Drive Selection
  ${NSD_CreateDroplist} 0 65 35% 20 ""
  Pop $DestDriveTxt
  ${NSD_OnChange} $DestDriveTxt OnSelectDrive
  ${GetDrives} "FDD+HDD" DrivesList
  ${If} $DestDrive != ""
  ${NSD_CB_SelectString} $DestDriveTxt $DestDrive
  ${EndIf}
  
  ${NSD_CreateLabel} 0 95 100% 15 $(CasperName_Input)
  Pop $CasperNameSelect   
  
    ${NSD_CreateRadioButton} 0 115 20% 20 "casper-rw"
    Pop $casper_rw
	${NSD_Check} $casper_rw
	${NSD_OnClick} $casper_rw CaspChecker
  ${NSD_CreateRadioButton} 25% 115 20% 20 "writable"
    Pop $writable
	${NSD_OnClick} $writable CaspChecker   
  
; Casper-RW Selection Starts
  ${NSD_CreateLabel} 0 145 100% 15 $(Casper_Text)
  Pop $CasperSelection  
  
; CasperSlider - TrackBar
;  !define TBM_SETPOS 0x0405
;  !define TBM_GETPOS 0x0400
; !define TBM_SETRANGEMIN 0x0407
; !define TBM_SETRANGEMAX 0x0408

  nsDialogs::CreateControl "msctls_trackbar32" "0x50010000|0x00000018" "" 0 165 50% 25 ""
  Pop $CasperSlider
  
  ${NSD_CreateLabel} 52% 170 30% 25 ""
  Pop $SlideSpot    

  SendMessage $CasperSlider ${TBM_SETRANGEMIN} 1 256 ; Min Range Value 256
  SendMessage $CasperSlider ${TBM_SETRANGEMAX} 1 $RemainingSpace ; Max Range Value 4090
  ${NSD_OnNotify} $CasperSlider புதையல்நிலைமாற்றிஅறிவிப்பதில்      
  
  nsDialogs::Show
FunctionEnd

Function CaspChecker
    Pop $checkpt
 	${If} $checkpt == $casper_rw
	${NSD_Check} $casper_rw
	StrCpy $CasperName "casper-rw" ; casper-rw persistence label	 
	${ElseIf} $checkpt == $writable
	${NSD_Check} $writable
	StrCpy $CasperName "writable" ; writable persistence label	 
	${EndIf}
	;MessageBox MB_OK "$CasperName"
FunctionEnd	

Function GetDiskVolumeName
System::Alloc 1024 ; Allocate string body
Pop $0 ; Get the allocated string's address

!define GetVolumeInformation "Kernel32::GetVolumeInformation(t,t,i,*i,*i,*i,t,i) i"
System::Call '${GetVolumeInformation}("$JustDrive",.r0,1024,,,,,1024)' ;

${If} $0 != ""
 StrCpy $VolName "$0"
${Else}
 StrCpy $VolName ""
${EndIf}
FunctionEnd 

Function DiskSpace
${DriveSpace} "$9" "/D=T /S=G" $1 ; used to find total space of each drive
${If} $1 > "0"
 StrCpy $Capacity "$1GB"
${Else}
 StrCpy $Capacity ""
${EndIf}
FunctionEnd

Function DrivesList
  StrCpy $JustDrive $9
  Call GetDiskVolumeName
  Call DiskSpace
  Call கோமுவகைபெறு
  SendMessage $DestDriveTxt ${CB_ADDSTRING} 0 "STR:$9 $VolName $Capacity $FSType"
  Push 1
FunctionEnd

Function கோமுவகைபெறு
System::Call 'Kernel32::GetVolumeInformation(t "$9",t,i ${NSIS_MAX_STRLEN},*i,*i,*i,t .r1" ,i ${NSIS_MAX_STRLEN}) i.r0'
 StrCpy $FSType "$1"
FunctionEnd

; On Selection of USB Drive
Function OnSelectDrive
  Pop $DestDriveTxt
  ${NSD_GetText} $DestDriveTxt $Letters
  StrCpy $DestDrive "$Letters"
  StrCpy $JustDrive $DestDrive 3  
  StrCpy $BDir $DestDrive 2 ;was -1 
  StrCpy $DestDisk $DestDrive 2 ;was -1 
  ; MessageBox MB_ICONSTOP|MB_OK "$JustDrive - $DestDrive"  
  GetDlgItem $6 $HWNDPARENT 1 ; Get "Next" control handle
  EnableWindow $6 1 ; enable "Next" control
  Call SetSpace
FunctionEnd

Function HaveSpace ; Check space required before installing
  ;StrCpy $0 '$0' ; check how much free space is left
  Call FreeDiskSpace
  StrCpy $2 $Casper ; Free space required by you (in MB)
  System::Int64Op $1 > $2 ; Compare the space required and the space available
  Pop $3 ; Get the result ...
  IntCmp $3 1 okay ; ... and compare it
  MessageBox MB_ICONSTOP|MB_OK "Oops: There is not enough Free disk space! $1 MB of $2 MB Needed on $JustDrive Drive."
  quit ; Close the program if the disk space was too small...
  okay: ; Proceed to execute...
FunctionEnd

Function SetSpace ; Set space available for persistence
 ${If} $FSType != "NTFS"
 ${AndIf} $FSType != "exFAT"
  Call FreeDiskSpace
  StrCpy $MaxPersist 4090 ; Space required for a 4GB max persistent file
   ${If} $1 > $MaxPersist ; Check if more space is available than we need for 4GB persistent file
   StrCpy $RemainingSpace 4090 ; Set maximum possible value to 4090 MB (any larger wont work on fat32 Filesystem)
   ${Else}
   StrCpy $RemainingSpace "$1"
   ${EndIf}
 ${Else}  
  Call FreeDiskSpace
  StrCpy $MaxPersist 20450 ; Space required for 20GB max persistent file
   ${If} $1 > $MaxPersist ; Check if more space is available than we need for a 20GB persistent file
   StrCpy $RemainingSpace 20450 ; Set maximum possible value to 20450 MB
   ${Else}
   StrCpy $RemainingSpace "$1"
   ${EndIf}

 ${EndIf} 
   IntOp $RemainingSpace $RemainingSpace - 1 ; Subtract 1MB so that we don't error for not having enough space
   SendMessage $CasperSlider ${TBM_SETRANGEMAX} 1 $RemainingSpace ; Re-Setting Max Value 
FunctionEnd

Function FreeDiskSpace
${DriveSpace} "$JustDrive" "/D=F /S=M" $1
FunctionEnd

!include ..\பொது-துணைநிரல்கள்\தவமுன்னேற்றம்.நிரல்
!include ..\பொது-துணைநிரல்கள்\புதையல்பொதுஉரை.நிரல்
Function CasperScript
${If} $Casper != "0"
Call புதைகருவிகளைப்பெறு
;MessageBox MB_OK "$CasperName"
Sleep 1000
DetailPrint "1 வினாடி தூங்குகிறது..."
ExpandEnvStrings $COMSPEC "%COMSPEC%"
ExecShell "" '"$COMSPEC"' '/C if 1==1 "$PLUGINSDIR\dd.exe" if=/dev/zero of=$PLUGINSDIR\$CasperName bs=1M count=$Casper --progress 2>$PLUGINSDIR\ddlog.txt' SW_HIDE
Banner::show /set 76 "நிலைத்தன்மை கோப்பை உருவாக்குதல்."
Banner::getWindow
Pop $1  
DetailPrint "நிலைத்தன்மை கோப்பை உருவாக்குதல்: முடிவடையும் வரை முன்னேற்றப் பட்டி நகராது..."
Call தவமுன்னேற்றம்
Banner::destroy
DetailPrint "இப்போது ஒரு நிலைத்தன்மை கோப்பை உருவாக்குதல்" 
DetailPrint "நிலைத்தன்மை கோப்பை வடிவமைத்தல்: முடிவடையும் வரை முன்னேற்றப் பட்டி நகராது. தயவுசெய்து பொருமையாயிறு..." 
Sleep 3000 ; தரவுவரையறை.exe வெளியேற நேரம் கொடுங்கள்.
DetailPrint "3 வினாடிகள் தூங்குகிறது..."
nsExec::ExecToLog '"$PLUGINSDIR\mke2fs.exe" -L $CasperName $PLUGINSDIR\$CasperName'
CopyFiles $PLUGINSDIR\$CasperName "$BDir\$CasperName" ; Copy casper-rw to USB
Delete "$PLUGINSDIR\$CasperName"
${EndIf}
  CopyFiles "$PLUGINSDIR\உரிமை.உரை" "$BDir\உரிமை.உரை" ; நகர்த்து 
FunctionEnd


Function புதையல்நிலைமாற்றிஅறிவிப்பதில்
Pop $Casper
SendMessage $CasperSlider ${TBM_GETPOS} 0 0 $Casper ; Get Trackbar position
${NSD_SetText} $SlideSpot "$Casper MB"
FunctionEnd

; ---- Let's Do This Stuff ----
Section  
Call HaveSpace ; Got enough Space? Lets Check!
Call புதையல்பொதுஉரை
SectionEnd

Function .onInit
StrCpy $CasperName "casper-rw" ; default to newer persistence label
StrCpy $JustISOName ".."
Call புதைகருவிகளைப்பெறு
File /oname=$PLUGINSDIR\உரிமை.உரை "..\அகர\பகவன்\உரிமை.உரை"
FunctionEnd 