import SwiftUI
import Combine

// One hive placed on a plot. tierId references HoneyCatalog.
struct HivePlacement: Codable {
    var tierId: Int
}

final class HiveGameState: ObservableObject {
    // MARK: - Grid
    // The apiary grid. nil means an unlocked-but-empty plot. Index = row*cols+col.
    @Published var grid: [HivePlacement?] = []
    @Published var unlockedPlots: Int = 9   // how many plots are buyable/usable

    let cols = 4
    let rows = 6   // 24 plots max

    // MARK: - Resources
    @Published var coins: Double = 30
    @Published var honey: Double = 0          // unsold honey waiting in the warehouse
    @Published var beePopulation: Double = 12 // total bees across the apiary

    // MARK: - Upgrades (levels)
    @Published var beeBoostLevel: Int = 0     // each level multiplies production
    @Published var capacityLevel: Int = 0     // each level grows max bee population
    @Published var pollinationLevel: Int = 0  // each level strengthens adjacency bonus
    @Published var unlockedTier: Int = 0      // highest unlocked honey tier id

    // MARK: - Selection (for placement)
    @Published var selectedTier: Int = 0

    @Published var lastFloatingMessage: String = ""

    private var timer: AnyCancellable?
    private let saveKey = "honeyHiveKeeperSaveV1"

    // Bee growth & economy tuning constants
    private let beeGrowthPerSec = 0.18        // bees born per second (scaled by hives)
    let baseBeeCapacity: Double = 40

    init() {
        if !load() {
            grid = Array(repeating: nil, count: rows * cols)
        }
        if grid.count != rows * cols {
            // migrate / repair
            var fixed = Array<HivePlacement?>(repeating: nil, count: rows * cols)
            for i in 0..<min(grid.count, fixed.count) { fixed[i] = grid[i] }
            grid = fixed
        }
    }

    // MARK: - Derived values

    var maxBeeCapacity: Double {
        baseBeeCapacity * pow(1.55, Double(capacityLevel)) * Double(max(1, hiveCount))
    }

    var hiveCount: Int {
        grid.compactMap { $0 }.count
    }

    var beeProductionMultiplier: Double {
        // More bees = more honey, with diminishing emphasis. Bee boost upgrade stacks.
        let popFactor = 1.0 + (beePopulation / 60.0)
        let boost = pow(1.35, Double(beeBoostLevel))
        return popFactor * boost
    }

    var pollinationStrength: Double {
        // Each adjacent hive of the SAME OR HIGHER tier adds this fraction.
        0.25 + 0.08 * Double(pollinationLevel)
    }

    // Pollination multiplier for a single plot given its neighbors.
    func pollinationMultiplier(at index: Int) -> Double {
        guard let me = grid[index] else { return 1.0 }
        let r = index / cols
        let c = index % cols
        var neighborBonus = 0.0
        let deltas = [(-1,0),(1,0),(0,-1),(0,1)]
        for (dr, dc) in deltas {
            let nr = r + dr, nc = c + dc
            if nr < 0 || nr >= rows || nc < 0 || nc >= cols { continue }
            let nIndex = nr * cols + nc
            if let neighbor = grid[nIndex] {
                // Adjacent hives cross-pollinate; matching/higher tiers help more.
                let tierFactor = neighbor.tierId >= me.tierId ? 1.0 : 0.6
                neighborBonus += pollinationStrength * tierFactor
            }
        }
        return 1.0 + neighborBonus
    }

    // Honey-per-second for a single plot, including pollination & global multipliers.
    func plotRate(at index: Int) -> Double {
        guard let placement = grid[index] else { return 0 }
        let tier = HoneyCatalog.tier(placement.tierId)
        return tier.baseRate * pollinationMultiplier(at: index) * beeProductionMultiplier
    }

    // Total honey per second across the apiary (in jars/sec, weighted by sell value
    // is handled at sale time; here it's raw jars).
    var totalHoneyPerSecond: Double {
        var sum = 0.0
        for i in grid.indices { sum += plotRate(at: i) }
        return sum
    }

