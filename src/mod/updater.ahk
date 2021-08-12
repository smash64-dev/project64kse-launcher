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

            SplitPath, % this.updater_binary,, tools_dir
            this.updater_config := Format("{1}\updater.cfg", tools_dir)
            this.user_config := Format("{1}\user.cfg", tools_dir)
        }
    }
}
