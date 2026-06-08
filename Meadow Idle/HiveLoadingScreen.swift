import SwiftUI

struct HiveLoadingScreen: View {
    @State private var spin = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [HiveTheme.skyTop, HiveTheme.skyBottom],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    // Honeycomb ring spinning around the hive.
                    ForEach(0..<6) { i in
                        HexShape()
                            .fill(HiveTheme.honeyGold.opacity(0.85))
                            .frame(width: 26, height: 30)
                            .offset(y: -70)
                            .rotationEffect(.degrees(Double(i) * 60))
                    }
                    .rotationEffect(.degrees(spin ? 360 : 0))

                    HiveIcon(size: 92)
                        .scaleEffect(pulse ? 1.06 : 0.94)
                }
                .frame(width: 170, height: 170)

                Text("Meadow Idle")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)

                Text("Warming the comb...")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                spin = true
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
