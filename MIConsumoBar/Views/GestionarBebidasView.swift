import SwiftUI

struct GestionarBebidasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bebidas: [Bebida] = []
    @State private var showingNueva = false
    @State private var editingBebida: Bebida?
    @State private var showingDeleteAlert = false
    @State private var bebidaToDelete: Bebida?

    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(bebidas) { bebida in
                    Button(action: {
                        editingBebida = bebida
                    }) {
                        HStack {
                            Text(bebida.emoji ?? "")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(CoreDataManager.shared.localizedNombre(for: bebida.nombre ?? ""))
                                    .font(.headline)
                                Text(bebida.precioBase, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if CoreDataManager.shared.isBebidaDefault(bebida) {
                                bebidaToDelete = bebida
                                showingDeleteAlert = true
                            } else {
                                deleteBebida(bebida)
                            }
                        } label: {
                            Label("eliminar_button", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("mis_productos_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cerrar_button") {
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
                EditarBebidaView(mode: .nueva) { _ in
                    reloadData()
                }
            }
            .sheet(item: $editingBebida) { bebida in
                if let bebidaID = bebida.id {
                    EditarBebidaView(mode: .editar(bebidaID)) { _ in
                        reloadData()
                    }
                }
            }
            .alert("eliminar_default_title", isPresented: $showingDeleteAlert, presenting: bebidaToDelete) { bebida in
                Button("cancelar_button", role: .cancel) {}
                Button("eliminar_button", role: .destructive) {
                    deleteBebida(bebida)
                }
            } message: { bebida in
                Text(String(format: NSLocalizedString("eliminar_default_message", comment: ""), bebida.nombre ?? ""))
            }
        }
        .onAppear {
            reloadData()
        }
    }
    
    private func deleteBebida(_ bebida: Bebida) {
        CoreDataManager.shared.deleteBebida(bebida)
        reloadData()
    }
    
    private func reloadData() {
        bebidas = CoreDataManager.shared.fetchBebidas()
    }
}