    // Coins per second if everything currently auto-sells.
    var coinsPerSecond: Double {
        var sum = 0.0
        for i in grid.indices {
            if let placement = grid[i] {
                let tier = HoneyCatalog.tier(placement.tierId)
                sum += plotRate(at: i) * tier.sellValue
            }
        }
        return sum
    }

    // MARK: - Costs

    func plotUnlockCost() -> Double {
        // Steep growth so expansion stays meaningful.
        25.0 * pow(1.9, Double(unlockedPlots - 9))
    }

    func beeBoostCost() -> Double { 60.0 * pow(2.15, Double(beeBoostLevel)) }
    func capacityCost() -> Double { 90.0 * pow(2.05, Double(capacityLevel)) }
    func pollinationCost() -> Double { 140.0 * pow(2.35, Double(pollinationLevel)) }

    func tierUnlockCost(_ tierId: Int) -> Double {
        HoneyCatalog.tier(tierId).unlockCost
    }

    // MARK: - Actions

    func canPlaceHive(at index: Int) -> Bool {
        guard index < unlockedPlots else { return false }
        guard grid[index] == nil else { return false }
        return coins >= HoneyCatalog.tier(selectedTier).hiveCost
    }

    func placeHive(at index: Int) {
        guard index < unlockedPlots, grid[index] == nil else { return }
        let tier = HoneyCatalog.tier(selectedTier)
        guard coins >= tier.hiveCost else {
            lastFloatingMessage = "Not enough coins"
            return
        }
        coins -= tier.hiveCost
        grid[index] = HivePlacement(tierId: selectedTier)
        // Placing a hive recruits a few starter bees.
        beePopulation = min(maxBeeCapacity, beePopulation + 4)
        save()
    }

    func removeHive(at index: Int) {
        guard index < grid.count, grid[index] != nil else { return }
        // Refund a portion of the hive cost.
        if let placement = grid[index] {
            let tier = HoneyCatalog.tier(placement.tierId)
            coins += tier.hiveCost * 0.4
        }
        grid[index] = nil
        save()
    }

    func unlockNextPlot() {
        guard unlockedPlots < rows * cols else { return }
        let cost = plotUnlockCost()
        guard coins >= cost else { lastFloatingMessage = "Not enough coins"; return }
        coins -= cost
        unlockedPlots += 1
        save()
    }

    func buyBeeBoost() {
        let cost = beeBoostCost()
        guard coins >= cost else { lastFloatingMessage = "Not enough coins"; return }
        coins -= cost
        beeBoostLevel += 1
        save()
    }

    func buyCapacity() {
        let cost = capacityCost()
        guard coins >= cost else { lastFloatingMessage = "Not enough coins"; return }
        coins -= cost
        capacityLevel += 1
        save()
    }

    func buyPollination() {
        let cost = pollinationCost()
        guard coins >= cost else { lastFloatingMessage = "Not enough coins"; return }
        coins -= cost
        pollinationLevel += 1
        save()
    }

    func unlockTier(_ tierId: Int) {
        guard tierId == unlockedTier + 1 else { return }
        let cost = tierUnlockCost(tierId)
        guard coins >= cost else { lastFloatingMessage = "Not enough coins"; return }
        coins -= cost
        unlockedTier = tierId
        save()
    }

    // Manually sell stored honey for coins, weighted by the value of stored jars.
    // (Honey is stored as raw jars from mixed tiers; we approximate sale value with
    // a running average value-per-jar to keep it simple and deterministic.)
    func sellAllHoney() {
        guard honey > 0 else { return }
        coins += honey * currentAverageJarValue
        honey = 0
        save()
    }

    var currentAverageJarValue: Double {
        var totalRate = 0.0
        var weightedValue = 0.0
        for i in grid.indices {
            if let placement = grid[i] {
                let tier = HoneyCatalog.tier(placement.tierId)
                let rate = plotRate(at: i)
                totalRate += rate
                weightedValue += rate * tier.sellValue
            }
        }
        if totalRate <= 0 { return 1.0 }
        return weightedValue / totalRate
    }

