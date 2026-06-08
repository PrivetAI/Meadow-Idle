import SwiftUI

struct HiveShopView: View {
    @ObservedObject var game: HiveGameState

    var body: some View {
        VStack(spacing: 0) {
            HiveHUD(game: game)
                .padding(.top, 6)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    sectionHeader("Hive Upgrades")

                    upgradeCard(
                        icon: AnyView(BeeIcon(size: 30)),
                        title: "Bee Boost",
                        desc: "Lvl \(game.beeBoostLevel) • multiplies all honey output",
                        cost: game.beeBoostCost(),
                        action: { game.buyBeeBoost() })

                    upgradeCard(
                        icon: AnyView(HiveIcon(size: 30)),
                        title: "Hive Capacity",
                        desc: "Lvl \(game.capacityLevel) • room for more bees per hive",
                        cost: game.capacityCost(),
                        action: { game.buyCapacity() })

                    upgradeCard(
                        icon: AnyView(FlowerIcon(size: 30)),
                        title: "Pollination",
                        desc: "Lvl \(game.pollinationLevel) • +\(String(format: "%.0f", game.pollinationStrength * 100))% per neighbor",
                        cost: game.pollinationCost(),
                        action: { game.buyPollination() })

                    sectionHeader("Unlock Honey Tiers")

                    ForEach(HoneyCatalog.tiers) { tier in
                        tierUnlockCard(tier)
                    }

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
    }

    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(HiveTheme.textDark)
            Spacer()
        }
        .padding(.top, 4)
    }

    private func upgradeCard(icon: AnyView, title: String, desc: String,
                             cost: Double, action: @escaping () -> Void) -> some View {
        let afford = game.coins >= cost
        return HStack(spacing: 12) {
            icon.frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                Text(desc)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button(action: action) {
                VStack(spacing: 2) {
                    UpgradeArrowIcon(size: 14)
                    HStack(spacing: 3) {
                        CoinIcon(size: 13)
                        Text(HiveTheme.format(cost))
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(afford ? HiveTheme.deepAmber : HiveTheme.textMuted.opacity(0.5)))
            }
            .buttonStyle(.plain)
            .disabled(!afford)
        }
        .padding(12)
        .background(cardBg)
    }

    private func tierUnlockCard(_ tier: HoneyTier) -> some View {
        let unlocked = tier.id <= game.unlockedTier
        let isNext = tier.id == game.unlockedTier + 1
        let cost = tier.unlockCost
        let afford = game.coins >= cost
        return HStack(spacing: 12) {
            HexShape()
                .fill(LinearGradient(colors: [tier.color, tier.accent],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 32, height: 36)
            VStack(alignment: .leading, spacing: 3) {
                Text(tier.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                Text("\(HiveTheme.format(tier.baseRate)) jars/s • \(HiveTheme.format(tier.sellValue)) coins/jar")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
            }
            Spacer(minLength: 0)
            if unlocked {
                Text("Owned")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.leafDark)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Capsule().fill(HiveTheme.leaf.opacity(0.25)))
            } else if isNext {
                Button {
                    game.unlockTier(tier.id)
                } label: {
                    HStack(spacing: 3) {
                        CoinIcon(size: 14)
                        Text(HiveTheme.format(cost))
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(afford ? HiveTheme.honeyGold : HiveTheme.textMuted.opacity(0.5)))
                }
                .buttonStyle(.plain)
                .disabled(!afford)
            } else {
                Text("Locked")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Capsule().fill(HiveTheme.plotEmpty.opacity(0.5)))
            }
        }
        .padding(12)
        .background(cardBg)
        .opacity(unlocked || isNext ? 1.0 : 0.7)
    }

    private var cardBg: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(HiveTheme.panel)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(HiveTheme.panelEdge, lineWidth: 1.5))
    }
}
