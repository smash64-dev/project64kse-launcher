/*
 * Process_Info - based on code from HuBa
 * http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=4693
 * http://www.autohotkey.com/forum/viewtopic.php?p=65983#65983
 * https://autohotkey.com/board/topic/17054-parent-processid-processname-processthreadcount/page-2#entry669812
 */

GetCurrentProcessID() {
    ; http://msdn2.microsoft.com/ms683180.aspx
    return DllCall("GetCurrentProcessId")
}

GetCurrentParentProcessID() {
    return GetParentProcessID(GetCurrentProcessID())
}

GetProcessList() {
    ; https://devblogs.microsoft.com/oldnewthing/20040223-00/?p=40503
    return GetProcessInformation(-1, "Str", 260 * (A_IsUnicode ? 2 : 1), 32 + A_PtrSize)
}

GetProcessName(ProcessID) {
    ; TCHAR szExeFile[MAX_PATH]
    return GetProcessInformation(ProcessID, "Str", 260 * (A_IsUnicode ? 2 : 1), 32 + A_PtrSize)
}

GetParentProcessID(ProcessID) {
    ; DWORD th32ParentProcessID
    return GetProcessInformation(ProcessID, "UInt *", 8, 20 + A_PtrSize)
}

GetProcessThreadCount(ProcessID) {
    ; DWORD cntThreads
    return GetProcessInformation(ProcessID, "UInt *", 8, 16 + A_PtrSize)
}

; http://msdn.microsoft.com/en-us/library/windows/desktop/ms684839%28v=vs.85%29.aspx
GetProcessInformation(ProcessID, CallVariableType, VariableCapacity, DataOffset) {
    static PE32_size := 8 * 4 + A_PtrSize + 260 * (A_IsUnicode ? 2 : 1)
    process_info := {}

    ; TH32CS_SNAPPROCESS = 2
    hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)

    if (hSnapshot >= 0) {
        ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
        VarSetCapacity(PE32, PE32_size, 0)
        DllCall("ntdll.dll\RtlFillMemoryUlong", "Ptr", &PE32, "UInt", 4, "UInt", PE32_size)

        VarSetCapacity(th32ProcessID, 4, 0)
        DllCall("Process32First" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32)

        ; http://msdn2.microsoft.com/ms684834.aspx
        if (DllCall("Kernel32.dll\Process32First" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32)) {
            loop {
                ; http://msdn2.microsoft.com/ms803004.aspx
                DllCall("RtlMoveMemory", "Ptr*", th32ProcessID, "Ptr", &PE32 + 8, "UInt", 4)

                if (ProcessID == -1 or ProcessID == th32ProcessID) {
                    VarSetCapacity(th32DataEntry, VariableCapacity, 0)

                    ; http://msdn2.microsoft.com/ms724211.aspx
                    DllCall("RtlMoveMemory", CallVariableType, th32DataEntry, "Ptr", &PE32 + DataOffset, "UInt", VariableCapacity)

                    if (ProcessID == -1) {
                        process_info.Insert(th32ProcessID, th32DataEntry)
                    } else {
                        DllCall("CloseHandle", "Ptr", hSnapshot)
                        return th32DataEntry
                    }
                }

                ; http://msdn2.microsoft.com/ms684836.aspx
                if not DllCall("Process32Next" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32) {
                    Break
                }
            }
        }

        DllCall("CloseHandle", "Ptr", hSnapshot)
    }

    return ProcessId == -1 ? process_info : false
}

; modified version of shimanov's function
GetModuleFileNameEx(ProcessID) {
    if (A_OSVersion in WIN_95, WIN_98, WIN_ME) {
        return GetProcessName(ProcessID)
    }

    ; PROCESS_VM_READ (0x0010) / PROCESS_QUERY_INFORMATION (0x0400)
    hProcess := DllCall("OpenProcess", "UInt", 0x10|0x400, "Int", False, "UInt", ProcessID)

    if (ErrorLevel or hProcess = 0) {
        return
    }

    FileNameSize := 260 * (A_IsUnicode ? 2 : 1)
    VarSetCapacity(ModuleFileName, FileNameSize, 0)

    CallResult := DllCall("Psapi.dll\GetModuleFileNameEx", "Ptr", hProcess, "Ptr", 0, "Str", ModuleFileName, "UInt", FileNameSize)
    DllCall("CloseHandle", "Ptr", hProcess)

    return ModuleFileName
}