    // MARK: - Tick

    func startLoop() {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick(delta: 0.5) }
    }

    func stopLoop() {
        timer?.cancel()
        timer = nil
        save()
    }

    private func tick(delta: Double) {
        // Bees grow toward capacity, faster with more hives.
        if hiveCount > 0 {
            let growth = beeGrowthPerSec * Double(hiveCount) * delta
            beePopulation = min(maxBeeCapacity, beePopulation + growth)
        }
        // Honey auto-collects into the warehouse...
        let producedJars = totalHoneyPerSecond * delta
        honey += producedJars
        // ...and auto-sells immediately (idle income). Warehouse acts as a buffer
        // so the sell button is for a satisfying manual burst, but income is passive.
        if honey > 0 {
            let value = honey * currentAverageJarValue
            coins += value
            honey = 0
        }
    }

    // MARK: - Offline earnings

    func applyOfflineEarnings(seconds: Double) -> Double {
        guard seconds > 1 else { return 0 }
        // Cap offline credit to 8 hours so it can't snowball absurdly.
        let capped = min(seconds, 8 * 3600)
        // Bees would have grown during offline time; approximate with half growth.
        if hiveCount > 0 {
            let growth = beeGrowthPerSec * Double(hiveCount) * capped * 0.5
            beePopulation = min(maxBeeCapacity, beePopulation + growth)
        }
        let earned = coinsPerSecond * capped
        if earned > 0 {
            coins += earned
            save()
        }
        return earned
    }

    // MARK: - Persistence

    struct SaveBlob: Codable {
        var grid: [HivePlacement?]
        var unlockedPlots: Int
        var coins: Double
        var honey: Double
        var beePopulation: Double
        var beeBoostLevel: Int
        var capacityLevel: Int
        var pollinationLevel: Int
        var unlockedTier: Int
        var selectedTier: Int
        var lastActive: Double
    }

    func save() {
        let blob = SaveBlob(
            grid: grid,
            unlockedPlots: unlockedPlots,
            coins: coins,
            honey: honey,
            beePopulation: beePopulation,
            beeBoostLevel: beeBoostLevel,
            capacityLevel: capacityLevel,
            pollinationLevel: pollinationLevel,
            unlockedTier: unlockedTier,
            selectedTier: selectedTier,
            lastActive: Date().timeIntervalSince1970
        )
        if let data = try? JSONEncoder().encode(blob) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    // Stamp the time the app went to background. Called ONLY from .background.
    func stampLastActive() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "honeyHiveLastActiveV1")
        save()
    }

    @discardableResult
    func load() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let blob = try? JSONDecoder().decode(SaveBlob.self, from: data) else {
            return false
        }
        grid = blob.grid
        unlockedPlots = blob.unlockedPlots
        coins = blob.coins
        honey = blob.honey
        beePopulation = blob.beePopulation
        beeBoostLevel = blob.beeBoostLevel
        capacityLevel = blob.capacityLevel
        pollinationLevel = blob.pollinationLevel
        unlockedTier = blob.unlockedTier
        selectedTier = min(blob.selectedTier, blob.unlockedTier)
        return true
    }

    // Returns elapsed offline seconds based on the dedicated lastActive stamp.
    func offlineSeconds() -> Double {
        let last = UserDefaults.standard.double(forKey: "honeyHiveLastActiveV1")
        if last <= 0 { return 0 }
        return Date().timeIntervalSince1970 - last
    }

    func resetProgress() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        UserDefaults.standard.removeObject(forKey: "honeyHiveLastActiveV1")
        grid = Array(repeating: nil, count: rows * cols)
        unlockedPlots = 9
        coins = 30
        honey = 0
        beePopulation = 12
        beeBoostLevel = 0
        capacityLevel = 0
        pollinationLevel = 0
        unlockedTier = 0
        selectedTier = 0
        save()
    }
}
