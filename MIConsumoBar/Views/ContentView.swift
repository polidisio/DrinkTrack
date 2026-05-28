import SwiftUI

struct ContentView: View {
    @State private var showingHistorial = false
    @State private var showingAddBebida = false
    @State private var showingSettings = false
    @State private var refreshTrigger = UUID()
    @StateObject private var viewModel = ConsumicionViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("budgetAmount") private var budgetAmount: Double = 0
    @AppStorage("budgetPeriod") private var budgetPeriod: String = "monthly"

    private var sortedBebidas: [Bebida] {
        viewModel.bebidas.sorted { bebida1, bebida2 in
            let count1 = viewModel.getConsumicionCount(for: bebida1)
            let count2 = viewModel.getConsumicionCount(for: bebida2)
            return count1 > count2
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    headerView
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sortedBebidas, id: \.objectID) { bebida in
                                BebidaCounterCard(
                                    bebida: bebida,
                                    count: viewModel.getConsumicionCount(for: bebida),
                                    cost: viewModel.getConsumicionCost(for: bebida),
                                    onAdd: { viewModel.addConsumicion(bebida: bebida) },
                                    onRemove: { viewModel.decrementConsumicion(bebida: bebida) },
                                    onReset: { viewModel.resetCounters(for: bebida) }
                                )
                            }
                        }
                        .id(refreshTrigger)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    bottomActionsView
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    let exportItems = sortedBebidas.map { bebida in
                        let cantidad = viewModel.getConsumicionCount(for: bebida)
                        return BebidaExporter.shared.createExportItem(from: bebida, cantidad: cantidad)
                    }
                    if let shareURL = BebidaExporter.shared.exportBebidas(exportItems) {
                        ShareLink(
                            item: shareURL,
                            subject: Text("Exportación de Bebidas"),
                            message: Text("Mis bebidas de MyBarTrack")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    } else {
                        EmptyView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.orange)
                        }
                        
                        Button("historial_title") {
                            showingHistorial = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHistorial) {
                HistorialView {
                    viewModel.loadData()
                }
            }
            .sheet(isPresented: $showingAddBebida) {
                AddConsumicionView(onSave: {
                    viewModel.loadData()
                })
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(onDismiss: {
                    print("DEBUG: Settings dismissed, reloading data")
                    self.refreshTrigger = UUID()
                    viewModel.loadData()
                })
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.loadData()
            }
        }
    }
    
    private var periodStart: Date {
        let calendar = Calendar.current
        if budgetPeriod == "weekly" {
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        } else {
            return calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        }
        }
    }

    private var periodSpending: Double {
        CoreDataManager.shared.getTotalSpending(since: periodStart)
    }

    private var budgetProgress: Double {
        guard budgetAmount > 0 else { return 0 }
        return min(periodSpending / budgetAmount, 1.5)
    }

    private var budgetColor: Color {
        guard budgetAmount > 0 else { return .clear }
        let progress = periodSpending / budgetAmount
        if progress >= 1.0 { return .red }
        if progress >= 0.8 { return .orange }
        return .green
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("total_hoy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalHoy.cantidad) \(viewModel.totalHoy.cantidad == 1 ? "drink" : "drinks")")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("coste_label")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(viewModel.totalHoy.coste, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            if budgetAmount > 0 {
                budgetProgressView
            }
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var budgetProgressView: some View {
        VStack(spacing: 4) {
            HStack {
                Text(String(format: "%.1f %@ / %.1f %@",
                    periodSpending,
                    Locale.current.currencySymbol ?? "€",
                    budgetAmount,
                    Locale.current.currencySymbol ?? "€"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(budgetProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(budgetColor)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)

            ProgressView(value: budgetProgress, total: 1.0)
                .tint(budgetColor)
                .padding(.horizontal, 16)
        }
    }
    
    private var bottomActionsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingAddBebida = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("anadir_consumicion_button")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }
}
