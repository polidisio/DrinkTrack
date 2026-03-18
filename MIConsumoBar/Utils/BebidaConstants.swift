import Foundation

enum BebidaCategoria: String, CaseIterable {
    case alcohol = "Alcohol"
    case sinAlcohol = "Sin Alcohol"
    
    var localizedKey: String {
        switch self {
        case .alcohol:
            return "categoria_alcohol"
        case .sinAlcohol:
            return "categoria_sin_alcohol"
        }
    }
}

enum BebidaConstants {
    static let defaultBebidas: [(nombre: String, emoji: String, precio: Double, categoria: BebidaCategoria)] = [
        ("Cerveza", "🍺", 3.5, .alcohol),
        ("Refresco", "🥤", 2.0, .sinAlcohol),
        ("Agua", "💧", 1.5, .sinAlcohol),
        ("Vino", "🍷", 4.0, .alcohol),
        ("Copa", "🍸", 6.0, .alcohol),
        ("Café", "☕", 1.8, .sinAlcohol)
    ]
    
    static let categoriaMapping: [String: String] = [
        BebidaCategoria.alcohol.rawValue: BebidaCategoria.alcohol.localizedKey,
        BebidaCategoria.sinAlcohol.rawValue: BebidaCategoria.sinAlcohol.localizedKey
    ]
}
