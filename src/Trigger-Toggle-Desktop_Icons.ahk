; Trigger-Toggle-Desktop-Icons by Cinabutts
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; ======================================================================
; SETTINGS
; ======================================================================
global ToggleMinimize := 0      ; 1 = Minimize Windows + Toggle, 0 = Just Toggle
global StateFile := A_Temp "\Windhawk_Desktop_State.ini"

global RegPath := "HKLM\SOFTWARE\Windhawk\Engine\Mods\local@desktop-icons-toggle"
global Settings_RegPath := RegPath "\Settings"

; ======================================================================
; MAIN LOGIC
; ======================================================================

; 1. Attempt to get Windhawk Key
Combo := ""
Source := "Windhawk"

; Check if Mod is Enabled (!RegRead flips 1->0 / 0->1) and get key
if GetModState()
    Combo := GetWindhawkKey()

; 2. Fallback to Wallpaper Engine if Windhawk failed
if (Combo = "" && ProcessExist("wallpaper64.exe")) {
    Combo := "^+!0"
    Source := "WallpaperEngine"
}

; 3. Execute or Fail
if (Combo != "") {
    ExecuteToggle(Combo, Source)
    Sleep 3500
} else {
    Tooltip "No hotkey found (Mod disabled & WPE not running)."
    Sleep 2000
}
ExitApp

; ======================================================================
; FUNCTIONS
; ======================================================================

ExecuteToggle(keyString, srcName) {
    global ToggleMinimize, StateFile
    
    ; If Feature OFF: Clean INI, Focus, Send, Exit
    if (ToggleMinimize = 0) {
        if FileExist(StateFile)
            FileDelete(StateFile)
        FocusDesktop()
        Send keyString
        Tooltip "Toggling via " srcName . "  " . keyString
        return
    }

    ; If Feature ON: Check State (0 = Normal/Needs Hide, 1 = Hidden/Needs Show)
    IsHidden := IniRead(StateFile, "State", "Val", "0")

    if (IsHidden = "0") { 
        ; HIDE SEQUENCE
        WinMinimizeAll()
        Sleep 20
        FocusDesktop()
        Send keyString
        Tooltip "Hiding via " . srcName . "  " . keyString
        IniWrite("1", StateFile, "State", "Val")
    } else {
        ; SHOW SEQUENCE
        FocusDesktop()
        Send keyString
        Sleep 20
        WinMinimizeAllUndo()
        Tooltip "Restoring via " srcName . "  " . keyString
        IniWrite("0", StateFile, "State", "Val")
    }
}

FocusDesktop() {
    if WinExist("ahk_class Progman")
        WinActivate
    else if WinExist("ahk_class WorkerW")
        WinActivate
}

GetModState() {
    try return !RegRead(RegPath, "Disabled") ; Returns 1 if Enabled, 0 if Disabled
    catch
        return 0
}

GetWindhawkKey() {
    try {
        ctrl := RegRead(Settings_RegPath, "UseCtrl", 0)
        alt  := RegRead(Settings_RegPath, "UseAlt", 0)
        char := RegRead(Settings_RegPath, "HotkeyChar", "")
        return (ctrl ? "^" : "") . (alt ? "!" : "") . char
    }
    return ""
}