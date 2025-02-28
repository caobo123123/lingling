; gui.ahk
CreateMainGui() {
    MyGui := Gui()
    MyGui.Title := "职业选择"
    MyGui.BackColor := "White"

    ; 列表视图
    LV := MyGui.Add("ListView", "r5 w200 vColorChoice AltSubmit", GetClassList())
    LV.OnEvent("ItemSelect", UpdateDisplay)

    ; 信息显示组件
    InfoBox := MyGui.Add("Edit", "r5 w200 vInfoBox ReadOnly", "按 F1 获取颜色信息")
    ColorPreview := MyGui.Add("Text", "w200 h30", "颜色预览")

    return {Gui: MyGui, LV: LV, InfoBox: InfoBox, Preview: ColorPreview}
}

UpdateDisplay(LV, *) {
    guiObj := LV.Gui
    selectedRow := LV.GetNext()
    if !selectedRow
        return

    selectedText := LV.GetText(selectedRow)
    colorMap := GetColorMap()

    ; 更新界面元素
    guiObj.Title := "当前选择：" selectedText
    guiObj.Preview.BackColor := colorMap[selectedText]
    guiObj.InfoBox.SetFont("c" colorMap[selectedText])
}