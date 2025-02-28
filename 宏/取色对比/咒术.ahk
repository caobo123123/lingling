#Requires AutoHotkey v2.0

class ColorTracker {
    static instances := Map()

    __New(config := unset) {
        ; 初始化配置
        this.config := {
            coordMode: "Screen",
            markerColor: "FF0000",
            markerDuration: 500,
            checkMonitor: true
        }
        if IsSet(config)
            this.config := this.config.Clone().Merge(config)

        ; 初始化状态
        this.records := Map()
        this._setupCoordMode()
    }

    ; ================= 公共方法 =================
    Record(x, y) {
        try {
            color := PixelGetColor(x, y)
            monitor := this._getMonitor(x, y)

            record := Map(
                "x", x,
                "y", y,
                "color", color,
                "timestamp", A_Now,
                "monitor", monitor
            )

            this.records["default"] := record
            this._showMarker(x, y)
            return record
        } catch as e {
            throw Error("记录失败: " e.Message)
        }
    }

    Compare(tolerance := 0) {
        if !this.records.Has("default")
            throw Error("无有效记录")

        record := this.records["default"]
        currentColor := PixelGetColor(record.x, record.y)

        ; 验证显示器
        if this.config.checkMonitor && (this._getMonitor(record.x, record.y) != record.monitor)
            throw Error("显示器配置已变更")

        ; 计算差异
        delta := this._colorDelta(record.color, currentColor)

        return {
            match: (delta.total <= tolerance),
            original: record.color,
            current: currentColor,
            delta: delta,
            duration: this._calcDuration(record.timestamp)
        }
    }

    ; ================= 工具方法 =================
    ShowMarker(x, y) {
        this._showMarker(x, y)
    }

    ClearRecord() {
        this.records.Delete("default")
    }

    ; ================= 内部方法 =================
    _setupCoordMode() {
        CoordMode "Mouse", this.config.coordMode
        CoordMode "Pixel", this.config.coordMode
    }

    _showMarker(x, y) {
        gui := Gui("+ToolWindow -Caption +AlwaysOnTop")
        gui.BackColor := this.config.markerColor
        gui.Opt("+E0x20")  ; 点击穿透
        gui.Add("Text", "x0 y0 w2 h20 Background" this.config.markerColor)
        gui.Add("Text", "x0 y0 w20 h2 Background" this.config.markerColor)
        gui.Show("NA x" x-10 " y" y-10)
        SetTimer(() => gui.Destroy(), -this.config.markerDuration)
    }

    _getMonitor(x, y) {
        Loop MonitorGetCount() {
            MonitorGet(A_Index, &L, &T, &R, &B)
            if (x >= L && x <= R) && (y >= T && y <= B)
                return A_Index
        }
        return 0
    }

    _colorDelta(color1, color2) {
        c1 := this._hexToRGB(color1)
        c2 := this._hexToRGB(color2)

        return {
            red: Abs(c1[1] - c2[1]),
            green: Abs(c1[2] - c2[2]),
            blue: Abs(c1[3] - c2[3]),
            total: Abs(c1[1] + c1[2] + c1[3] - c2[1] - c2[2] - c2[3])
        }
    }

    _hexToRGB(hex) {
        hex := StrReplace(hex, "0x")
        return [
            Integer("0x" SubStr(hex, 1, 2)),
            Integer("0x" SubStr(hex, 3, 2)),
            Integer("0x" SubStr(hex, 5, 2))
        ]
    }

    _calcDuration(timestamp) {
        return (A_Now - timestamp) * 86400  ; 转换为秒
    }
}

class CoordDisplay {
    static Create() {
        gui := Gui("+ToolWindow -Caption +AlwaysOnTop")
        gui.BackColor := "EEAA99"
        text := gui.Add("Text", "w240 h30 Center", "屏幕坐标 (X: 0, Y: 0)")
        return {gui: gui, text: text}
    }

    static Update(display, x, y) {
        display.text.Text := Format("屏幕坐标 (X: {}, Y: {})", x, y)
        display.gui.Show("NA x" x+20 " y" y+20)
    }
}