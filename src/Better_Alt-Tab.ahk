;Alt-Tab Replacement by jeeswg

#SingleInstance force
ListLines, Off
#KeyHistory 0
Menu, Tray, Click, 1
#NoEnv
AutoTrim, Off
#UseHook
;#NoTrayIcon

SplitPath, A_ScriptName,,,, vScriptNameNoExt
Menu, Tray, Tip, % vScriptNameNoExt

;==================================================

;options:
;the order in which items will appear
;specify zero to exclude an item
vListVisibleWindows := 1
vListIntExpTabs := 2
vListDesktop := 3
vListNewIntExp := 0

;==================================================

vListCount := 4
;hIcon := DllCall("user32\LoadIcon", Ptr,0, Ptr,32512, Ptr) ;IDI_APPLICATION := 32512
;get Desktop icon (tested on Windows 7)
hIconDT := LoadPicture("shell32.dll", "w16 h16 icon35", vType)
hIconDTBig := LoadPicture("shell32.dll", "w32 h32 icon35", vType)
;get Internet Explorer icon
hIconIE := LoadPicture("C:\Program Files\Internet Explorer\iexplore.exe", "w16 h16", vType)
hIconIEBig := LoadPicture("C:\Program Files\Internet Explorer\iexplore.exe", "w32 h32", vType)

Gui, New, +HwndhGui -Caption +E0x80 Border, Alt-Tab Replacement
Gui, Font, s16
Gui, Color, ABCDEF
Gui, Add, Picture, +HwndhStcImg x4 y4 w32 h32 +0x3 ;SS_ICON := 0x3
;Gui, Add, Picture, +HwndhStcImg x10 y10 w16 h16 +0x3 ;SS_ICON := 0x3
Gui, Add, Text, +HwndhStc x40 y6 w500
Gui, Add, ListView, -Hdr x-2 y40 w530 h280, Window Title
return

;==================================================

GuiClose:
ExitApp
return

;==================================================

!Tab::
+!Tab::
vIndex += InStr(A_ThisHotkey, "+")?-1:1
Gui, % hGui ":Default"

if !DllCall("user32\IsWindowVisible", "Ptr",hGui)
{
	;==============================
	Hotkey, IfWinActive, % "ahk_id " hGui
	Hotkey, *Esc, DoCancel, On
	LV_Delete(), IL_Destroy(hIL)
	hIL := IL_Create(30) ;small icons
	;hIL := IL_Create(30, 30, 1) ;large icons
	LV_SetImageList(hIL)
	vCount := 0, vPrompt := "", oHWnd := {}, oTitle := {}, oHIcon := {}, oHIconBig := {}
	Loop % vListCount
	{
		if (A_Index = vListVisibleWindows)
		{
			DetectHiddenWindows, Off
			WinGet, vWinList, List
			Loop % vWinList
			{
				hWnd := vWinList%A_Index%
				if !JEE_WinHasAltTabIcon(hWnd)
					continue
				WinGetTitle, vWinTitle, % "ahk_id " hWnd
				vCount += 1
				oHWnd.Push(hWnd)
				oTitle.Push(vWinTitle)
				oHIcon.Push(JEE_WinGetIcon(hWnd))
				oHIconBig.Push(JEE_WinGetIcon(hWnd, 1))
				IL_Add(hIL, "HICON:" oHIcon[vCount])
				LV_Add("Icon" vCount, vWinTitle)
			}
			DetectHiddenWindows, On
		}
		if (A_Index = vListDesktop)
		{
			vCount += 1
			oHWnd.Push("Desktop")
			oTitle.Push("Desktop")
			oHIcon.Push(hIconDT)
			oHIconBig.Push(hIconDTBig)
			IL_Add(hIL, "HICON:*" oHIcon[vCount])
			LV_Add("Icon" vCount, oTitle[vCount])
		}
		if (A_Index = vListIntExpTabs)
		{
			WinGet, vWinList, List, ahk_class TabThumbnailWindow
			Loop % vWinList
			{
				hWnd := vWinList%A_Index%
				WinGetTitle, vWinTitle, % "ahk_id " hWnd
				if (vWinTitle = "Blank Page - Internet Explorer")
				|| !(vWinTitle ~= " - Internet Explorer$")
					continue
				vCount += 1
				oHWnd.Push(hWnd)
				oTitle.Push(vWinTitle)
				oHIcon.Push(JEE_WinGetIcon(hWnd))
				;oHIconBig.Push(JEE_WinGetIcon(hWnd, 1))
				;the icons retrieved are small, therefore enlarge them:
				hIcon := JEE_WinGetIcon(hWnd, 1)
				hIcon := LoadPicture("HICON:" hIcon, "w32 h32", vType)
				oHIconBig.Push(hIcon)
				IL_Add(hIL, "HICON:" oHIcon[vCount])
				LV_Add("Icon" vCount, vWinTitle)
			}
		}
		if (A_Index = vListNewIntExp)
		{
			vCount += 1
			oHWnd.Push("NewIntExp")
			oTitle.Push("New Internet Explorer Window")
			oHIcon.Push(hIconIE)
			oHIconBig.Push(hIconIEBig)
			IL_Add(hIL, "HICON:*" oHIcon[vCount])
			LV_Add("Icon" vCount, oTitle[vCount])
		}
	}
	;Loop 2
	;	LV_Add("Icon0", "")
	;==============================
	vIndex := 2
	Gui, Show, y250 w500 h300
	SetTimer, CheckAlt, 30
}
if (vIndex < 1)
	vIndex := vCount
