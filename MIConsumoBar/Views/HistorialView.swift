import SwiftUI

struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var filterMode: FilterMode = .today
    @State private var consumiciones: [Consumicion] = []
    @State private var bebidas: [Bebida] = []
    @State private var consumicionesUltimos7: [Consumicion] = []
    @State private var showingDatePicker = false
    let onDismiss: () -> Void
    
    enum FilterMode {
        case today, yesterday, last7Days
    }
    
    private let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    chartsView
                    dateSelectorView
                    
                    if consumiciones.isEmpty {
                        emptyStateView
                    } else {
                        consumicionesListView
                    }
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
            .sheet(isPresented: $showingDatePicker) {
                NavigationStack {
                    DatePicker("Seleccionar fecha", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .navigationTitle("Seleccionar fecha")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Aceptar") {
                                    showingDatePicker = false
                                }
                            }
                        }
                }
            }
            .onChange(of: selectedDate) { _ in
                if filterMode != .last7Days {
                    loadConsumiciones()
                }
            }
            .onChange(of: filterMode) { _ in
                loadConsumiciones()
            }
        }
    }
    
    private var chartsView: some View {
        // Charts should always show last 7 days history, regardless of the selected date for the list
        ConsumptionChartView(
            consumiciones: consumicionesUltimos7,
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
                    filterMode = .today
                }
                .buttonStyle(DateButtonStyle(isSelected: filterMode == .today))
                
                Button("filtro_ayer") {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                    filterMode = .yesterday
                }
                .buttonStyle(DateButtonStyle(isSelected: filterMode == .yesterday))
                
                Button("filtro_ultimos_7_dias") {
                    filterMode = .last7Days
                }
                .buttonStyle(DateButtonStyle(isSelected: filterMode == .last7Days))
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
        // Load both the consumiciones for the list (based on filterMode/selectedDate)
        // and the consumiciones for the charts (always the last 7 days)
        consumicionesUltimos7 = coreDataManager.fetchConsumiciones(last7Days: true)
        loadConsumiciones()
    }
    
    private func loadConsumiciones() {
        if filterMode == .last7Days {
            consumiciones = consumicionesUltimos7
        } else {
            consumiciones = coreDataManager.fetchConsumiciones(for: selectedDate)
        }
    }
    
    private func deleteConsumiciones(at offsets: IndexSet) {
        for index in offsets {
            let consumicion = consumiciones[index]
            coreDataManager.deleteConsumicion(consumicion)
        }
        // Refresh both list and chart data after deletion
        consumicionesUltimos7 = coreDataManager.fetchConsumiciones(last7Days: true)
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
