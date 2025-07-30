#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce

; 24H2 requires explicit process priority
ProcessSetPriority "High"

; Target updated window classes
#HotIf WinActive("ahk_class XamlExplorerHostIslandWindow")
WheelUp::Send "{Left}"
WheelDown::Send "{Right}"
#HotIf
