import SwiftUI
import CoreData

struct ContentView: View {
    @State private var viewModel = ConsumicionViewModel()
    @State private var showingHistorial = false
    @State private var showingAddBebida = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con totales
                headerView
                
                // Lista de contadores
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.bebidas, id: \.id) { bebida in
                            BebidaCounterCard(
                                bebida: bebida,
                                count: viewModel.getConsumicionCount(for: bebida),
                                cost: viewModel.getConsumicionCost(for: bebida),
                                onAdd: { viewModel.addConsumicion(bebida: bebida) },
                                onRemove: { viewModel.decrementConsumicion(bebida: bebida) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Bottom actions
                bottomActionsView
            }
            .navigationTitle("Mi Consumo Bar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Historial") {
                        showingHistorial = true
                    }
                }
            }
            .sheet(isPresented: $showingHistorial) {
                HistorialView()
            }
            .sheet(isPresented: $showingAddBebida) {
                AddConsumicionView(bebidas: viewModel.bebidas) {
                    viewModel.refreshTodayData()
                }
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Hoy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalHoy.cantidad) bebidas")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Coste")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("€\(String(format: "%.2f", viewModel.totalHoy.coste))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
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
                    Text("Añadir Consumición")
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
        .background(Color(.systemBackground))
    }
}