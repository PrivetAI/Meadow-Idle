import SwiftUI

// The apiary grid. Renders the plots, hives, per-hive rate, and pollination glow.
// Avoids the .position() overflow pitfall: the board is inscribed inside the
// available space using min(width, height-derived) sizing and clipped to bounds.
struct HiveGridView: View {
    @ObservedObject var game: HiveGameState
    let screenSize: CGSize   // passed from parent, NOT taken from a Canvas closure
    @Binding var pickedPlot: Int?

    var body: some View {
        GeometryReader { geo in
            let avail = geo.size
            // Reserve aspect for the grid: cols x rows. Compute the largest cell
            // that fits both dimensions, then center the board.
            let spacing: CGFloat = 6
            let cellW = (avail.width - spacing * CGFloat(game.cols + 1)) / CGFloat(game.cols)
            let cellH = (avail.height - spacing * CGFloat(game.rows + 1)) / CGFloat(game.rows)
            let cell = max(28, min(cellW, cellH))
            let boardW = cell * CGFloat(game.cols) + spacing * CGFloat(game.cols + 1)
            let boardH = cell * CGFloat(game.rows) + spacing * CGFloat(game.rows + 1)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(colors: [HiveTheme.leaf.opacity(0.25),
                                                HiveTheme.cream],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(HiveTheme.leaf.opacity(0.4), lineWidth: 2))
                    .frame(width: boardW, height: boardH)

                ForEach(0..<(game.rows * game.cols), id: \.self) { idx in
                    let r = idx / game.cols
                    let c = idx % game.cols
                    let x = spacing + cell * (CGFloat(c) + 0.5) + spacing * CGFloat(c)
                    let y = spacing + cell * (CGFloat(r) + 0.5) + spacing * CGFloat(r)
                    HivePlotCell(game: game, index: idx, cell: cell,
                                 pickedPlot: $pickedPlot)
                        .frame(width: cell, height: cell)
                        // offset from board top-left, then shift board to center.
                        .position(x: x + (avail.width - boardW) / 2,
                                  y: y + (avail.height - boardH) / 2)
                }
            }
            .frame(width: avail.width, height: avail.height)
            .clipped()
        }
    }
}

struct HivePlotCell: View {
    @ObservedObject var game: HiveGameState
    let index: Int
    let cell: CGFloat
    @Binding var pickedPlot: Int?

    private var isUnlocked: Bool { index < game.unlockedPlots }
    private var placement: HivePlacement? { game.grid[index] }

    var body: some View {
        Button(action: tap) {
            ZStack {
                if !isUnlocked {
                    lockedPlot
                } else if let placement = placement {
                    hivePlot(placement)
                } else {
                    emptyPlot
                }
            }
            .frame(width: cell, height: cell)
        }
        .buttonStyle(.plain)
    }

    private func tap() {
        if let placement = placement {
            // toggle selection of an existing hive for inspect/remove
            _ = placement
            pickedPlot = (pickedPlot == index) ? nil : index
        } else if isUnlocked {
            game.placeHive(at: index)
            pickedPlot = nil
        }
    }

    private var lockedPlot: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cell * 0.18)
                .fill(HiveTheme.plotEmpty.opacity(0.4))
                .overlay(RoundedRectangle(cornerRadius: cell * 0.18)
                    .strokeBorder(HiveTheme.plotEdge.opacity(0.5),
                                  style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])))
            // padlock made of shapes
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: cell * 0.06)
                    .strokeBorder(HiveTheme.textMuted, lineWidth: cell * 0.045)
                    .frame(width: cell * 0.22, height: cell * 0.22)
                    .offset(y: cell * 0.05)
                RoundedRectangle(cornerRadius: cell * 0.05)
                    .fill(HiveTheme.textMuted)
                    .frame(width: cell * 0.34, height: cell * 0.24)
            }
        }
    }

    private var emptyPlot: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cell * 0.18)
                .fill(HiveTheme.plotEmpty)
                .overlay(RoundedRectangle(cornerRadius: cell * 0.18)
                    .strokeBorder(HiveTheme.plotEdge, lineWidth: 1.5))
            FlowerIcon(size: cell * 0.5).opacity(0.7)
            // affordable hint
            if game.coins >= HoneyCatalog.tier(game.selectedTier).hiveCost {
                PlusIcon(size: cell * 0.2, color: HiveTheme.leafDark)
                    .opacity(0.0) // kept subtle; flower communicates plot
            }
        }
    }

    private func hivePlot(_ placement: HivePlacement) -> some View {
        let tier = HoneyCatalog.tier(placement.tierId)
        let mult = game.pollinationMultiplier(at: index)
        let rate = game.plotRate(at: index)
        let glow = min(0.9, (mult - 1.0))
        let selected = pickedPlot == index
        return ZStack {
            HexShape()
                .fill(
                    LinearGradient(colors: [tier.color, tier.accent],
                                   startPoint: .top, endPoint: .bottom)
                )
                .overlay(HexShape().strokeBorder(Color.white.opacity(0.5),
                                                 lineWidth: cell * 0.03))
                .shadow(color: HiveTheme.honeyGold.opacity(glow),
                        radius: glow * 8)

            VStack(spacing: 1) {
                HiveIcon(size: cell * 0.42, color: tier.accent.opacity(0.9))
                Text(HiveTheme.format(rate))
                    .font(.system(size: cell * 0.15, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                    .lineLimit(1).minimumScaleFactor(0.5)
            }

            // pollination multiplier badge
            if mult > 1.001 {
                Text("x\(String(format: "%.2f", mult))")
                    .font(.system(size: cell * 0.13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, cell * 0.06)
                    .padding(.vertical, cell * 0.02)
                    .background(Capsule().fill(HiveTheme.leafDark))
                    .offset(y: cell * 0.36)
            }

            if selected {
                HexShape().strokeBorder(HiveTheme.danger, lineWidth: cell * 0.05)
            }
        }
    }
}
