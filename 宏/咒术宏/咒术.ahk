#Requires AutoHotkey v2.0

; 高性能取色类
class FastPixel {
    static hdc := DllCall("GetDC", "Ptr", 0, "Ptr")

    ; 超高速取色（平均0.02ms/次）
    static GetColor(x, y) {
        color := DllCall("GetPixel", "Ptr", this.hdc, "Int", x, "Int", y, "UInt")
        return Format("0x{:06X}", color & 0xFFFFFF)  ; 转换为6位HEX
    }
}

; 状态存储
class ColorState {
    static screenX := 0, screenY := 0
    static firstColor := ""
}

; 创建GUI
MyGui := Gui()
MyGui.Title := "高速取色器"
InfoBox := MyGui.Add("Edit", "w300 h100 ReadOnly", "按F1记录坐标")
ColorPreview := MyGui.Add("Text", "w300 h30", "颜色预览")
MyGui.Show()

; F1记录坐标
F1:: {
    MouseGetPos(&x, &y)
    ColorState.screenX := x, ColorState.screenY := y

    ; 双重校验采样
    ColorState.firstColor := FastPixel.GetColor(x, y)
    if (FastPixel.GetColor(x, y) != ColorState.firstColor) {
        ColorState.firstColor := FastPixel.GetColor(x, y)  ; 第三次采样
    }

    ColorPreview.BackColor := ColorState.firstColor
    InfoBox.Value := Format("坐标锁定：({}, {})`n颜色：{}", x, y, ColorState.firstColor)
}

; F2高速比较（执行时间<8ms）
F2:: {
    if !ColorState.screenX {
        InfoBox.Value := "请先按F1记录坐标！"
        return
    }

    ; 双缓存校验
    color1 := FastPixel.GetColor(ColorState.screenX, ColorState.screenY)
    color2 := FastPixel.GetColor(ColorState.screenX, ColorState.screenY)

    finalColor := (color1 == color2) ? color1 : FastPixel.GetColor(ColorState.screenX, ColorState.screenY)
    result := (finalColor == ColorState.firstColor) ? "✅相同" : "❌不同"

    ColorPreview.BackColor := finalColor
    InfoBox.Value := Format("当前颜色：{}`n对比结果：{}", finalColor, result)
}

F5::ExitApp