if (vIndex > vCount)
	vIndex := 1
ControlSetText,, % oTitle[vIndex], % "ahk_id " hStc
SendMessage, 0x170, % oHIconBig[vIndex], 0,, % "ahk_id " hStcImg ;STM_SETICON := 0x170
;SendMessage, 0x170, % oHIcon[vIndex], 0,, % "ahk_id " hStcImg ;STM_SETICON := 0x170

;LV_Modify(vIndex, "Focus")
LV_Modify(0, "-Select")
LV_Modify(vIndex, "Select")
LV_Modify(vIndex, "Vis")
return

;==================================================

CheckAlt:
if !GetKeyState("Alt", "P")
{
	SetTimer, CheckAlt, Off
	WinHide, % "ahk_id " hGui
	DetectHiddenWindows, On
	if (oHWnd[vIndex] = "Desktop")
		WinMinimizeAll
	else if (oHWnd[vIndex] = "NewIntExp")
		Run, iexplore.exe
	else
		WinActivate, % "ahk_id " oHWnd[vIndex]
}
return

;==================================================

DoCancel:
SetTimer, CheckAlt, Off
Hotkey, IfWinActive, % "ahk_id " hGui
Hotkey, *Esc, DoCancel, Off
WinHide, % "ahk_id " hGui
return

;==================================================

