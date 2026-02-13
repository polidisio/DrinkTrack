import SwiftUI

struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var consumiciones: [Consumicion] = []
    @State private var bebidas: [Bebida] = []
    @State private var showingDatePicker = false
    let onDismiss: () -> Void
    
    private let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chartsView
                dateSelectorView
                
                if consumiciones.isEmpty {
                    emptyStateView
                } else {
                    consumicionesListView
                }
            }
            .navigationTitle("historial_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cerrar_button") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadData()
            }
            .onChange(of: selectedDate) { _, _ in
                loadConsumiciones()
            }
        }
    }
    
    private var chartsView: some View {
        ConsumptionChartView(
            consumiciones: consumiciones,
            bebidas: bebidas
        )
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
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack(spacing: 8) {
                Button("filtro_hoy") {
                    selectedDate = Date()
                }
                .buttonStyle(DateButtonStyle(isSelected: Calendar.current.isDateInToday(selectedDate)))
                
                Button("filtro_ayer") {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                }
                .buttonStyle(DateButtonStyle(isSelected: isYesterday(selectedDate)))
                
                Button("filtro_ultimos_7_dias") {
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
            Text("no_hay_consumiciones")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("no_hay_consumiciones_fecha")
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
    
    private func loadData() {
        bebidas = coreDataManager.fetchBebidas()
        loadConsumiciones()
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
        formatter.locale = Locale.current
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
            .background(isSelected ? Color.orange : Color(uiColor: .systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
