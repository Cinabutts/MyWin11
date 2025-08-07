; #SingleInstance, Force
; #notrayicon
; #warn All, Off
; ======================================================================
; This triggers the Windhawk mod "desktop-icons-toggle" (Working vers: 1.2)
; +========================_++DO NOT MODIFY++_========================+
; ======================================================================
    ; WinMinimizeAll  ; Minimizes all windows (shows desktop)
    ; Sleep(200)
	; Send("^!d")		;comment this/uncomment below to do the classic way right click desktop - context menu - etc.

    ; Send("{AppsKey}")  ; Open context menu on desktop
    ; Sleep(1000)
    ; Send("v")         ; 'v' is the shortcut for "View" in English Windows
    ; Sleep(1000)
    ; Send("d")         ; 'd' toggles "Show desktop icons"


#Requires AutoHotkey v2.0+
#SingleInstance Force
; #warn All, Off

; Define the path to the Windhawk mod's settings in the registry.
global RegPath := "HKLM\SOFTWARE\Windhawk\Engine\Mods\local@desktop-icons-toggle\Settings"
; Initialize the hotkey combination variable.
global HotkeyCombo := ""

; ======================================================================
; MAIN SCRIPT EXECUTION
; This is what runs when the script is launched.
; ======================================================================

; Attempt to refresh the hotkey combination from the registry upon starting.
RefreshHotkeyCombo()

; Check if a valid hotkey combination was retrieved.
if (HotkeyCombo != "") {	;This is where i believe you need to return the new combo instead of just ""
    ; If successful, send the retrieved hotkey combination.
		; "Warning: This global variable appears to never be assigned a value."
		; MsgBox modifiers . hotkeyChar		;this throws error regardless of if it's detected the shortcut/that popup shows up.
		
    WinMinimizeAll  ; Minimizes all windows (shows desktop)
    Sleep(200)
    Send(HotkeyCombo)
} else {
    ; If reading the registry fails, display an error message.
    MsgBox("Error: Could not retrieve the hotkey combination from the registry.`n`nPlease check if the Windhawk mod 'desktop-icons-toggle' is installed and configured correctly.", "Hotkey Script Error", "Icon!")
}

; The script will now exit after sending the hotkey or showing an error.
ExitApp

; ======================================================================
; FUNCTIONS
; These can be called as needed. The 'RefreshHotkeyCombo' function
; is designed to be reusable.
; ======================================================================

/**
 * Reads the hotkey configuration from the Windows Registry and updates the global HotkeyCombo variable.
 */
RefreshHotkeyCombo() {
    global RegPath, HotkeyCombo
    try {
        ; Read the modifier key settings and the hotkey character from the registry.
        local useCtrl := RegRead(RegPath, "UseCtrl")
        local useAlt := RegRead(RegPath, "UseAlt")
			; Keep for future accommodations
        ; local useShift := RegRead(RegPath, "UseShift") ; Assuming a 'UseShift' might exist
        ; local useWin := RegRead(RegPath, "UseWin")   ; Assuming a 'UseWin' might exist
        local hotkeyChar := RegRead(RegPath, "HotkeyChar")

        ; Build the modifier string based on the registry values.
        local modifiers := ""
        if (useCtrl = 1) {
            modifiers .= "^"
        }
        if (useAlt = 1) {
            modifiers .= "!"
        }
			; Keep for future accommodations
        ; if (useShift = 1) {
            ; modifiers .= "+"
        ; }
        ; if (useWin = 1) {
            ; modifiers .= "#"
        ; }

        ; Combine the modifiers and the hotkey character to form the final hotkey string.
        HotkeyCombo := modifiers . hotkeyChar
		
		; MsgBox modifiers . hotkeyChar
        return true ; Indicate success
    } catch {
        ; If there's an error reading from the registry, reset the combo and indicate failure.
        HotkeyCombo := ""
	MsgBox("Failure")
        return false ; Indicate failure
    }
}
