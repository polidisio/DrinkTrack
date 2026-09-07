import Foundation

/// Small snapshot written by the app and read by the widget extension, shared
/// via an App Group `UserDefaults` suite. Avoids sharing the CoreData store
/// (and the store-migration risk that would bring for existing installs).
struct WidgetSnapshot: Codable {
    static let appGroupID = "group.com.polidisio.MyBarTrack"
    private static let storageKey = "widgetSnapshot"

    /// Cumulative count/cost as tracked by `ConsumicionViewModel.totalHoy` —
    /// these reset only when the user manually resets counters, never automatically.
    let totalCantidad: Int
    let totalCoste: Double
    let currencyCode: String
    /// Budget progress (0...1.5) for the current period, nil if no budget is set.
    let budgetProgress: Double?

    func save() {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID),
              let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
