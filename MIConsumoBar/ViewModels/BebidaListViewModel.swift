import Foundation
import SwiftUI
import Combine

struct BebidaCounter: Identifiable {
    let id = UUID()
    let bebida: Bebida
    var count: Int
    var totalCost: Double
}

class BebidaListViewModel: ObservableObject {
    @Published var bebidas: [Bebida] = []
    @Published var contadores: [BebidaCounter] = []
    
    init() {
        loadBebidas()
    }
    
    func loadBebidas() {
        // This will be populated by the main ViewModel
    }
    
    func updateContadores(from consumiciones: [Consumicion]) {
        contadores = []
        
        for bebida in bebidas {
            let consumicionesBebida = consumiciones.filter { $0.bebidaID == bebida.id }
            let cantidad = consumicionesBebida.reduce(0) { $0 + Int($1.cantidad) }
            let coste = consumicionesBebida.reduce(0.0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
            
            if cantidad > 0 {
                contadores.append(BebidaCounter(bebida: bebida, count: cantidad, totalCost: coste))
            }
        }
    }
}