import Foundation
import CoreData

class BebidaExporter {
    static let shared = BebidaExporter()
    
    private let exportVersion = "1.0"
    
    func exportBebidas(_ bebidas: [BebidaExportItem]) -> URL? {
        let data = BebidaExportData(version: exportVersion, exportDate: Date(), bebidas: bebidas)
        
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("bebidas.drinktrack")
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing export file: \(error)")
            return nil
        }
    }
    
    func createExportItem(from bebida: Bebida) -> BebidaExportItem {
        BebidaExportItem(
            id: bebida.id ?? UUID(),
            nombre: bebida.nombre ?? "",
            emoji: bebida.emoji ?? "",
            precioBase: bebida.precioBase,
            categoria: bebida.categoria ?? "",
            orden: bebida.orden
        )
    }
}
