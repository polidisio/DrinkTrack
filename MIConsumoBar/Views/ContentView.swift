import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingHistorial = false
    @State private var showingAddBebida = false
    @State private var bebidas: [Bebida] = []
    @State private var consumicionesHoy: [Consumicion] = []
    @State private var totalHoy: (cantidad: Int, coste: Double) = (0, 0.0)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(bebidas, id: \.id) { bebida in
                            BebidaCounterCard(
                                bebida: bebida,
                                count: getConsumicionCount(for: bebida),
                                cost: getConsumicionCost(for: bebida),
                                onAdd: { addConsumicion(bebida: bebida) },
                                onRemove: { decrementConsumicion(bebida: bebida) },
                                onReset: { resetCounters(for: bebida) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
                
                bottomActionsView
            }
            .navigationTitle("DrinkTrack")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let shareURL = createShareURL() {
                        ShareLink(
                            item: shareURL,
                            subject: Text("Exportación de Bebidas"),
                            message: Text("Mis bebidas de DrinkTrack")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    } else {
                        EmptyView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("historial_title") {
                        showingHistorial = true
                    }
                }
            }
            .sheet(isPresented: $showingHistorial) {
                HistorialView {
                    reloadData()
                }
            }
            .sheet(isPresented: $showingAddBebida) {
                AddConsumicionView(onSave: {
                    reloadData()
                })
            }
        }
        .onAppear {
            reloadData()
        }
    }
    
    private func createShareURL() -> URL? {
        let exportItems = bebidas.map { bebida in
            BebidaExportItem(
                id: bebida.id ?? UUID(),
                nombre: bebida.nombre ?? "",
                emoji: bebida.emoji ?? "",
                precioBase: bebida.precioBase,
                categoria: bebida.categoria ?? "",
                orden: bebida.orden
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
    
    private func reloadData() {
        let context = CoreDataManager.shared.context
        let bebidasRequest: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        let allBebidas = (try? context.fetch(bebidasRequest)) ?? []
        
        let consumicionRequest: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        let allConsumiciones = (try? context.fetch(consumicionRequest)) ?? []
        
        let bebidasTotales: [(bebida: Bebida, total: Int)] = allBebidas.map { bebida in
            let total = allConsumiciones
                .filter { $0.bebidaID == bebida.id }
                .reduce(0) { $0 + Int($1.cantidad) }
            return (bebida, total)
        }
        
        bebidas = bebidasTotales
            .sorted { $0.total > $1.total }
            .map { $0.bebida }
        
        consumicionesHoy = allConsumiciones
        
        totalHoy = calculateTotal()
    }
    
    private func calculateTotal() -> (Int, Double) {
        let cantidad = consumicionesHoy.reduce(0) { $0 + Int($1.cantidad) }
        let coste = consumicionesHoy.reduce(0.0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
        return (cantidad, coste)
    }
    
    private func getConsumicionCount(for bebida: Bebida) -> Int {
        return consumicionesHoy
            .filter { $0.bebidaID == bebida.id }
            .reduce(0) { $0 + Int($1.cantidad) }
    }
    
    private func getConsumicionCost(for bebida: Bebida) -> Double {
        return consumicionesHoy
            .filter { $0.bebidaID == bebida.id }
            .reduce(0.0) { $0 + (Double($1.cantidad) * $1.precioUnitario) }
    }
    
    private func addConsumicion(bebida: Bebida) {
        guard let bebidaID = bebida.id else { return }
        
        let consumicion = Consumicion(context: CoreDataManager.shared.context)
        consumicion.id = UUID()
        consumicion.bebidaID = bebidaID
        consumicion.cantidad = 1
        consumicion.precioUnitario = bebida.precioBase
        consumicion.timestamp = Date()
        
        do {
            try CoreDataManager.shared.context.save()
            reloadData()
        } catch {
            print("Error adding consumicion: \(error)")
        }
    }
    
    private func decrementConsumicion(bebida: Bebida) {
        let consumicionesBebida = consumicionesHoy.filter { $0.bebidaID == bebida.id }
        if let primera = consumicionesBebida.first {
            if primera.cantidad > 1 {
                primera.cantidad -= 1
            } else {
                CoreDataManager.shared.context.delete(primera)
            }
            do {
                try CoreDataManager.shared.context.save()
                reloadData()
            } catch {
                print("Error decrementing consumicion: \(error)")
            }
        }
    }
    
    private func resetCounters(for bebida: Bebida) {
        let consumicionesBebida = consumicionesHoy.filter { $0.bebidaID == bebida.id }
        for consumicion in consumicionesBebida {
            CoreDataManager.shared.context.delete(consumicion)
        }
        do {
            try CoreDataManager.shared.context.save()
            reloadData()
        } catch {
            print("Error resetting counters: \(error)")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("total_hoy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(totalHoy.cantidad) \(totalHoy.cantidad == 1 ? "drink" : "drinks")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("coste_label")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(totalHoy.coste, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
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
