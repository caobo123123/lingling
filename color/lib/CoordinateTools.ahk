; 坐标工具类
class CoordinateTools {
    static ShowMarker(x, y) {
        markerGui := Gui("+ToolWindow -Caption +AlwaysOnTop")
        markerGui.BackColor := "FF0000"
        markerGui.Opt("+E0x20 -DPIScale")

        markerGui.Add("Text", "x0 y0 w2 h20 BackgroundRed")
        markerGui.Add("Text", "x0 y0 w20 h2 BackgroundRed")
        markerGui.Show("NA x" x-10 " y" y-10)
        SetTimer(() => markerGui.Destroy(), -500)
    }

    static CreateCoordTip() {
        coordTip := Gui("+ToolWindow -Caption +AlwaysOnTop")
        coordTip.BackColor := "EEAA99"
        coordTip.SetFont("s10 bold")
        coordText := coordTip.Add("Text", "w240 h30 Center", "屏幕坐标 (X: 0, Y: 0)")
        return {gui: coordTip, text: coordText}
    }
}