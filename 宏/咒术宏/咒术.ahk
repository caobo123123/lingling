#Requires AutoHotkey v2.0
#SingleInstance Force

; 设置全局坐标模式为屏幕坐标系
CoordMode "Mouse", "Screen"   ; 鼠标相关操作使用屏幕坐标
CoordMode "Pixel", "Screen"   ; 像素相关操作使用屏幕坐标

; 实时坐标显示（带屏幕坐标系标识）
coordTip := Gui("+ToolWindow -Caption +AlwaysOnTop")
coordTip.BackColor := "EEAA99"
coordTip.SetFont("s10 bold")
coordText := coordTip.Add("Text", "w240 h30 Center", "屏幕坐标 (X: 0, Y: 0)")
SetTimer(UpdateCoordTip, 50)

; 主界面增强
mainGui := Gui()
mainGui.Title := "屏幕坐标取色器 v2"
mainGui.SetFont("s10")
mainGui.Add("Text", "w400", "操作说明：`nF1 - 记录当前屏幕坐标颜色`nF2 - 对比记录点的颜色变化`nF5 - 退出程序")
resultBox := mainGui.Add("Edit", "w400 h150 ReadOnly")
mainGui.Show()

; 数据存储升级
Global colorData := Map(
    "x", 0,
    "y", 0,
    "color", "",
    "timestamp", 0,
    "monitor", 0  ; 记录所在显示器
)

UpdateCoordTip() {
    MouseGetPos(&x, &y)
    ; 添加显示器信息
    monitor := GetMonitorAt(x, y)
    coordText.Text := Format("屏幕坐标 (X: {}, Y: {})`n显示器 #{}", x, y, monitor)
    coordTip.Show("NA x" x+20 " y" y+20)
}

; 新增函数：获取指定坐标的显示器编号
GetMonitorAt(x, y) {
    monitors := MonitorGetCount()
    Loop monitors {
        MonitorGet(A_Index, &L, &T, &R, &B)
        if (x >= L && x <= R && y >= T && y <= B) {
            return A_Index
        }
    }
    return 1
}

ShowMarker(x, y) {
    ; 优化标记显示（兼容多显示器）
    markerGui := Gui("+ToolWindow -Caption +AlwaysOnTop")
    markerGui.BackColor := "FF0000"
    markerGui.Opt("+E0x20 -DPIScale")

    ; 绘制十字准星
    markerGui.Add("Text", "x0 y0 w2 h20 BackgroundRed")   ; 垂直
    markerGui.Add("Text", "x0 y0 w20 h2 BackgroundRed")   ; 水平
    markerGui.Show("NA x" x-10 " y" y-10)
    SetTimer(() => markerGui.Destroy(), -500)
}
; 修改时间记录方式
F1:: {
    MouseGetPos(&x, &y)
    colorData["x"] := x
    colorData["y"] := y
    colorData["color"] := PixelGetColor(x, y)
    colorData["timestamp"] := A_Now  ; 使用标准时间戳
    colorData["monitor"] := GetMonitorAt(x, y)

    ShowMarker(x, y)
    ; 直接格式化时间
    formattedTime := FormatTime(colorData["timestamp"], "HH:mm:ss")
    resultBox.Value := Format("
    (
    【记录成功 - 屏幕坐标】
    坐标：({}, {})
    颜色值：{}
    时间：{}
    显示器：#{}
    )", x, y, colorData["color"], formattedTime, colorData["monitor"])
}

; 修改持续时间计算方式
F2:: {
    if (colorData["x"] = 0) {
        resultBox.Value := "请先按F1记录颜色！"
        return
    }

    currentMonitor := GetMonitorAt(colorData["x"], colorData["y"])
    if (currentMonitor != colorData["monitor"]) {
        resultBox.Value := "警告：目标点已不在原显示器！#" currentMonitor
        return
    }

    currentColor := PixelGetColor(colorData["x"], colorData["y"])
    ShowMarker(colorData["x"], colorData["y"])

    ; 计算持续时间（秒）
    duration := (A_Now - colorData["timestamp"]) * 86400  ; 转换天数为秒
    resultBox.Value := Format("
    (
    【对比结果 - 屏幕坐标】
    目标坐标：({}, {})
    原始颜色：{}
    当前颜色：{}
    状态：{}
    已持续：{}秒
    )",
    colorData["x"], colorData["y"],
    colorData["color"], currentColor,
    (colorData["color"] = currentColor) ? "✅匹配" : "❌变化",
    duration)
}

F5:: ExitApp