; process_info.ahk

GetCurrentParentProcessID() {
    return GetWin32Process(GetCurrentProcessID(), "ParentProcessId")[1].ParentProcessId
}

GetCurrentProcessID() {
    return DllCall("GetCurrentProcessId")
}

GetParentProcessID(process_id) {
    return GetWin32Process(process_id, "ParentProcessId")[1].ParentProcessId
}

GetProcessList() {
    process_list := {}
    for index, item in GetWin32Process(-1, ["ProcessId", "Name"]) {
        process_list[item.ProcessId] := item.Name
    }
    return process_list
}

GetProcessName(process_id) {
    return GetWin32Process(process_id, "Name")[1].Name
}

GetWin32Process(process_id, fields_array := "") {
    response := []

    fields_array := IsObject(fields_array) ? fields_array : [ fields_array ]
    for index, field in fields_array {
        fields .= ", " . field
    }
    fields := Trim(SubStr(fields, 2))

    if (StrLen(fields) == "0") {
        fields := "*"
    }

    ; https://devblogs.microsoft.com/oldnewthing/20040223-00/?p=40503
    if (process_id == -1) {
        query := Format("Select {1} from Win32_Process", fields)
    } else {
        query := Format("Select {1} from Win32_Process Where ProcessId = '{2}'", fields, process_id)
    }

    for result in ComObjGet("winmgmts:").ExecQuery("" . query) {
        response.push(result)
    }
    return response
}
