import Foundation

/// iPhone → Watch: estado a mostrar. Refleja los contadores acumulados de la app
/// (los mismos que `WidgetSnapshot`), más las bebidas ordenadas por uso.
struct WatchState: Codable, Equatable {
    struct Drink: Codable, Identifiable, Equatable {
        let id: UUID
        let emoji: String
        var count: Int
    }

    var drinks: [Drink]
    var totalCantidad: Int
    var totalCoste: Double
    var currencyCode: String
    var budgetProgress: Double?
}

/// Watch → iPhone: acción idempotente (el iPhone descarta ids ya procesados).
struct WatchCommand: Codable, Equatable {
    enum Kind: String, Codable { case add, undo }

    let id: UUID
    let kind: Kind
    let bebidaID: UUID

    init(kind: Kind, bebidaID: UUID) {
        self.id = UUID()
        self.kind = kind
        self.bebidaID = bebidaID
    }
}
