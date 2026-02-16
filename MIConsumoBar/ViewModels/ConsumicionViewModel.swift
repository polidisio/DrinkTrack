import Foundation
import CoreData
import Combine
import SwiftUI

class ConsumicionViewModel: ObservableObject {
    private let coreDataManager = CoreDataManager.shared
    
    @Published var bebidas: [Bebida] = []
    @Published var consumicionesHoy: [Consumicion] = []
    @Published var totalHoy: (cantidad: Int, coste: Double) = (0, 0.0)
    
    init() {
        loadData()
    }
    
    func loadData() {
        Task { @MainActor in
            // TEMPORARILY DISABLED: cleanupOldConsumiciones()
            // coreDataManager.cleanupOldConsumiciones()
            bebidas = coreDataManager.fetchBebidas()
            
            if bebidas.isEmpty {
                coreDataManager.createDefaultBebidas()
                bebidas = coreDataManager.fetchBebidas()
            }
            
            refreshTodayData()
        }
    }
    
    func refreshTodayData() {
        consumicionesHoy = coreDataManager.fetchAllConsumiciones()
        totalHoy = coreDataManager.getTotalToday()
    }
    
    func addConsumicion(bebida: Bebida, cantidad: Int = 1, precioUnitario: Double? = nil) {
        guard let bebidaID = bebida.id else { return }
        let precio = precioUnitario ?? bebida.precioBase
        coreDataManager.addConsumicion(
            bebidaID: bebidaID,
            cantidad: cantidad,
            precioUnitario: precio
        )
        refreshTodayData()
    }
    
    func deleteConsumicion(_ consumicion: Consumicion) {
        coreDataManager.deleteConsumicion(consumicion)
        refreshTodayData()
    }
    
    func decrementConsumicion(bebida: Bebida) {
        let consumicionesBebida = consumicionesHoy.filter { $0.bebidaID == bebida.id }
        if let primera = consumicionesBebida.first {
            if primera.cantidad > 1 {
                primera.cantidad -= 1
                coreDataManager.save()
            } else {
                coreDataManager.deleteConsumicion(primera)
            }
            refreshTodayData()
        }
    }
    
    func getBebida(by id: UUID) -> Bebida? {
        return bebidas.first { $0.id == id }
    }
    
    func getConsumicionCount(for bebida: Bebida) -> Int {
        return consumicionesHoy
            .filter { $0.bebidaID == bebida.id }
            .reduce(0) { $0 + Int($1.cantidad) }
    }
    
    func getConsumicionCost(for bebida: Bebida) -> Double {
        return consumicionesHoy
            .filter { $0.bebidaID == bebida.id }
            .reduce(0.0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
    }
    
    func resetCounters(for bebida: Bebida) {
        let consumicionesBebida = consumicionesHoy.filter { $0.bebidaID == bebida.id }
        for consumicion in consumicionesBebida {
            coreDataManager.deleteConsumicion(consumicion)
        }
        refreshTodayData()
    }
    
    func createBebidaPersonalizada(nombre: String, emoji: String, precio: Double, categoria: String) -> Bebida {
        let bebida = coreDataManager.createBebida(nombre: nombre, emoji: emoji, precio: precio, categoria: categoria)
        loadData()
        return bebida
    }
    
    func updateBebida(_ bebida: Bebida, nombre: String, emoji: String, precio: Double, categoria: String) {
        coreDataManager.updateBebida(bebida, nombre: nombre, emoji: emoji, precio: precio, categoria: categoria)
        loadData()
    }
    
    func deleteBebidaPersonalizada(_ bebida: Bebida) {
        coreDataManager.deleteBebida(bebida)
        loadData()
    }
    
    func isBebidaDefault(_ bebida: Bebida) -> Bool {
        return coreDataManager.isBebidaDefault(bebida)
    }
}