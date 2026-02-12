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
                    Text(bebida?.nombre ?? "bebida_desconocida")
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
                
                let total = Double(consumicion.cantidad) * consumicion.precioUnitario
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
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
}
