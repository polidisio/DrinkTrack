import SwiftUI

struct ConsumicionRowView: View {
    let consumicion: Consumicion
    
    private let coreDataManager = CoreDataManager.shared
    private var bebida: Bebida? {
        coreDataManager.fetchBebidas().first { $0.id == consumicion.bebidaID }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(bebida?.emoji ?? "🥤")
                        .font(.title2)
                    Text(coreDataManager.localizedNombre(for: bebida?.nombre ?? ""))
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
