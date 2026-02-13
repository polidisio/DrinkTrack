import Foundation
import CoreData

class BebidaImporter {
    static let shared = BebidaImporter()
    
    enum ImportMode {
        case merge
        case overwrite
        case cancel
    }
    
    func parseExportData(from url: URL) -> BebidaExportData? {
        guard let data = try? Data(contentsOf: url) else {
            print("Error reading file at URL: \(url)")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let exportData = try? decoder.decode(BebidaExportData.self, from: data) else {
            print("Error decoding JSON data")
            return nil
        }
        
        return exportData
    }
    
    func importBebidas(from exportData: BebidaExportData, mode: ImportMode, context: NSManagedObjectContext) async throws {
        switch mode {
        case .merge:
            try await mergeBebidas(exportData.bebidas, context: context)
        case .overwrite:
            try await overwriteBebidas(exportData.bebidas, context: context)
        case .cancel:
            return
        }
    }
    
    private func mergeBebidas(_ items: [BebidaExportItem], context: NSManagedObjectContext) async throws {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        let existingBebidas = (try? context.fetch(request)) ?? []
        let existingIDs = Set(existingBebidas.compactMap { $0.id })
        
        for item in items {
            if existingIDs.contains(item.id) {
                if let existing = existingBebidas.first(where: { $0.id == item.id }) {
                    existing.nombre = item.nombre
                    existing.emoji = item.emoji
                    existing.precioBase = item.precioBase
                    existing.categoria = item.categoria
                    existing.orden = item.orden
                }
            } else {
                let newBebida = Bebida(context: context)
                newBebida.id = item.id
                newBebida.nombre = item.nombre
                newBebida.emoji = item.emoji
                newBebida.precioBase = item.precioBase
                newBebida.categoria = item.categoria
                newBebida.orden = item.orden
            }
        }
        
        try context.save()
    }
    
    private func overwriteBebidas(_ items: [BebidaExportItem], context: NSManagedObjectContext) async throws {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        let existingBebidas = (try? context.fetch(request)) ?? []
        
        for existing in existingBebidas {
            context.delete(existing)
        }
        
        for item in items {
            let newBebida = Bebida(context: context)
            newBebida.id = item.id
            newBebida.nombre = item.nombre
            newBebida.emoji = item.emoji
            newBebida.precioBase = item.precioBase
            newBebida.categoria = item.categoria
            newBebida.orden = item.orden
        }
        
        try context.save()
    }
}
