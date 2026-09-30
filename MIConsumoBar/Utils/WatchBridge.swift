import Foundation

extension Notification.Name {
    static let watchDidChangeData = Notification.Name("watchDidChangeData")
}

/// Aplica en el iPhone los comandos que llegan del Watch (mismo camino que la UI: `CoreDataManager`).
enum WatchBridge {
    private static let processedKey = "watchProcessedCommands"
    private static let maxRemembered = 500

    static func start() {
        WatchSyncService.shared.onCommand = handle
        WatchSyncService.shared.onNeedsState = { DispatchQueue.main.async { WidgetSync.refresh() } }
        WatchSyncService.shared.activate()
    }

    static func handle(_ command: WatchCommand) {
        DispatchQueue.main.async {
            guard markProcessed(command.id) else { return } // transferUserInfo puede reentregar
            let coreData = CoreDataManager.shared
            guard let bebida = coreData.fetchBebidaByID(command.bebidaID) else { return }
            switch command.kind {
            case .add:
                coreData.addConsumicion(bebidaID: command.bebidaID, cantidad: 1, precioUnitario: bebida.precioBase, source: "watch")
            case .undo:
                if let last = coreData.fetchAllConsumiciones().first(where: { $0.bebidaID == command.bebidaID }) {
                    coreData.decrementConsumicionQuantity(last)
                }
            }
            WidgetSync.refresh()
            NotificationCenter.default.post(name: .watchDidChangeData, object: nil)
        }
    }

    /// true si el id es nuevo (y lo recuerda).
    static func markProcessed(_ id: UUID, defaults: UserDefaults = .standard) -> Bool {
        var seen = defaults.stringArray(forKey: processedKey) ?? []
        guard !seen.contains(id.uuidString) else { return false }
        seen.append(id.uuidString)
        if seen.count > maxRemembered { seen.removeFirst(seen.count - maxRemembered) }
        defaults.set(seen, forKey: processedKey)
        return true
    }
}
