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
                            Text("\(String(format: "%.2f", bebida.precioBase)) €")
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
                EditarBebidaView(mode: .nueva) { nuevaBebida in
                    bebidas = viewModel.bebidas
                }
            }
            .sheet(isPresented: $showingEditar) {
                if let bebida = bebidaToEdit {
                    EditarBebidaView(mode: .editar(bebida)) { bebidaEditada in
                        bebidas = viewModel.bebidas
                    }
                }
            }
        }
        .onAppear {
            bebidas = viewModel.bebidas
        }
    }
}

#Preview {
    GestionarBebidasView()
}
