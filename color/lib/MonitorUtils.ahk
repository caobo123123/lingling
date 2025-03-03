; 多显示器工具类
class MonitorUtils {
    static GetMonitorAt(x, y) {
        monitors := MonitorGetCount()
        Loop monitors {
            MonitorGet(A_Index, &L, &T, &R, &B)
            if (x >= L && x <= R && y >= T && y <= B) {
                return A_Index
            }
        }
        return 1
    }
}