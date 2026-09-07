import Foundation
import CoreData
import Combine
import SwiftUI
import WidgetKit

class ConsumicionViewModel: ObservableObject {
    private let coreDataManager = CoreDataManager.shared
    
    @Published var bebidas: [Bebida] = []
    @Published var consumicionesHoy: [Consumicion] = []
    @Published var totalHoy: (cantidad: Int, coste: Double) = (0, 0.0)
    @Published var isLoading = false
    
    init() {
        loadData()
    }
    
    func loadData() {
        Task { @MainActor in
            isLoading = true
            
            bebidas = coreDataManager.fetchBebidas()
            
            if bebidas.isEmpty {
                coreDataManager.createDefaultBebidas()
                bebidas = coreDataManager.fetchBebidas()
            }
            
            refreshTodayData()
            
            isLoading = false
        }
    }
    
    func refreshTodayData() {
        consumicionesHoy = coreDataManager.fetchAllConsumiciones()

        let cantidad = consumicionesHoy.reduce(0) { $0 + Int($1.cantidad) }
        let coste = consumicionesHoy.reduce(0.0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
        totalHoy = (cantidad, coste)

        updateWidgetSnapshot()
    }

    /// Pushes the current (cumulative, manual-reset-only) totals to the widget's
    /// shared App Group storage and asks WidgetKit to refresh. Does not filter by
    /// date — mirrors `totalHoy` exactly, same as the in-app counters.
    private func updateWidgetSnapshot() {
        let defaults = UserDefaults.standard
        let budgetAmount = defaults.double(forKey: "budgetAmount")
        let budgetPeriod = defaults.string(forKey: "budgetPeriod") ?? "monthly"

        var budgetProgress: Double? = nil
        if budgetAmount > 0 {
            let periodStart = coreDataManager.periodStart(for: budgetPeriod)
            let periodSpending = coreDataManager.getTotalSpending(since: periodStart)
            budgetProgress = min(periodSpending / budgetAmount, 1.5)
        }

        WidgetSnapshot(
            totalCantidad: totalHoy.cantidad,
            totalCoste: totalHoy.coste,
            currencyCode: Locale.current.currency?.identifier ?? "EUR",
            budgetProgress: budgetProgress
        ).save()
        WidgetCenter.shared.reloadAllTimelines()
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
        let consumicionesBebida = consumicionesHoy
            .filter { $0.bebidaID == bebida.id }
            .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
        if let ultima = consumicionesBebida.first {
            if ultima.cantidad > 1 {
                ultima.cantidad -= 1
                coreDataManager.save()
            } else {
                coreDataManager.deleteConsumicion(ultima)
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