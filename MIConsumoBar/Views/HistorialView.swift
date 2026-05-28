import SwiftUI

struct HistorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var filterMode: FilterMode = .today
    @State private var consumiciones: [Consumicion] = []
    @State private var bebidas: [Bebida] = []
    @State private var consumicionesChart: [Consumicion] = []
    @State private var chartDayRange: Int = 7
    @State private var searchText = ""
    @State private var selectedBebidaFilter: UUID?
    @State private var showingDatePicker = false
    @State private var isLoading = false
    let onDismiss: () -> Void

    enum FilterMode {
        case today, yesterday, last7Days
    }

    private let coreDataManager = CoreDataManager.shared

    private var filteredConsumiciones: [Consumicion] {
        var result = consumiciones
        if !searchText.isEmpty {
            result = result.filter { c in
                guard let id = c.bebidaID, let bebida = bebidasLookup[id] else { return false }
                let name = (bebida.nombre ?? "").lowercased()
                return name.contains(searchText.lowercased())
            }
        }
        if let filterID = selectedBebidaFilter {
            result = result.filter { $0.bebidaID == filterID }
        }
        return result
    }

    private var bebidasLookup: [UUID: Bebida] {
        Dictionary(uniqueKeysWithValues: bebidas.compactMap { bebida in
            guard let id = bebida.id else { return nil }
            return (id, bebida)
        })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        chartsView
                        dateSelectorView

                        filterView

                        if filteredConsumiciones.isEmpty {
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

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color(uiColor: .systemBackground).opacity(0.8))
                }
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
            .onChange(of: chartDayRange) { _ in
                loadChartData()
            }
        }
    }

    private var chartsView: some View {
        VStack(spacing: 8) {
            Picker("chart_range_label", selection: $chartDayRange) {
                Text("chart_range_7d").tag(7)
                Text("chart_range_30d").tag(30)
                Text("chart_range_90d").tag(90)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ConsumptionChartView(
                consumiciones: consumicionesChart,
                bebidas: bebidas,
                dayRange: chartDayRange
            )
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

    private var filterView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("search_placeholder", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            if !bebidas.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button("filter_all") {
                            selectedBebidaFilter = nil
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: selectedBebidaFilter == nil))

                        ForEach(bebidas) { bebida in
                            Button(action: {
                                selectedBebidaFilter = selectedBebidaFilter == bebida.id ? nil : bebida.id
                            }) {
                                HStack(spacing: 4) {
                                    Text(bebida.emoji ?? "")
                                    Text(CoreDataManager.shared.localizedNombre(for: bebida.nombre ?? ""))
                                }
                            }
                            .buttonStyle(FilterButtonStyle(isSelected: selectedBebidaFilter == bebida.id))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
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
            ForEach(filteredConsumiciones) { consumicion in
                ConsumicionRowView(consumicion: consumicion, bebidasLookup: bebidasLookup)
            }
            .onDelete(perform: deleteConsumiciones)
        }
        .listStyle(PlainListStyle())
    }

    private func loadData() {
        bebidas = coreDataManager.fetchBebidas()
        loadChartData()
        loadConsumiciones()
    }

    private func loadChartData() {
        consumicionesChart = coreDataManager.fetchConsumiciones(lastDays: chartDayRange)
    }

    private func loadConsumiciones() {
        if filterMode == .last7Days {
            consumiciones = consumicionesChart
        } else {
            consumiciones = coreDataManager.fetchConsumiciones(for: selectedDate)
        }
    }

    private func deleteConsumiciones(at offsets: IndexSet) {
        for index in offsets {
            let consumicion = filteredConsumiciones[index]
            coreDataManager.deleteConsumicion(consumicion)
        }
        loadChartData()
        loadConsumiciones()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}

struct FilterButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(uiColor: .systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
