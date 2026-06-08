import SwiftUI

// All icons are pure SwiftUI Shapes / drawings — no SF Symbols, no emoji.

// A pointy-top hexagon, the core honeycomb motif.
// Conforms to InsettableShape so `.strokeBorder` can be used for crisp inner edges.
struct HexShape: InsettableShape {
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: inset, dy: inset)
        var p = Path()
        let w = r.width, h = r.height
        let cx = r.midX, cy = r.midY
        let rx = w / 2, ry = h / 2
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 2
            let pt = CGPoint(x: cx + rx * cos(angle), y: cy + ry * sin(angle))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }

    func inset(by amount: CGFloat) -> HexShape {
        var copy = self
        copy.inset += amount
        return copy
    }
}

// A stylized hive (stacked skep dome).
struct HiveIcon: View {
    var size: CGFloat
    var color: Color = HiveTheme.deepAmber
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Stacked bands of the skep.
                VStack(spacing: w * 0.04) {
                    Capsule().fill(color.opacity(0.95)).frame(height: h * 0.16)
                        .frame(width: w * 0.42)
                    Capsule().fill(color.opacity(0.95)).frame(height: h * 0.16)
                        .frame(width: w * 0.62)
                    Capsule().fill(color.opacity(0.95)).frame(height: h * 0.16)
                        .frame(width: w * 0.80)
                    Capsule().fill(color.opacity(0.95)).frame(height: h * 0.16)
                        .frame(width: w * 0.92)
                }
                // Entrance hole.
                Circle().fill(HiveTheme.darkComb)
                    .frame(width: w * 0.16, height: w * 0.16)
                    .offset(y: h * 0.30)
            }
            .frame(width: w, height: h, alignment: .center)
        }
        .frame(width: size, height: size)
    }
}

// A simple bee made of an oval body with stripes and wings.
struct BeeIcon: View {
    var size: CGFloat
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Wings
                Ellipse().fill(Color.white.opacity(0.75))
                    .frame(width: w * 0.34, height: h * 0.24)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -w * 0.04, y: -h * 0.22)
                Ellipse().fill(Color.white.opacity(0.75))
                    .frame(width: w * 0.34, height: h * 0.24)
                    .rotationEffect(.degrees(25))
                    .offset(x: w * 0.18, y: -h * 0.22)
                // Body
                Ellipse().fill(HiveTheme.darkComb)
                    .frame(width: w * 0.66, height: h * 0.5)
                    .offset(y: h * 0.05)
                // Stripes
                HStack(spacing: w * 0.05) {
                    Capsule().fill(HiveTheme.honeyGold).frame(width: w * 0.07, height: h * 0.34)
                    Capsule().fill(HiveTheme.honeyGold).frame(width: w * 0.07, height: h * 0.40)
                    Capsule().fill(HiveTheme.honeyGold).frame(width: w * 0.07, height: h * 0.30)
                }
                .offset(y: h * 0.05)
            }
            .frame(width: w, height: h)
        }
        .frame(width: size, height: size)
    }
}

// A honey jar / drop used to represent honey resource.
struct HoneyDropIcon: View {
    var size: CGFloat
    var color: Color = HiveTheme.honeyGold
    var body: some View {
        DropShape()
            .fill(
                LinearGradient(colors: [color, color.opacity(0.7)],
                               startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                Circle().fill(Color.white.opacity(0.45))
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: -size * 0.12, y: size * 0.08)
            )
            .frame(width: size, height: size)
    }
}

struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addCurve(to: CGPoint(x: w, y: h * 0.65),
                   control1: CGPoint(x: w * 0.85, y: h * 0.18),
                   control2: CGPoint(x: w, y: h * 0.42))
        p.addArc(center: CGPoint(x: w * 0.5, y: h * 0.65),
                 radius: w * 0.5, startAngle: .degrees(0),
                 endAngle: .degrees(180), clockwise: false)
        p.addCurve(to: CGPoint(x: w * 0.5, y: 0),
                   control1: CGPoint(x: 0, y: h * 0.42),
                   control2: CGPoint(x: w * 0.15, y: h * 0.18))
        p.closeSubpath()
        return p
    }
}

// A coin icon (concentric circles with a hex stamp).
struct CoinIcon: View {
    var size: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(HiveTheme.coinSilver)
            Circle().strokeBorder(HiveTheme.deepAmber.opacity(0.6), lineWidth: size * 0.06)
            HexShape().fill(HiveTheme.deepAmber.opacity(0.55))
                .frame(width: size * 0.42, height: size * 0.46)
        }
        .frame(width: size, height: size)
    }
}

// A flower icon for empty plots.
struct FlowerIcon: View {
    var size: CGFloat
    var color: Color = HiveTheme.leaf
    var petalColor: Color = Color(red: 0.95, green: 0.62, blue: 0.74)
    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Ellipse().fill(petalColor)
                    .frame(width: size * 0.26, height: size * 0.5)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            Circle().fill(HiveTheme.honeyGold)
                .frame(width: size * 0.30, height: size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

// Plus icon for buy buttons.
struct PlusIcon: View {
    var size: CGFloat
    var color: Color = .white
    var body: some View {
        ZStack {
            Capsule().fill(color).frame(width: size, height: size * 0.22)
            Capsule().fill(color).frame(width: size * 0.22, height: size)
        }
        .frame(width: size, height: size)
    }
}

// Arrow-up icon for upgrades.
struct UpgradeArrowIcon: View {
    var size: CGFloat
    var color: Color = .white
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
                p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.9))
                p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.9))
                p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.55))
                p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.55))
                p.closeSubpath()
            }
            .fill(color)
        }
        .frame(width: size, height: size)
    }
}

// Gear-like icon for settings (made of overlapping rounded rects + circle).
struct SettingsGearIcon: View {
    var size: CGFloat
    var color: Color = HiveTheme.textDark
    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(color)
                    .frame(width: size * 0.18, height: size * 0.9)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            Circle().fill(color).frame(width: size * 0.7, height: size * 0.7)
            Circle().fill(HiveTheme.cream).frame(width: size * 0.32, height: size * 0.32)
        }
        .frame(width: size, height: size)
    }
}

// Grid icon for the apiary tab.
struct GridTabIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        let s = size
        VStack(spacing: s * 0.12) {
            ForEach(0..<2) { _ in
                HStack(spacing: s * 0.12) {
                    HexShape().fill(color).frame(width: s * 0.36, height: s * 0.40)
                    HexShape().fill(color).frame(width: s * 0.36, height: s * 0.40)
                }
            }
        }
        .frame(width: s, height: s)
    }
}

// Shop bag icon.
struct ShopTabIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.12)
                    .fill(color)
                    .frame(width: w * 0.78, height: h * 0.62)
                    .offset(y: h * 0.14)
                // handle
                RoundedRectangle(cornerRadius: w * 0.1)
                    .strokeBorder(color, lineWidth: w * 0.08)
                    .frame(width: w * 0.42, height: h * 0.36)
                    .offset(y: -h * 0.18)
            }
            .frame(width: w, height: h)
        }
        .frame(width: size, height: size)
    }
}
