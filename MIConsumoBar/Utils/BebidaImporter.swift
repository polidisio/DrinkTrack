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
        
        // Try with iso8601 first
        decoder.dateDecodingStrategy = .iso8601
        if let exportData = try? decoder.decode(BebidaExportData.self, from: data) {
            return exportData
        }
        
        // Try with deferredDateDecoder if iso8601 fails
        decoder.dateDecodingStrategy = .deferredToDate
        if let exportData = try? decoder.decode(BebidaExportData.self, from: data) {
            return exportData
        }
        
        // Try without date decoding strategy (for files without dates or with custom format)
        let decoderNoDate = JSONDecoder()
        if let exportData = try? decoderNoDate.decode(BebidaExportData.self, from: data) {
            return exportData
        }
        
        print("Error decoding JSON data")
        return nil
    }
    
    // MARK: - Synchronous methods for import
    
    func mergeBebidasSync(_ items: [BebidaExportItem], context: NSManagedObjectContext) {
        // Fetch existing drinks and consumiciones
        let bebidaRequest: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        let existingBebidas = (try? context.fetch(bebidaRequest)) ?? []
        let existingIDs = Set(existingBebidas.compactMap { $0.id })
        
        for item in items {
            let drinkID = item.id ?? UUID()
            
            if existingIDs.contains(drinkID) {
                // Update existing drink info
                if let existing = existingBebidas.first(where: { $0.id == drinkID }) {
                    existing.nombre = item.nombre
                    existing.emoji = item.emoji
                    existing.precioBase = item.precioBase
                    existing.categoria = item.categoria
                    existing.orden = item.orden
                }
                
                // Add consumicion with the imported quantity
                let qty = item.cantidad ?? 0
                if qty > 0 {
                    let consumicion = Consumicion(context: context)
                    consumicion.id = UUID()
                    consumicion.bebidaID = drinkID
                    consumicion.cantidad = Int32(qty)
                    consumicion.precioUnitario = item.precioBase
                    consumicion.timestamp = Date()
                    print("DEBUG: Added \(qty) consumiciones to existing drink: \(item.nombre)")
                }
            } else {
                // Create new drink
                let newBebida = Bebida(context: context)
                newBebida.id = drinkID
                newBebida.nombre = item.nombre
                newBebida.emoji = item.emoji
                newBebida.precioBase = item.precioBase
                newBebida.categoria = item.categoria
                newBebida.orden = item.orden
                
                // Create consumicion with the imported quantity
                let qty = item.cantidad ?? 0
                if qty > 0 {
                    let consumicion = Consumicion(context: context)
                    consumicion.id = UUID()
                    consumicion.bebidaID = drinkID
                    consumicion.cantidad = Int32(qty)
                    consumicion.precioUnitario = item.precioBase
                    consumicion.timestamp = Date()
                    print("DEBUG: Added new drink: \(item.nombre) with \(qty) consumiciones")
                } else {
                    print("DEBUG: Added new drink: \(item.nombre) with ID: \(drinkID)")
                }
            }
        }
        
        do {
            try context.save()
            context.refreshAllObjects()
            print("DEBUG: Merge save successful!")
        } catch {
            print("Error saving merged bebidas: \(error)")
        }
    }
    
    func overwriteBebidasSync(_ items: [BebidaExportItem], context: NSManagedObjectContext) {
        // Delete ALL consumiciones first
        let consumicionRequest: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        if let allConsumiciones = try? context.fetch(consumicionRequest) {
            for consumicion in allConsumiciones {
                context.delete(consumicion)
            }
            print("DEBUG: Deleted \(allConsumiciones.count) consumiciones")
        }
        
        // Delete ALL bebidas
        let bebidaRequest: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        let existingBebidas = (try? context.fetch(bebidaRequest)) ?? []
        
        for existing in existingBebidas {
            context.delete(existing)
        }
        print("DEBUG: Deleted \(existingBebidas.count) bebidas")
        
        // Create new bebidas from import + their consumiciones
        for item in items {
            let drinkID = item.id ?? UUID()
            let newBebida = Bebida(context: context)
            newBebida.id = drinkID
            newBebida.nombre = item.nombre
            newBebida.emoji = item.emoji
            newBebida.precioBase = item.precioBase
            newBebida.categoria = item.categoria
            newBebida.orden = item.orden
            
            // Create consumicion with the imported quantity
            let qty = item.cantidad ?? 0
            if qty > 0 {
                let consumicion = Consumicion(context: context)
                consumicion.id = UUID()
                consumicion.bebidaID = drinkID
                consumicion.cantidad = Int32(qty)
                consumicion.precioUnitario = item.precioBase
                consumicion.timestamp = Date()
                print("DEBUG: Imported drink: \(item.nombre) with \(qty) consumiciones")
            } else {
                print("DEBUG: Imported drink: \(item.nombre) with ID: \(drinkID)")
            }
        }
        
        do {
            try context.save()
            context.refreshAllObjects()
            print("DEBUG: Overwrite save successful!")
        } catch {
            print("DEBUG: Error saving overwritten bebidas: \(error)")
        }
    }
}
