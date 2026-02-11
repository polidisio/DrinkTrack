import SwiftUI

struct BebidaCounterCard: View {
    let bebida: Bebida
    let count: Int
    let cost: Double
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(bebida.emoji ?? "")
                    .font(.system(size: 32))
                Text(bebida.nombre ?? "Bebida")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(bebida.categoria ?? "Sin categoría")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .disabled(count <= 0)
                    
                    Text("\(count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 40)
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    Button(action: onReset) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("€\(String(format: "%.2f", cost))")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .separator), lineWidth: 1)
        )
    }
}