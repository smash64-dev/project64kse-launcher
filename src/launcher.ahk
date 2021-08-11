; launcher.ahk

#NoTrayIcon
#SingleInstance force

#Include %A_LineFile%\..\include.ahk

global AUTHOR := "CEnnis91 © 2021"
global SELF := "project64kse-launcher"
global VERSION := "1.0.0"

global APP_DIRECTORY := Format("{1}\{2}", A_AppData, SELF)
global TEMP_DIRECTORY := Format("{1}\{2}", A_Temp, SELF)

; creates a global file handle for this session to write to
FormatTime, LOG_NOW, , yyyy-MM-dd-HHmmss
global LOGGER_LOG_FILE := Format("{1}\{2}.log", TEMP_DIRECTORY, LOG_NOW)
global LOGGER_LOG_FILE_HANDLE := FileOpen(LOGGER_LOG_FILE, "a", 0x200)

; entry point
global log := new Logger("launcher.ahk")
log.crit("===================================")
log.crit("= {1} (v{2})", SELF, VERSION)
log.crit("===================================")

; todo

; exit cleanly
LOGGER_LOG_FILE_HANDLE.Close()
ExitApp
exit
