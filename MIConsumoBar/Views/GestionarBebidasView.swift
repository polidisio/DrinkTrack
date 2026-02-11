import SwiftUI

struct GestionarBebidasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bebidas: [Bebida] = []
    @State private var showingEditar = false
    @State private var bebidaToEdit: Bebida?
    @State private var showingNueva = false
    
    private let viewModel = ConsumicionViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bebidas) { bebida in
                    HStack {
                        Text(bebida.emoji ?? "")
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(bebida.nombre ?? "")
                                .font(.headline)
                            Text("\(String(format: "%.2f", getFreshPrecio(bebida: bebida))) €")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if !viewModel.isBebidaDefault(bebida) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !viewModel.isBebidaDefault(bebida) {
                            bebidaToEdit = bebida
                            showingEditar = true
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        if !viewModel.isBebidaDefault(bebida) {
                            Button(role: .destructive) {
                                viewModel.deleteBebidaPersonalizada(bebida)
                                reloadData()
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mis Productos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNueva = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNueva) {
                EditarBebidaView(viewModel: viewModel, mode: .nueva) { _ in
                    reloadData()
                }
            }
            .sheet(isPresented: $showingEditar) {
                if let bebida = bebidaToEdit {
                    EditarBebidaView(viewModel: viewModel, mode: .editar(bebida)) { _ in
                        reloadData()
                    }
                }
            }
        }
        .onAppear {
            reloadData()
        }
    }
    
    private func getFreshPrecio(bebida: Bebida) -> Double {
        if let id = bebida.id {
            return CoreDataManager.shared.fetchBebidas().first { $0.id == id }?.precioBase ?? bebida.precioBase
        }
        return bebida.precioBase
    }
    
    private func reloadData() {
        bebidas = CoreDataManager.shared.fetchBebidas()
    }
}
