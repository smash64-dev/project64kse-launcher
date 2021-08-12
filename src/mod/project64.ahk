; project64.ahk

#Include %A_LineFile%\..\..\lib\logger.ahk
#Include %A_LineFile%\..\..\lib\process_info.ahk

class Project64 {
    static pjlog := {}

    process_id := ""
    process_name := ""

    __New(process_id) {
        pjlog := new Logger("project64.ahk")
        this.log := pjlog

        this.process_id := process_id
        this.process_name := GetProcessName(this.process_id)
    }

    ; notify the user if there are multiple instances of the process present
    CheckForMultipleInstances() {
        for pid, name in GetProcessList() {
            if (pid != this.process_id and name == this.process_name) {
                message := Format("Another instance of {1} is running.`n`nClose the other instance (id: {2}) now?", name, pid)
                MsgBox, % (0x4 | 0x40 | 0x1000), % this.process_name, % message

                IfMsgBox, Yes
                {
                    WinKill, ahk_pid %pid%
                }
            }
        }
    }
}
