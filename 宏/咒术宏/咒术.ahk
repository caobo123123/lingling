#Requires AutoHotkey v2.0

; 目标窗口信息存储
class TargetWindow {
    static hwnd := 0
    static clientX := 0, clientY := 0
    static width := 0, height := 0
}

; 创建GUI
MyGui := Gui()
MyGui.Title := "窗口颜色检测器"
MyGui.Add("Text",, "F3: 选择目标窗口`nF1: 记录颜色`nF2: 对比颜色")
InfoBox := MyGui.Add("Edit", "w400 h150 ReadOnly", "操作提示：")
MyGui.Show()

; F3：选择目标窗口
F3:: {
    MouseGetPos(,, &hoverHwnd)
    if !WinExist(hoverHwnd) {
        InfoBox.Value := "无效窗口！"
        return
    }

    ; 获取窗口客户区位置
    WinGetClientPos(&x, &y, &w, &h, hoverHwnd)
    TargetWindow.hwnd := hoverHwnd
    TargetWindow.clientX := x
    TargetWindow.clientY := y
    TargetWindow.width := w
    TargetWindow.height := h

    InfoBox.Value := Format("
    (
    █ 已选择目标窗口
    █ 客户区尺寸：{}x{}
    █ 屏幕位置：({}, {})
    )", w, h, x, y)
}

; 通用坐标转换函数
GetWindowColorInfo() {
    ; 获取屏幕坐标
    MouseGetPos(&screenX, &screenY)

    ; 转换到窗口客户区坐标
    winX := screenX - TargetWindow.clientX
    winY := screenY - TargetWindow.clientY

    ; 坐标有效性验证
    if (winX < 0 || winY < 0 || winX > TargetWindow.width || winY > TargetWindow.height) {
        return {valid: false}
    }

    ; 获取颜色
    color := PixelGetColor(screenX, screenY, "RGB")
    return {x: winX, y: winY, color: "0x" StrReplace(color, "0x"), valid: true}
}

; F1：记录颜色
F1:: {
    if !TargetWindow.hwnd {
        InfoBox.Value := "请先按F3选择目标窗口！"
        return
    }

    info := GetWindowColorInfo()
    if !info.valid {
        InfoBox.Value := Format("坐标超出窗口范围！`n客户区尺寸：{}x{}", TargetWindow.width, TargetWindow.height)
        return
    }

    ; 存储首次记录
    persistent FirstRecord := {x: info.x, y: info.y, color: info.color}

    InfoBox.Value := Format("
    (
    █ 窗口坐标：({}, {})
    █ 颜色值：{}
    █ 屏幕坐标：({}, {})
    )",
    info.x, info.y, info.color,
    info.x + TargetWindow.clientX, info.y + TargetWindow.clientY)
}

; F2：对比颜色
F2:: {
    if !FirstRecord.HasProp("x") {
        InfoBox.Value := "请先按F1记录初始颜色！"
        return
    }

    ; 获取当前颜色
    WinGetClientPos(,, &w, &h, TargetWindow.hwnd)
    if (FirstRecord.x > w || FirstRecord.y > h) {
        InfoBox.Value := "目标坐标超出当前窗口范围！"
        return
    }

    ; 计算实际屏幕坐标
    absX := TargetWindow.clientX + FirstRecord.x
    absY := TargetWindow.clientY + FirstRecord.y

    ; 获取颜色
    currentColor := "0x" StrReplace(PixelGetColor(absX, absY, "RGB"), "0x")

    ; 生成报告
    report := Format("
    (
    █ 目标位置：({}, {}) in window
    █ 首次颜色：{}
    █ 当前颜色：{}
    █ 对比结果：{}
    )",
    FirstRecord.x, FirstRecord.y,
    FirstRecord.color, currentColor,
    (FirstRecord.color == currentColor) ? "相同 ✅" : "不同 ❌")

    InfoBox.Value := report
}

F5::ExitApp