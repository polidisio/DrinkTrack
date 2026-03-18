import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingHistorial = false
    @State private var showingAddBebida = false
    @State private var showingSettings = false
    @State private var refreshTrigger = UUID()
    @StateObject private var viewModel = ConsumicionViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let shareURL = createShareURL() {
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
    
    private func createShareURL() -> URL? {
        let exportItems = sortedBebidas.map { bebida in
            let cantidad = viewModel.getConsumicionCount(for: bebida)
            return BebidaExportItem(
                id: bebida.id ?? UUID(),
                nombre: bebida.nombre ?? "",
                emoji: bebida.emoji ?? "",
                precioBase: bebida.precioBase,
                categoria: bebida.categoria ?? "",
                orden: bebida.orden,
                cantidad: cantidad
            )
        }
        let exportData = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: exportItems)
        
        guard let jsonData = try? JSONEncoder().encode(exportData) else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("bebidas.json")
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
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
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 8)
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
