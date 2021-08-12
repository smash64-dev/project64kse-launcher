; include.ahk

; modules
#Include, %A_LineFile%\..\mod\kaillera.ahk
#Include, %A_LineFile%\..\mod\project64.ahk
#Include, %A_LineFile%\..\mod\updater.ahk

; first-party classes
#Include %A_LineFile%\..\lib\ini_config.ahk
#Include %A_LineFile%\..\lib\logger.ahk
#Include %A_LineFile%\..\lib\process_info.ahk

; third-party libraries
#Include %A_LineFile%\..\ext\json.ahk
#Include %A_LineFile%\..\ext\msgboxex.ahk
#Include %A_LineFile%\..\ext\taskdialogex.ahk
