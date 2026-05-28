import Foundation
import CoreData

class BebidaExporter {
    static let shared = BebidaExporter()

    private let exportVersion = "1.0"

    func exportToCSV(consumiciones: [Consumicion], bebidasLookup: [UUID: Bebida]) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        var csv = "Date,Drink,Emoji,Quantity,Unit Price,Total,Notes\n"

        for consumicion in consumiciones {
            let date = consumicion.timestamp.map { dateFormatter.string(from: $0) } ?? ""
            let bebida = consumicion.bebidaID.flatMap { bebidasLookup[$0] }
            let drink = bebida?.nombre ?? ""
            let emoji = bebida?.emoji ?? ""
            let quantity = consumicion.cantidad
            let unitPrice = consumicion.precioUnitario
            let total = Double(quantity) * unitPrice
            let notas = (consumicion.notas ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            let notasField = notas.contains(",") ? "\"\(notas)\"" : notas

            csv += "\(date),\(drink),\(emoji),\(quantity),\(String(format: "%.2f", unitPrice)),\(String(format: "%.2f", total)),\(notasField)\n"
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("export_\(UUID().uuidString).csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
    
    func exportBebidas(_ bebidas: [BebidaExportItem]) -> URL? {
        let data = BebidaExportData(version: exportVersion, exportDate: Date(), bebidas: bebidas)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(data) else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("bebidas_\(UUID().uuidString).json")
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing export file: \(error)")
            return nil
        }
    }
    
    func createExportItem(from bebida: Bebida, cantidad: Int) -> BebidaExportItem {
        BebidaExportItem(
            id: bebida.id ?? UUID(),
            nombre: bebida.nombre ?? "",
            emoji: bebida.emoji ?? "",
            precioBase: bebida.precioBase,
            categoria: bebida.categoria ?? "",
            orden: bebida.orden,
            cantidad: cantidad
        )
    }
}
