#Requires AutoHotkey v2.0
#SingleInstance Force

global DebugMode := true

F1:: LogTest("常规连招测试")

LogTest(msg) {
    if DebugMode {
        FileAppend FormatTime(, "HH:mm:ss") " - " msg "`n", "debug.log"
        ToolTip msg
        SetTimer () => ToolTip(), -1000
    }
}12