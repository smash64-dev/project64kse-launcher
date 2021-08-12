; updater.ahk

#Include %A_LineFile%\..\..\ext\json.ahk
#Include %A_LineFile%\..\..\lib\logger.ahk

class Updater {
    static ulog := {}

    base_dir := ""
    tools_config := ""
    updater_binary := ""
    updater_config := ""
    user_config := ""

    __New(base_dir, tools_config) {
        ulog := new Logger("updater.ahk")
        this.log := ulog

        this.base_dir := base_dir
        this.tools_config := Format("{1}\{2}", base_dir, tools_config)
        if ! FileExist(this.tools_config) {
            this.log.warn("Config file '{1}' does not exist, aborting", this.tools_config)
            return false
        }

        this.tools_ini := new IniConfig(this.tools_config)
        if (this.tools_ini.HasKey("chm", "cmd")) {
            this.updater_binary := Format("{1}\{2}", this.base_dir, this.tools_ini.GetData()["chm"]["cmd"])

            if ! FileExist(this.updater_binary) {
                this.log.warn("Updater binary '{1}' does not exist, aborting", this.updater_binary)
                return false
            }

            SplitPath, % this.updater_binary,, tools_dir
            this.updater_config := Format("{1}\updater.cfg", tools_dir)
            this.user_config := Format("{1}\user.cfg", tools_dir)
        } else {
            return false
        }
    }

    ; quietly check for updates, only perform the check every x hours
    CheckForUpdates(minimum_check := 6) {
        last_check := 0
        now_check := this.__GetSystemTimeAsUnixTime()

        if FileExist(this.user_config) {
            user_ini := new IniConfig(this.user_config)

            if (user_ini.HasKey("Update_History", "LastUpdateCheck")) {
                last_check := user_ini.GetData()["Update_History"]["LastUpdateCheck"]
            }
        }

        ; only check if it's been long enough
        if ((now_check - last_check) > (minimum_check * 3600)) {
            Run, % Format("{1} -c", this.updater_binary)
        }
    }

    __GetSystemTimeAsUnixTime() {
        ; January 1, 1970 (start of Unix epoch) in "ticks"
        UNIX_TIME_START := 0x019DB1DED53E8000
        TICKS_PER_SECOND := 10000000

        DllCall("GetSystemTimeAsFileTime", "Int64*", UTC_Ticks)
        Return Floor((UTC_Ticks - UNIX_TIME_START) / TICKS_PER_SECOND)
    }
}
