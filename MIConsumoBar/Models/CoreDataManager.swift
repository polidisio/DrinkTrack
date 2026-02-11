import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MiConsumoBar")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Bebida Operations
    
    func createDefaultBebidas() {
        let bebidasPredeterminadas: [(nombre: String, emoji: String, precio: Double, categoria: String)] = [
            ("Cerveza", "🍺", 3.5, "Alcohol"),
            ("Refresco", "🥤", 2.0, "Sin Alcohol"),
            ("Agua", "💧", 1.5, "Sin Alcohol"),
            ("Vino", "🍷", 4.0, "Alcohol"),
            ("Copa", "🍸", 6.0, "Alcohol"),
            ("Café", "☕", 1.8, "Sin Alcohol")
        ]
        
        for (index, bebidaData) in bebidasPredeterminadas.enumerated() {
            let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
            request.predicate = NSPredicate(format: "nombre == %@", bebidaData.nombre)
            
            let existing = try? context.fetch(request)
            if existing?.isEmpty == true {
                let bebida = Bebida(context: context)
                bebida.id = UUID()
                bebida.nombre = bebidaData.nombre
                bebida.emoji = bebidaData.emoji
                bebida.precioBase = bebidaData.precio
                bebida.categoria = bebidaData.categoria
                bebida.orden = Int32(index + 1)
            }
        }
        
        save()
    }
    
    func fetchBebidas() -> [Bebida] {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orden", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching bebidas: \(error)")
            return []
        }
    }
    
    func createBebida(nombre: String, emoji: String, precio: Double, categoria: String) -> Bebida {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orden", ascending: false)]
        request.fetchLimit = 1
        
        let maxOrden = (try? context.fetch(request).first?.orden) ?? 0
        
        let bebida = Bebida(context: context)
        bebida.id = UUID()
        bebida.nombre = nombre
        bebida.emoji = emoji
        bebida.precioBase = precio
        bebida.categoria = categoria
        bebida.orden = maxOrden + 1
        
        save()
        return bebida
    }
    
    func updateBebida(_ bebida: Bebida, nombre: String, emoji: String, precio: Double, categoria: String) {
        bebida.nombre = nombre
        bebida.emoji = emoji
        bebida.precioBase = precio
        bebida.categoria = categoria
        save()
    }
    
    func deleteBebida(_ bebida: Bebida) {
        context.delete(bebida)
        save()
    }
    
    func isBebidaDefault(_ bebida: Bebida) -> Bool {
        let defaultNombres = ["Cerveza", "Refresco", "Agua", "Vino", "Copa", "Café"]
        return defaultNombres.contains(bebida.nombre ?? "")
    }
    
    // MARK: - Consumicion Operations
    
    func addConsumicion(bebidaID: UUID, cantidad: Int, precioUnitario: Double, notas: String? = nil) {
        let consumicion = Consumicion(context: context)
        consumicion.id = UUID()
        consumicion.bebidaID = bebidaID
        consumicion.cantidad = Int32(cantidad)
        consumicion.precioUnitario = precioUnitario
        consumicion.timestamp = Date()
        consumicion.notas = notas
        
        save()
    }
    
    func fetchConsumiciones(for date: Date? = nil) -> [Consumicion] {
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        
        if let date = date {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching consumiciones: \(error)")
            return []
        }
    }
    
    func deleteConsumicion(_ consumicion: Consumicion) {
        context.delete(consumicion)
        save()
    }
    
    func cleanupOldConsumiciones() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@", startOfToday as NSDate)
        
        do {
            let oldConsumiciones = try context.fetch(request)
            for consumicion in oldConsumiciones {
                context.delete(consumicion)
            }
            save()
        } catch {
            print("Error cleaning up old consumiciones: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    func getTotalToday() -> (cantidad: Int, coste: Double) {
        let today = Date()
        let consumiciones = fetchConsumiciones(for: today)
        
        let totalCantidad = consumiciones.reduce(0) { $0 + Int($1.cantidad) }
        let totalCoste = consumiciones.reduce(0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
        
        return (totalCantidad, totalCoste)
    }
}