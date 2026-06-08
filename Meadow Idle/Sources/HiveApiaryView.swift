import SwiftUI

struct HiveApiaryView: View {
    @ObservedObject var game: HiveGameState
    @State private var pickedPlot: Int? = nil

    var body: some View {
        GeometryReader { geo in
            let screenSize = geo.size
            VStack(spacing: 10) {
                HiveHUD(game: game)
                    .padding(.top, 6)

                tierPicker

                // The grid takes the bulk of remaining space.
                HiveGridView(game: game, screenSize: screenSize,
                             pickedPlot: $pickedPlot)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 12)

                if let plot = pickedPlot, plot < game.grid.count, game.grid[plot] != nil {
                    plotInspector(plot)
                        .padding(.horizontal, 12)
                } else {
                    expansionBar
                        .padding(.horizontal, 12)
                }
            }
            .padding(.bottom, 8)
            .frame(width: screenSize.width, height: screenSize.height)
            .background(
                LinearGradient(colors: [HiveTheme.skyTop, HiveTheme.skyBottom],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }

    // Horizontal picker of unlocked honey tiers for placement.
    private var tierPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0...game.unlockedTier, id: \.self) { id in
                    let tier = HoneyCatalog.tier(id)
                    let selected = game.selectedTier == id
                    Button {
                        game.selectedTier = id
                    } label: {
                        VStack(spacing: 3) {
                            HexShape()
                                .fill(LinearGradient(colors: [tier.color, tier.accent],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(width: 26, height: 28)
                            Text(tier.name)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(HiveTheme.textDark)
                                .lineLimit(1)
                            HStack(spacing: 3) {
                                CoinIcon(size: 12)
                                Text(HiveTheme.format(tier.hiveCost))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(HiveTheme.deepAmber)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selected ? HiveTheme.honeyGold.opacity(0.35) : HiveTheme.panel)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(selected ? HiveTheme.deepAmber : HiveTheme.panelEdge,
                                                  lineWidth: selected ? 2.5 : 1.5))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private func plotInspector(_ plot: Int) -> some View {
        let placement = game.grid[plot]!
        let tier = HoneyCatalog.tier(placement.tierId)
        let mult = game.pollinationMultiplier(at: plot)
        let rate = game.plotRate(at: plot)
        return HStack(spacing: 12) {
            HexShape()
                .fill(LinearGradient(colors: [tier.color, tier.accent],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(tier.name) Hive")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                Text("\(HiveTheme.format(rate)) jars/s  •  pollination x\(String(format: "%.2f", mult))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
            }
            Spacer(minLength: 0)
            Button {
                game.removeHive(at: plot)
                pickedPlot = nil
            } label: {
                Text("Sell 40%")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(Capsule().fill(HiveTheme.danger))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HiveTheme.panel)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(HiveTheme.panelEdge, lineWidth: 1.5))
        )
    }

    private var expansionBar: some View {
        let canExpand = game.unlockedPlots < game.rows * game.cols
        let cost = game.plotUnlockCost()
        let afford = game.coins >= cost
        return HStack(spacing: 12) {
            FlowerIcon(size: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(canExpand ? "Clear a New Flower Plot" : "Apiary Fully Expanded")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                Text("\(game.unlockedPlots)/\(game.rows * game.cols) plots  •  tap a flower to place a hive")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
            }
            Spacer(minLength: 0)
            if canExpand {
                Button {
                    game.unlockNextPlot()
                } label: {
                    HStack(spacing: 4) {
                        CoinIcon(size: 16)
                        Text(HiveTheme.format(cost))
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(Capsule().fill(afford ? HiveTheme.leaf : HiveTheme.textMuted.opacity(0.5)))
                }
                .buttonStyle(.plain)
                .disabled(!afford)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HiveTheme.panel)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(HiveTheme.panelEdge, lineWidth: 1.5))
        )
    }
}
