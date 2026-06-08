import SwiftUI

// Escalating honey tiers. Each tier produces more value per jar but the hive
// costs far more to place, keeping the economy in check.
struct HoneyTier: Identifiable {
    let id: Int
    let name: String
    let baseRate: Double      // jars per second from a single hive of this tier
    let sellValue: Double     // coins earned per jar when sold
    let hiveCost: Double      // coins to place a hive of this tier
    let unlockCost: Double    // coins to unlock this tier (0 = starts unlocked)
    let color: Color
    let accent: Color
}

enum HoneyCatalog {
    static let tiers: [HoneyTier] = [
        HoneyTier(id: 0, name: "Clover",
                  baseRate: 0.40, sellValue: 1.0, hiveCost: 15, unlockCost: 0,
                  color: Color(red: 0.98, green: 0.86, blue: 0.45),
                  accent: Color(red: 0.85, green: 0.66, blue: 0.18)),
        HoneyTier(id: 1, name: "Wildflower",
                  baseRate: 1.10, sellValue: 4.0, hiveCost: 120, unlockCost: 350,
                  color: Color(red: 0.96, green: 0.71, blue: 0.30),
                  accent: Color(red: 0.80, green: 0.50, blue: 0.10)),
        HoneyTier(id: 2, name: "Orange Blossom",
                  baseRate: 2.80, sellValue: 14.0, hiveCost: 850, unlockCost: 2600,
                  color: Color(red: 0.97, green: 0.58, blue: 0.22),
                  accent: Color(red: 0.82, green: 0.40, blue: 0.08)),
        HoneyTier(id: 3, name: "Lavender",
                  baseRate: 6.50, sellValue: 48.0, hiveCost: 5200, unlockCost: 16000,
                  color: Color(red: 0.66, green: 0.55, blue: 0.86),
                  accent: Color(red: 0.46, green: 0.36, blue: 0.68)),
        HoneyTier(id: 4, name: "Buckwheat",
                  baseRate: 15.0, sellValue: 165.0, hiveCost: 32000, unlockCost: 95000,
                  color: Color(red: 0.55, green: 0.38, blue: 0.24),
                  accent: Color(red: 0.38, green: 0.25, blue: 0.14)),
        HoneyTier(id: 5, name: "Manuka",
                  baseRate: 36.0, sellValue: 560.0, hiveCost: 210000, unlockCost: 620000,
                  color: Color(red: 0.30, green: 0.55, blue: 0.42),
                  accent: Color(red: 0.18, green: 0.40, blue: 0.28)),
        HoneyTier(id: 6, name: "Royal Reserve",
                  baseRate: 85.0, sellValue: 1950.0, hiveCost: 1400000, unlockCost: 4200000,
                  color: Color(red: 0.92, green: 0.78, blue: 0.30),
                  accent: Color(red: 0.74, green: 0.58, blue: 0.12))
    ]

    static func tier(_ id: Int) -> HoneyTier { tiers[max(0, min(id, tiers.count - 1))] }
}
