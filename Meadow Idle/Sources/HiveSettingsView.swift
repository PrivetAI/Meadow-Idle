import SwiftUI

struct HiveSettingsView: View {
    @ObservedObject var game: HiveGameState
    @State private var showPrivacy = false
    @State private var showResetConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            HiveHUD(game: game)
                .padding(.top, 6)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Title card
                    VStack(spacing: 12) {
                        HiveIcon(size: 64)
                        Text("Meadow Idle")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(HiveTheme.textDark)
                        Text("Build an apiary, master pollination,\nand let the honey flow.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(HiveTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(cardBg)

                    howToCard

                    Button {
                        showPrivacy = true
                    } label: {
                        settingsRow(title: "Privacy Policy",
                                    icon: AnyView(ShieldIcon(size: 24)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showResetConfirm = true
                    } label: {
                        settingsRow(title: "Reset Progress",
                                    icon: AnyView(TrashIcon(size: 24)),
                                    tint: HiveTheme.danger)
                    }
                    .buttonStyle(.plain)

                    Text("Version 1.0")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HiveTheme.textMuted)
                        .padding(.top, 4)

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
            }
        }
        .background(
            LinearGradient(colors: [HiveTheme.skyTop, HiveTheme.skyBottom],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showPrivacy) {
            HiveWebPanel(urlString: "https://meadowidle.org/click.php")
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.black.ignoresSafeArea())
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset Progress?"),
                message: Text("This permanently clears your apiary, coins, and upgrades."),
                primaryButton: .destructive(Text("Reset")) {
                    game.resetProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var howToCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to Play")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(HiveTheme.textDark)
            tipRow("Tap a flower plot to place the selected hive.")
            tipRow("Place hives next to each other — adjacency pollinates and multiplies output.")
            tipRow("Higher honey tiers earn far more per jar; unlock them in the Shop.")
            tipRow("Honey auto-sells into coins, even while you're away.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBg)
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            HexShape().fill(HiveTheme.honeyGold)
                .frame(width: 12, height: 13)
                .padding(.top, 2)
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(HiveTheme.textMuted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func settingsRow(title: String, icon: AnyView,
                             tint: Color = HiveTheme.textDark) -> some View {
        HStack(spacing: 12) {
            icon.frame(width: 26, height: 26)
            Text(title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(tint)
            Spacer()
            ChevronIcon(size: 14, color: HiveTheme.textMuted)
        }
        .padding(16)
        .background(cardBg)
    }

    private var cardBg: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(HiveTheme.panel)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(HiveTheme.panelEdge, lineWidth: 1.5))
    }
}

// Small icons local to settings.
struct ShieldIcon: View {
    var size: CGFloat
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w * 0.5, y: 0))
                p.addLine(to: CGPoint(x: w, y: h * 0.2))
                p.addLine(to: CGPoint(x: w, y: h * 0.55))
                p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h),
                               control: CGPoint(x: w * 0.92, y: h * 0.92))
                p.addQuadCurve(to: CGPoint(x: 0, y: h * 0.55),
                               control: CGPoint(x: w * 0.08, y: h * 0.92))
                p.addLine(to: CGPoint(x: 0, y: h * 0.2))
                p.closeSubpath()
            }
            .fill(HiveTheme.leaf)
        }
        .frame(width: size, height: size)
    }
}

struct TrashIcon: View {
    var size: CGFloat
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            VStack(spacing: h * 0.04) {
                RoundedRectangle(cornerRadius: w * 0.05)
                    .fill(HiveTheme.danger)
                    .frame(width: w * 0.8, height: h * 0.12)
                RoundedRectangle(cornerRadius: w * 0.08)
                    .fill(HiveTheme.danger)
                    .frame(width: w * 0.68, height: h * 0.72)
            }
            .frame(width: w, height: h)
        }
        .frame(width: size, height: size)
    }
}

struct ChevronIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                p.move(to: CGPoint(x: w * 0.3, y: h * 0.15))
                p.addLine(to: CGPoint(x: w * 0.7, y: h * 0.5))
                p.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
            }
            .stroke(color, style: StrokeStyle(lineWidth: w * 0.18,
                                              lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}
