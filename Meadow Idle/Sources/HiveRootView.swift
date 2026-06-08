import SwiftUI

struct HiveRootView: View {
    @StateObject private var game = HiveGameState()
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var offlineEarned: Double? = nil
    @State private var didApplyOffline = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { tabContent(HiveApiaryView(game: game)) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { tabContent(HiveShopView(game: game)) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { tabContent(HiveSettingsView(game: game)) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }

            if let earned = offlineEarned {
                offlinePopup(earned)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            game.startLoop()
            if !didApplyOffline {
                didApplyOffline = true
                let secs = game.offlineSeconds()
                let earned = game.applyOfflineEarnings(seconds: secs)
                if earned > 1 {
                    offlineEarned = earned
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                // Stamp lastActive ONLY on .background. NOT on .inactive — .inactive
                // fires in both directions and would zero out the offline credit.
                game.stampLastActive()
                game.stopLoop()
            case .active:
                game.startLoop()
            case .inactive:
                // Intentionally do nothing here.
                break
            @unknown default:
                break
            }
        }
    }

    private func tabContent<V: View>(_ view: V) -> some View {
        view
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Apiary",
                      icon: AnyView(GridTabIcon(size: 24,
                          color: selectedTab == 0 ? HiveTheme.deepAmber : HiveTheme.textMuted.opacity(0.55))))
            tabButton(index: 1, label: "Shop",
                      icon: AnyView(ShopTabIcon(size: 24,
                          color: selectedTab == 1 ? HiveTheme.deepAmber : HiveTheme.textMuted.opacity(0.55))))
            tabButton(index: 2, label: "More",
                      icon: AnyView(SettingsGearIcon(size: 24,
                          color: selectedTab == 2 ? HiveTheme.deepAmber : HiveTheme.textMuted.opacity(0.55))))
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            HiveTheme.panel
                .overlay(Rectangle().fill(HiveTheme.panelEdge).frame(height: 1.5), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(index: Int, label: String, icon: AnyView) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                icon.frame(width: 26, height: 26)
                Text(label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(selectedTab == index ? HiveTheme.deepAmber : HiveTheme.textMuted.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func offlinePopup(_ earned: Double) -> some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { offlineEarned = nil }
            VStack(spacing: 16) {
                ZStack {
                    ForEach(0..<6) { i in
                        HexShape().fill(HiveTheme.honeyGold.opacity(0.6))
                            .frame(width: 18, height: 20)
                            .offset(y: -44)
                            .rotationEffect(.degrees(Double(i) * 60))
                    }
                    HiveIcon(size: 58)
                }
                .frame(width: 110, height: 110)

                Text("Welcome Back!")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(HiveTheme.textDark)
                Text("Your bees kept working while you were away.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(HiveTheme.textMuted)
                HStack(spacing: 8) {
                    CoinIcon(size: 26)
                    Text("+\(HiveTheme.format(earned))")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(HiveTheme.deepAmber)
                }
                Button {
                    offlineEarned = nil
                } label: {
                    Text("Collect")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40).padding(.vertical, 12)
                        .background(Capsule().fill(HiveTheme.leaf))
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(HiveTheme.cream)
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(HiveTheme.panelEdge, lineWidth: 2))
            )
            .padding(40)
        }
    }
}
