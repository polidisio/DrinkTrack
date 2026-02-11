import SwiftUI

struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var consumiciones: [Consumicion] = []
    @State private var showingDatePicker = false
    let onDismiss: () -> Void
    
    private let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date selector
                dateSelectorView
                
                // Lista de consumiciones
                if consumiciones.isEmpty {
                    emptyStateView
                } else {
                    consumicionesListView
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadConsumiciones()
            }
            .onChange(of: selectedDate) { _, _ in
                loadConsumiciones()
            }
        }
    }
    
    private var dateSelectorView: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Image(systemName: "calendar")
                    Text(formatDate(selectedDate))
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quick date buttons
            HStack(spacing: 8) {
                Button("Hoy") {
                    selectedDate = Date()
                }
                .buttonStyle(DateButtonStyle(isSelected: Calendar.current.isDateInToday(selectedDate)))
                
                Button("Ayer") {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                }
                .buttonStyle(DateButtonStyle(isSelected: isYesterday(selectedDate)))
                
                Button("Últimos 7 días") {
                    // Implementar vista de 7 días
                }
                .buttonStyle(DateButtonStyle(isSelected: false))
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No hay consumiciones")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("No has registrado ninguna bebida para esta fecha")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var consumicionesListView: some View {
        List {
            ForEach(consumiciones) { consumicion in
                ConsumicionRowView(consumicion: consumicion)
            }
            .onDelete(perform: deleteConsumiciones)
        }
        .listStyle(PlainListStyle())
    }
    
    private func loadConsumiciones() {
        consumiciones = coreDataManager.fetchConsumiciones(for: selectedDate)
    }
    
    private func deleteConsumiciones(at offsets: IndexSet) {
        for index in offsets {
            let consumicion = consumiciones[index]
            coreDataManager.deleteConsumicion(consumicion)
        }
        loadConsumiciones()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func isYesterday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        return calendar.isDate(date, inSameDayAs: yesterday)
    }
}

struct DateButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}