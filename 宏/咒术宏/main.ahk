; main.ahk
#Requires AutoHotkey v2.0
#Include config.ahk
#Include gui.ahk
#Include color_ops.ahk

; 初始化GUI
mainGui := CreateMainGui()
mainGui.Gui.Show()

; 热键绑定
F1:: {
    MouseGetPos(&x, &y)
    ColorComparator.lastPos := {x: x, y: y}
    ColorComparator.firstColor := ColorComparator.GetColor(x, y)
    mainGui.InfoBox.Value := Format("F1坐标：({1}, {2})`n颜色值：{3}", x, y, ColorComparator.firstColor)
}

F2:: {
    if !ColorComparator.lastPos.x
        return mainGui.InfoBox.Value := "请先使用F1获取坐标！"

    result := ColorComparator.CompareColors()
    mainGui.InfoBox.Value := result
}

F5::ExitApp