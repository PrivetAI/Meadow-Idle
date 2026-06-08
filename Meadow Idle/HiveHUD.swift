import SwiftUI

// Top resource bar shown across screens.
struct HiveHUD: View {
    @ObservedObject var game: HiveGameState

    var body: some View {
        HStack(spacing: 10) {
            statPill(icon: AnyView(CoinIcon(size: 22)),
                     value: HiveTheme.format(game.coins),
                     sub: "+\(HiveTheme.format(game.coinsPerSecond))/s",
                     tint: HiveTheme.deepAmber)

            statPill(icon: AnyView(HoneyDropIcon(size: 20)),
                     value: HiveTheme.format(game.totalHoneyPerSecond),
                     sub: "jars/s",
                     tint: HiveTheme.honeyGold)

            statPill(icon: AnyView(BeeIcon(size: 22)),
                     value: HiveTheme.format(game.beePopulation),
                     sub: "/ \(HiveTheme.format(game.maxBeeCapacity))",
                     tint: HiveTheme.leaf)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(HiveTheme.panel)
                .overlay(RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(HiveTheme.panelEdge, lineWidth: 1.5))
        )
        .padding(.horizontal, 12)
    }

    private func statPill(icon: AnyView, value: String, sub: String, tint: Color) -> some View {
        HStack(spacing: 7) {
            icon.frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(sub)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
