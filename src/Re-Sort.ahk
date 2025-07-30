#Requires AutoHotkey v1.1
#NoTrayIcon
SetTitleMatchMode, 2
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SendMode, Input
SetBatchLines, -1
Sleeptime := 500

;=============Re-Sort Desktop Icons==========
; 		Ensure the desktop has focus
WinActivate, ahk_class Progman

; 		Store current mouse position
MouseGetPos, origX, origY

; 		Timer to keep the mouse from moving
SetTimer, LockMouse, 10

; 		First round of sort
Send, {AppsKey}
Sleep, 700
Send, o  ; "Sort by"
Sleep, % (Sleeptime + 150)
Send, d  ; "Date modified"

; 		Second round of sort (to enforce it)
Sleep, %Sleeptime%
Send, {AppsKey}
Send, o
Sleep, %Sleeptime%
Send, d

LockMouse:
MouseMove, %origX%, %origY%, 0
Return

; 		Stop locking mouse and restore cursor
SetTimer, LockMouse, Off
MouseMove, %origX%, %origY%, 0
ExitApp