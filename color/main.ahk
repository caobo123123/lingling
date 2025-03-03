#SingleInstance Force
#Include lib\CoordinateTools.ahk
#Include lib\ColorSampler.ahk
#Include lib\MonitorUtils.ahk

; 初始化组件
sampler := ColorSampler()
coordTip := CoordinateTools.CreateCoordTip()
SetTimer(UpdateCoordTip, 50)

; 主界面
mainGui := Gui()
mainGui.Title := "屏幕坐标取色器 v2"
mainGui.SetFont("s10")
mainGui.Add("Text", "w400", "操作说明：`nF1 - 记录颜色`nF2 - 对比颜色`nF5 - 退出")
resultBox := mainGui.Add("Edit", "w400 h150 ReadOnly")
mainGui.Show()

; 实时坐标更新函数
UpdateCoordTip() {
    MouseGetPos(&x, &y)
    monitor := MonitorUtils.GetMonitorAt(x, y)
    coordTip.text.Text := Format("屏幕坐标 (X: {}, Y: {})`n显示器 #{}", x, y, monitor)
    coordTip.gui.Show("NA x" x+20 " y" y+20)
}

; 热键绑定
F1:: resultBox.Value := sampler.RecordColor()
F2:: resultBox.Value := sampler.CompareColor()
F5:: ExitApp