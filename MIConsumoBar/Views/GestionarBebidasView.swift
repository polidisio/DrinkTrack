import SwiftUI

struct GestionarBebidasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bebidas: [Bebida] = []
    @State private var showingNueva = false
    @State private var editingBebida: Bebida?
    
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bebidas) { bebida in
                    Button(action: {
                        editingBebida = bebida
                    }) {
                        HStack {
                            Text(bebida.emoji ?? "")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text(bebida.nombre ?? "")
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
                            deleteBebida(bebida)
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
