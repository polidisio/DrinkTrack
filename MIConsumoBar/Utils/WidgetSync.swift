import Foundation
import WidgetKit

/// Recalcula los contadores acumulados y los publica al widget y al Watch.
/// No depende de ninguna vista: también se usa cuando el Watch manda un comando con la app en segundo plano.
enum WidgetSync {
    static func refresh() {
        let coreData = CoreDataManager.shared
        let consumiciones = coreData.fetchAllConsumiciones()
        let cantidad = consumiciones.reduce(0) { $0 + Int($1.cantidad) }
        let coste = consumiciones.reduce(0.0) { $0 + Double($1.cantidad) * $1.precioUnitario }

        let defaults = UserDefaults.standard
        let budgetAmount = defaults.double(forKey: "budgetAmount")
        let budgetPeriod = defaults.string(forKey: "budgetPeriod") ?? "monthly"
        var budgetProgress: Double? = nil
        if budgetAmount > 0 {
            let spending = coreData.getTotalSpending(since: coreData.periodStart(for: budgetPeriod))
            budgetProgress = min(spending / budgetAmount, 1.5)
        }
        let currencyCode = Locale.current.currency?.identifier ?? "EUR"

        WidgetSnapshot(totalCantidad: cantidad, totalCoste: coste, currencyCode: currencyCode, budgetProgress: budgetProgress).save()
        WidgetCenter.shared.reloadAllTimelines()

        var counts: [UUID: Int] = [:]
        for consumicion in consumiciones {
            if let id = consumicion.bebidaID { counts[id, default: 0] += Int(consumicion.cantidad) }
        }
        let drinks = coreData.fetchBebidas()
            .compactMap { bebida -> WatchState.Drink? in
                guard let id = bebida.id else { return nil }
                return WatchState.Drink(id: id, emoji: bebida.emoji ?? "🥤", count: counts[id] ?? 0)
            }
            .sorted { $0.count > $1.count }
        WatchSyncService.shared.push(WatchState(
            drinks: Array(drinks.prefix(8)),
            totalCantidad: cantidad,
            totalCoste: coste,
            currencyCode: currencyCode,
            budgetProgress: budgetProgress
        ))
    }
}
