import SwiftUI
import CoreData

enum EditarBebidaMode {
    case nueva
    case editar(Bebida)
}

struct EditarBebidaView: View {
    @Environment(\.dismiss) var dismiss
    let mode: EditarBebidaMode
    let onSave: (Bebida) -> Void
    
    @State private var nombre: String = ""
    @State private var emoji: String = "📦"
    @State private var precio: String = ""
    @State private var categoria: String = "Alcohol"
    
    private let categorias = ["Alcohol", "Sin Alcohol"]
    private let viewModel = ConsumicionViewModel()
    
    private var isFormValid: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty && (Double(precio) ?? 0) > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información") {
                    TextField("Nombre", text: $nombre)
                    
                    HStack {
                        Text("Emoji")
                        Spacer()
                        Text(emoji)
                            .font(.title2)
                            .onTapGesture {
                                showingEmojiPicker = true
                            }
                    }
                }
                
                Section("Precio") {
                    HStack {
                        Text("€")
                        TextField("0.00", text: $precio)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $categoria) {
                        ForEach(categorias, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(mode.isNueva ? "Nuevo Producto" : "Editar Producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        save()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(selectedEmoji: $emoji)
            }
            .onAppear {
                if case .editar(let bebida) = mode {
                    nombre = bebida.nombre ?? ""
                    emoji = bebida.emoji ?? "📦"
                    precio = String(format: "%.2f", bebida.precioBase)
                    categoria = bebida.categoria ?? "Alcohol"
                }
            }
        }
    }
    
    @State private var showingEmojiPicker = false
    
    private func save() {
        guard let precioDouble = Double(precio), precioDouble > 0 else { return }
        let nombreTrimmed = nombre.trimmingCharacters(in: .whitespaces)
        
        if case .editar(let bebida) = mode {
            viewModel.updateBebida(bebida, nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
        } else {
            _ = viewModel.createBebidaPersonalizada(nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
        }
        
        dismiss()
    }
}

struct EmojiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedEmoji: String
    
    private let emojis = [
        "🍺", "🥤", "💧", "🍷", "🍸", "☕",
        "🍹", "🍺", "🥂", "🧉", "🥃", "🍷",
        "🧋", "🍵", "🥛", "🫖", "🍶", "🥡",
        "🍲", "🍛", "🍜", "🥘", "🍝", "🍕",
        "🍔", "🍟", "🌭", "🥪", "🌮", "🌯"
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(selectedEmoji == emoji ? Color.orange.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedEmoji = emoji
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension EditarBebidaMode {
    var isNueva: Bool {
        if case .nueva = self { return true }
        return false
    }
}
