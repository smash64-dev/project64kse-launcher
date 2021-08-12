; kaillera.ahk

#Include %A_LineFile%\..\..\lib\ini_config.ahk
#Include %A_LineFile%\..\..\lib\logger.ahk

class Kaillera {
    static klog := {}

    base_dir := ""
    config_path := ""
    config_ini := ""
    monitors := []

    __New(base_dir, config_file) {
        klog := new Logger("kaillera.ahk")
        this.log := klog

        this.base_dir := base_dir
        this.config_file := Format("{1}\{2}", base_dir, config_file)
        if ! FileExist(this.config_file) {
            this.log.warn("Config file '{1}' does not exist, aborting", this.config_file)
            return false
        }

        this.config_ini := new IniConfig(this.config_file)
    }

    ; ensure config values for window positions are visible
    VerifyConfig() {
        config_data := this.config_ini.GetData()

        ; fix kaillera windows appearing offscreen when monitors and/or resolutions change
        for index, window_type in Array("SC", "p2p") {
            valid := false

            for index, monitor in this.__GetMonitorsBounds() {
                if this.__EnsureWindowIsVisible(monitor, config_data[window_type]["XPOS"], config_data[window_type]["YPOS"]) {
                    valid := true
                    break
                }
            }

            ; let kaillera regenerate its own config
            if (! valid) {
                this.config_ini.__DeleteProperty(window_type, "XPOS")
                this.config_ini.__DeleteProperty(window_type, "YPOS")
                this.config_ini.WriteConfig()
            }
        }
    }

    ; determine if the top left coordinates of a window are visible on monitor
    __EnsureWindowIsVisible(monitor, win_x, win_y) {
        if (win_x >= monitor.left and win_x <= monitor.right) {
            if (win_y >= monitor.top and win_y <= monitor.bottom) {
                return true
            }
        }

        return false
    }

    ; get the coordinate bounds of each monitor
    __GetMonitorsBounds() {
        SysGet, monitors, MonitorCount
        loop %monitors%
        {
            SysGet bounds, Monitor, %A_Index%
            monitor := { left: boundsLeft, top: boundsTop, right: boundsRight, bottom: boundsBottom }
            monitor.height := monitor.bottom - monitor.top
            monitor.width := monitor.right - monitor.left

            this.monitors[A_Index] := monitor
        }

        return this.monitors
    }
}
