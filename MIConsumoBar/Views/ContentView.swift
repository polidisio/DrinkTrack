import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingHistorial = false
    @State private var showingAddBebida = false
    @State private var bebidas: [Bebida] = []
    @State private var consumicionesHoy: [Consumicion] = []
    @State private var totalHoy: (cantidad: Int, coste: Double) = (0, 0.0)
    
    var body: some View {
        NavigationView {
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
    
    private func reloadData() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orden", ascending: true)]
        bebidas = (try? context.fetch(request)) ?? []
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let consumicionRequest: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        consumicionRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        consumicionRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        consumicionesHoy = (try? context.fetch(consumicionRequest)) ?? []
        
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
                    Text(LocalizedStringKey("bebidas_count"), value: totalHoy.cantidad, format: .number)
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
