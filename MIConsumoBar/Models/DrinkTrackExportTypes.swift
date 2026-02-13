import Foundation

struct BebidaExportData: Codable {
    let version: String
    let exportDate: Date
    let bebidas: [BebidaExportItem]
}

struct BebidaExportItem: Codable, Identifiable {
    let id: UUID
    let nombre: String
    let emoji: String
    let precioBase: Double
    let categoria: String
    let orden: Int32
}
