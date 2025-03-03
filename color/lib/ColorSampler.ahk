#Include MonitorUtils.ahk
#Include CoordinateTools.ahk

class ColorSampler {
    __New() {
        this.colorData := Map(
            "x", 0,
            "y", 0,
            "color", "",
            "timestamp", 0,
            "monitor", 0
        )
    }

    RecordColor() {
        MouseGetPos(&x, &y)
        this.colorData["x"] := x
        this.colorData["y"] := y
        this.colorData["color"] := PixelGetColor(x, y)
        this.colorData["timestamp"] := A_Now
        this.colorData["monitor"] := MonitorUtils.GetMonitorAt(x, y)

        CoordinateTools.ShowMarker(x, y)
        return this.FormatRecordInfo(x, y)
    }

    CompareColor() {
        if (this.colorData["x"] = 0) {
            return "请先记录颜色！"
        }

        x := this.colorData["x"]
        y := this.colorData["y"]
        currentMonitor := MonitorUtils.GetMonitorAt(x, y)
        if (currentMonitor != this.colorData["monitor"]) {
            return Format("警告：目标点已不在原显示器！#{}", currentMonitor)
        }

        currentColor := PixelGetColor(x, y)
        duration := (A_Now - this.colorData["timestamp"]) * 86400
        CoordinateTools.ShowMarker(x, y)

        return this.FormatCompareInfo(currentColor, duration)
    }

    FormatRecordInfo(x, y) {
        formattedTime := FormatTime(this.colorData["timestamp"], "HH:mm:ss")
        return Format("
        (
        【记录成功 - 屏幕坐标】
        坐标：({}, {})
        颜色值：{}
        时间：{}
        显示器：#{}
        )", x, y, this.colorData["color"], formattedTime, this.colorData["monitor"])
    }

    FormatCompareInfo(currentColor, duration) {
        return Format("
        (
        【对比结果 - 屏幕坐标】
        目标坐标：({}, {})
        原始颜色：{}
        当前颜色：{}
        状态：{}
        已持续：{}秒
        )",
        this.colorData["x"], this.colorData["y"],
        this.colorData["color"], currentColor,
        (this.colorData["color"] = currentColor) ? "✅匹配" : "❌变化",
        duration)
    }
}