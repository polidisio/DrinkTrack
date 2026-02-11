import SwiftUI

struct GestionarBebidasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bebidas: [Bebida] = []
    @State private var showingEditar = false
    @State private var bebidaToEditID: UUID?
    @State private var showingNueva = false
    
    let onDismiss: () -> Void
    
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
                            Text("\(String(format: "%.2f", bebida.precioBase)) €")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        let isDefault = isBebidaDefault(bebida)
                        if !isDefault {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isBebidaDefault(bebida), let id = bebida.id {
                            bebidaToEditID = id
                            showingEditar = true
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        if !isBebidaDefault(bebida) {
                            Button(role: .destructive) {
                                if let id = bebida.id, let freshBebida = CoreDataManager.shared.fetchBebidaByID(id) {
                                    deleteBebida(freshBebida)
                                }
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mis Productos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        onDismiss()
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
                EditarBebidaView(mode: .nueva) {
                    reloadData()
                }
            }
            .sheet(isPresented: $showingEditar) {
                if let id = bebidaToEditID {
                    EditarBebidaView(mode: .editar(id)) {
                        reloadData()
                    }
                }
            }
        }
        .onAppear {
            reloadData()
        }
    }
    
    private func isBebidaDefault(_ bebida: Bebida) -> Bool {
        let defaultNombres = ["Cerveza", "Refresco", "Agua", "Vino", "Copa", "Café"]
        return defaultNombres.contains(bebida.nombre ?? "")
    }
    
    private func deleteBebida(_ bebida: Bebida) {
        CoreDataManager.shared.deleteBebida(bebida)
        reloadData()
    }
    
    private func reloadData() {
        bebidas = CoreDataManager.shared.fetchBebidas()
    }
}
