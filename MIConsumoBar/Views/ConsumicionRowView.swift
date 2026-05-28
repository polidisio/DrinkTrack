import SwiftUI

struct ConsumicionRowView: View {
    let consumicion: Consumicion
    let bebidasLookup: [UUID: Bebida]

    init(consumicion: Consumicion, bebidasLookup: [UUID: Bebida] = [:]) {
        self.consumicion = consumicion
        self.bebidasLookup = bebidasLookup
    }

    private var bebida: Bebida? {
        guard let bebidaID = consumicion.bebidaID else { return nil }
        return bebidasLookup[bebidaID]
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(bebida?.emoji ?? "🥤")
                        .font(.title2)
                    Text(CoreDataManager.shared.localizedNombre(for: bebida?.nombre ?? ""))
                        .font(.headline)
                }
                
                HStack(spacing: 12) {
                    if let timestamp = consumicion.timestamp {
                        Text(formatTime(timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let notas = consumicion.notas, !notas.isEmpty {
                        Text("📝")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("x\(consumicion.cantidad)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(formatCurrency())
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    private func formatCurrency() -> String {
        let total = Double(consumicion.cantidad) * consumicion.precioUnitario
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        return formatter.string(from: NSNumber(value: total)) ?? "\(total) €"
    }
}
