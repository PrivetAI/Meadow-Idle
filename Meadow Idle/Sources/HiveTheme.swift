import SwiftUI

// Theme-independent palette. All colors are explicit RGB so the app looks
// identical regardless of the device's light/dark setting.
enum HiveTheme {
    static let honeyGold = Color(red: 0.96, green: 0.71, blue: 0.16)
    static let deepAmber = Color(red: 0.78, green: 0.48, blue: 0.06)
    static let darkComb  = Color(red: 0.45, green: 0.28, blue: 0.04)
    static let cream     = Color(red: 0.99, green: 0.96, blue: 0.88)
    static let panel     = Color(red: 1.00, green: 0.98, blue: 0.92)
    static let panelEdge = Color(red: 0.88, green: 0.78, blue: 0.55)
    static let leaf      = Color(red: 0.36, green: 0.58, blue: 0.27)
    static let leafDark  = Color(red: 0.24, green: 0.42, blue: 0.18)
    static let textDark  = Color(red: 0.27, green: 0.18, blue: 0.05)
    static let textMuted = Color(red: 0.52, green: 0.42, blue: 0.26)
    static let plotEmpty = Color(red: 0.86, green: 0.80, blue: 0.62)
    static let plotEdge  = Color(red: 0.74, green: 0.66, blue: 0.45)
    static let coinSilver = Color(red: 0.95, green: 0.83, blue: 0.40)
    static let danger    = Color(red: 0.80, green: 0.32, blue: 0.20)
    static let skyTop    = Color(red: 0.74, green: 0.88, blue: 0.97)
    static let skyBottom = Color(red: 0.99, green: 0.96, blue: 0.85)

    static func format(_ value: Double) -> String {
        // Guard against NaN / Infinity / negatives so the UI never shows "nan"/"inf".
        guard value.isFinite else { return "0" }
        let v = max(0, value)
        if v < 1000 {
            if v < 10 && v != floor(v) {
                return String(format: "%.1f", v)
            }
            return String(Int(v))
        }
        let units = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp"]
        var idx = 0
        var n = v
        while n >= 1000 && idx < units.count - 1 {
            n /= 1000
            idx += 1
        }
        return String(format: "%.2f%@", n, units[idx])
    }
}
