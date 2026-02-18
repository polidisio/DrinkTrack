import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MiConsumoBar")
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
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
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Bebida Operations
    
    func createDefaultBebidas() {
        let existingBebidas = fetchBebidas()
        guard existingBebidas.isEmpty else { return }
        
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
    
    func localizedNombre(for nombre: String) -> String {
        let nameMap: [String: String] = [
            "Cerveza": "bebida_cerveza",
            "Refresco": "bebida_refresco",
            "Agua": "bebida_agua",
            "Vino": "bebida_vino",
            "Copa": "bebida_copa",
            "Café": "bebida_cafe"
        ]
        guard let key = nameMap[nombre] else { return nombre }
        return NSLocalizedString(key, comment: "Drink name")
    }
    
    func localizedCategoria(for categoria: String) -> String {
        let catMap: [String: String] = [
            "Alcohol": "categoria_alcohol",
            "Sin Alcohol": "categoria_sin_alcohol"
        ]
        guard let key = catMap[categoria] else { return categoria }
        return NSLocalizedString(key, comment: "Category")
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
    
    func fetchBebidaByID(_ id: UUID) -> Bebida? {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching bebida by ID: \(error)")
            return nil
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
        guard let bebidaID = bebida.id else { return }
        updateBebidaByID(bebidaID, nombre: nombre, emoji: emoji, precio: precio, categoria: categoria)
    }
    
    func updateBebidaByID(_ id: UUID, nombre: String, emoji: String, precio: Double, categoria: String) {
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let bebida = try context.fetch(request).first {
                bebida.nombre = nombre
                bebida.emoji = emoji
                bebida.precioBase = precio
                bebida.categoria = categoria
                save()
            }
        } catch {
            print("Error updating bebida: \(error)")
        }
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
    
    func fetchConsumiciones(for date: Date? = nil, last7Days: Bool = false) -> [Consumicion] {
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        
        if last7Days {
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            request.predicate = NSPredicate(format: "timestamp >= %@", startDate as NSDate)
        } else if let date = date {
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
    
    func fetchAllConsumiciones() -> [Consumicion] {
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching all consumiciones: \(error)")
            return []
        }
    }
    
    func deleteConsumicion(_ consumicion: Consumicion) {
        context.delete(consumicion)
        save()
    }
    
    func cleanupOldConsumiciones() {
        let retentionDays = UserDefaults.standard.integer(forKey: "retentionDays")
        
        guard retentionDays > 0 else { return }
        
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -retentionDays, to: Date())!
        
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        
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