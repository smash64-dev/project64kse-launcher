; launcher.ahk

#NoTrayIcon
#SingleInstance force

#Include %A_LineFile%\..\include.ahk

global AUTHOR := "CEnnis91 © 2021"
global SELF := "project64kse-launcher"
global VERSION := "1.0.0"

global APP_DIRECTORY := Format("{1}\{2}", A_AppData, SELF)
global KSE_BINARY := "Project64KSE.exe"
global TEMP_DIRECTORY := Format("{1}\{2}", A_Temp, SELF)

; creates a global file handle for this session to write to
FormatTime, LOG_NOW, , yyyy-MM-dd-HHmmss
global LOGGER_LOG_FILE := Format("{1}\{2}.log", TEMP_DIRECTORY, LOG_NOW)
global LOGGER_LOG_FILE_HANDLE := FileOpen(LOGGER_LOG_FILE, "a", 0x200)

; clean up the environment and close out log files before exiting
ExitClean(final_message := "") {
    global

    ; clean up old log files, they're text files, we can keep a lot
    old_log_format := Format("{1}\*.log", TEMP_DIRECTORY)
    old_log_list := ""
    old_log_preserve := 25

    loop, files, %old_log_format%
    {
        old_log_list := old_log_list . "`n" . A_LoopFileFullPath
    }

    Sort old_log_list, CLR
    old_log_array := StrSplit(old_log_list, "`n")
    old_log_array.RemoveAt(1, old_log_preserve)

    for index, old_log in old_log_array {
        if old_log {
            FileDelete, % old_log
        }
    }

    ; submit a final log message
    if final_message {
        log.crit("===================================")
        log.crit(final_message)
        log.crit("===================================")
    } else {
        log.crit("===================================")
    }

    ; exit cleanly
    LOGGER_LOG_FILE_HANDLE.Close()
    ExitApp
}

GetBaseDirectory(binary_name) {
    global

    ; splitpath doesn't like forward slashes in paths
    ; FileExist works off A_WorkingDir, don't destroy that
    self_path := StrReplace(A_ScriptFullPath, "/", "\")
    B_WorkingDir = %A_WorkingDir%
    SplitPath, self_path,, current_dir

    ; we shouldn't be more than 5 subdirectories deep anyway
    loop, 5 {
        SetWorkingDir, %current_dir%

        if FileExist(binary_name) {
            SetWorkingDir %B_WorkingDir%
            return current_dir
        }

        SplitPath, A_WorkingDir,, current_dir
    }

    log.err("Unable to determine base directory from '{1}'", binary_name)
    return false
}

; entry point
global log := new Logger("launcher.ahk")
log.crit("===================================")
log.crit("= {1} (v{2})", SELF, VERSION)
log.crit("===================================")

; create base working directories if they don't exist
for index, dir in [APP_DIRECTORY, TEMP_DIRECTORY] {
    if ! InStr(FileExist(dir), "D") {
        FileCreateDir % dir
        log.verb("Created working temp directory '{1}' (error: {2})", dir, A_LastError)
    }
}

global BASE_DIRECTORY := GetBaseDirectory(KSE_BINARY)

; kse-launcher expects to be opened *from* KSE, but let the launcher
; actually act as a real launcher too; open KSE and exit immediately
if (GetProcessName(GetCurrentParentProcessID()) != KSE_BINARY) {
    if not BASE_DIRECTORY {
        MsgBox, % (0x10 | 0x2000), Error, % Format("Unable to find {1}.`nDid you move or rename it?", KSE_BINARY)
    } else {
        Run, % Format("{1}\{2}", BASE_DIRECTORY, KSE_BINARY)
    }

    ExitClean()
}

; this code is run when launched from KSE itself
Project64 := New Project64(GetCurrentParentProcessID())
Kaillera := New Kaillera(BASE_DIRECTORY, "Net\cfg")
Updater := New Updater(BASE_DIRECTORY, "Cfg\tools.cfg")

Project64.CheckForMultipleInstances()
Kaillera.VerifyConfig()

; exit cleanly
ExitClean()
exit