;JEE_WinGetHIcon
JEE_WinGetIcon(hWnd, vDoGetBig:=0)
{
	static vSfx := (A_PtrSize=8) ? "Ptr" : ""
	if !hWnd || !WinExist("ahk_id " hWnd)
		return 0
	if vDoGetBig
	{
		if (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",1, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_BIG := 1
		|| (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",0, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_SMALL := 0
		|| (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",2, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_SMALL2 := 2
		|| (hIcon := DllCall("user32\GetClassLong" vSfx, "Ptr",hWnd, "Int",-14, "UPtr")) ;GCL_HICON := -14 ;(big icon)
		|| (hIcon := DllCall("user32\GetClassLong" vSfx, "Ptr",hWnd, "Int",-34, "UPtr")) ;GCL_HICONSM := -34 ;(small icon)
		|| (hIcon := DllCall("user32\LoadIcon", "Ptr",0, "Ptr",32512, "Ptr")) ;IDI_APPLICATION := 32512 ;(standard exe icon)
			return hIcon
	}
	else
	{
		if (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",0, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_SMALL := 0
		|| (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",2, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_SMALL2 := 2
		|| (hIcon := DllCall("user32\SendMessage", "Ptr",hWnd, "UInt",0x7F, "UPtr",1, "Ptr",0, "Ptr")) ;WM_GETICON := 0x7F ;ICON_BIG := 1
		|| (hIcon := DllCall("user32\GetClassLong" vSfx, "Ptr",hWnd, "Int",-34, "UPtr")) ;GCL_HICONSM := -34 ;(small icon)
		|| (hIcon := DllCall("user32\GetClassLong" vSfx, "Ptr",hWnd, "Int",-14, "UPtr")) ;GCL_HICON := -14 ;(big icon)
		|| (hIcon := DllCall("user32\LoadIcon", "Ptr",0, "Ptr",32512, "Ptr")) ;IDI_APPLICATION := 32512 ;(standard exe icon)
			return hIcon
	}
	return 0
}

;==================================================

;info for: JEE_WinHasTaskbarButton/JEE_WinHasAltTabIcon

;will it appear on the alt-tab dialog/taskbar:
;WS_CHILD := 0x40000000 ;A maybe, T maybe (appears to make no difference re. presence on list, but does affect the alt-tab icon's appearance)
;WS_VISIBLE := 0x10000000 ;(if off:) A no, T no
;WS_DISABLED := 0x8000000 ;A no, T maybe
;WS_EX_NOACTIVATE := 0x8000000 ;A no, T maybe
;WS_EX_APPWINDOW := 0x40000 ;A yes, T yes
;WS_EX_TOOLWINDOW := 0x80 ;A no, T no (T: under some conditions it seems you can have WS_EX_TOOLWINDOW and a taskbar button)
;has owner ;A maybe, T no
;has parent ;A no, T no
;note: WS_EX_APPWINDOW takes priority over WS_EX_TOOLWINDOW

;Window Styles | Microsoft Docs
;https://docs.microsoft.com/en-us/windows/desktop/winmsg/window-styles
;Extended Window Styles | Microsoft Docs
;https://docs.microsoft.com/en-us/windows/desktop/winmsg/extended-window-styles
;WS_EX_APPWINDOW:
;Forces a top-level window onto the taskbar when the window is visible.
;WS_EX_NOACTIVATE:
;The window does not appear on the taskbar by default. To force the window to appear on the taskbar, use the WS_EX_APPWINDOW style.
;WS_EX_TOOLWINDOW:
;A tool window does not appear in the taskbar or in the dialog that appears when the user presses ALT+TAB.

;from the AHK documentation:
;An owned window has no taskbar button by default, and when visible it is always on top of its owner.

;script for testing:
;DetectHiddenWindows, On
;Gui, New, +HwndhGui -0xFFFFFFFF -E0xFFFFFFFF
;Gui, Show, W300 H300

;hWndParent := DllCall("user32\GetAncestor", Ptr,hWnd, UInt,1, Ptr) ;GA_PARENT := 1
;hWndOwner := DllCall("user32\GetWindow", Ptr,hWnd, UInt,4, Ptr) ;GW_OWNER := 4

;example: WS_EX_TOOLWINDOW on and has no taskbar button
;DetectHiddenWindows, On
;Gui, New, +HwndhGui -0xFFFFFFFF -E0xFFFFFFFF +E0x80 ;WS_EX_TOOLWINDOW := 0x80
;Gui, Show, W300 H300

;example: WS_EX_TOOLWINDOW on but has a taskbar button
;DetectHiddenWindows, On
;Gui, New, +HwndhGui -0xFFFFFFFF -E0xFFFFFFFF
;Gui, Show, W300 H300
;WinSet, ExStyle, +0x80, % "ahk_id " hGui ;WS_EX_TOOLWINDOW := 0x80

;==================================================

;gives you roughly the correct results (tested on Windows 7)
;JEE_WinIsTaskbar
JEE_WinHasTaskbarButton(hWnd)
{
	local
	if !(DllCall("user32\GetDesktopWindow", "Ptr") = DllCall("user32\GetAncestor", "Ptr",hWnd, "UInt",1, "Ptr")) ;GA_PARENT := 1
	|| DllCall("user32\GetWindow", "Ptr",hWnd, "UInt",4, "Ptr") ;GW_OWNER := 4 ;affects taskbar but not alt-tab
		return 0
	if DllCall("user32\GetWindow", "Ptr",hWnd, "UInt",4, "Ptr") ;GW_OWNER := 4 ;affects taskbar but not alt-tab
		return 0
	WinGet, vWinStyle, Style, % "ahk_id " hWnd
	if !vWinStyle
	|| !(vWinStyle & 0x10000000) ;WS_VISIBLE := 0x10000000
	;|| (vWinStyle & 0x8000000) ;WS_DISABLED := 0x8000000 ;affects alt-tab but not taskbar
		return 0
	WinGet, vWinExStyle, ExStyle, % "ahk_id " hWnd
	if (vWinExStyle & 0x40000) ;WS_EX_APPWINDOW := 0x40000
		return 1
	;under some conditions it seems you can have WS_EX_TOOLWINDOW and a taskbar button
	if (vWinExStyle & 0x80) ;WS_EX_TOOLWINDOW := 0x80
	;|| (vWinExStyle & 0x8000000) ;WS_EX_NOACTIVATE := 0x8000000 ;affects alt-tab but not taskbar
		return 0
	return 1
}

;==================================================

;gives you roughly the correct results (tested on Windows 7)
;JEE_WinIsAltTab
JEE_WinHasAltTabIcon(hWnd)
{
	local
	if !(DllCall("user32\GetDesktopWindow", "Ptr") = DllCall("user32\GetAncestor", "Ptr",hWnd, "UInt",1, "Ptr")) ;GA_PARENT := 1
	;|| DllCall("user32\GetWindow", "Ptr",hWnd, "UInt",4, "Ptr") ;GW_OWNER := 4 ;affects taskbar but not alt-tab
		return 0
	WinGet, vWinStyle, Style, % "ahk_id " hWnd
	if !vWinStyle
	|| !(vWinStyle & 0x10000000) ;WS_VISIBLE := 0x10000000
	|| (vWinStyle & 0x8000000) ;WS_DISABLED := 0x8000000 ;affects alt-tab but not taskbar
		return 0
	WinGet, vWinExStyle, ExStyle, % "ahk_id " hWnd
	if (vWinExStyle & 0x40000) ;WS_EX_APPWINDOW := 0x40000
		return 1
	if (vWinExStyle & 0x80) ;WS_EX_TOOLWINDOW := 0x80
	|| (vWinExStyle & 0x8000000) ;WS_EX_NOACTIVATE := 0x8000000 ;affects alt-tab but not taskbar
		return 0
	return 1
}

;==================================================
