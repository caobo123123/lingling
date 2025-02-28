; color_ops.ahk
class ColorComparator {
    static lastPos := {x: 0, y: 0}
    static firstColor := ""

    static GetColor(x, y) {
        color := PixelGetColor(x, y, 'RGB')
        return StrReplace(color, '0x', '#')
    }

    static CompareColors() {
        if !this.lastPos.x && !this.lastPos.y
            return "请先使用F1获取坐标！"

        currentColor := this.GetColor(this.lastPos.x, this.lastPos.y)
        result := (this.firstColor == currentColor) ? "相同" : "不同"

        return Format("
        (
        F1坐标：({1}, {2})
        首次颜色：{3}
        当前颜色：{4}
        比较结果：{5}
        )", this.lastPos.x, this.lastPos.y, this.firstColor, currentColor, result)
    }
}