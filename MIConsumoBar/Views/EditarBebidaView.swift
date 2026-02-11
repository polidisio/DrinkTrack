import SwiftUI
import CoreData

enum EditarBebidaMode {
    case nueva
    case editar(Bebida)
}

struct EditarBebidaView: View {
    @Environment(\.dismiss) var dismiss
    let mode: EditarBebidaMode
    let onSave: () -> Void
    
    @State private var nombre: String = ""
    @State private var emoji: String = "📦"
    @State private var precio: String = ""
    @State private var categoria: String = "Alcohol"
    
    private let categorias = ["Alcohol", "Sin Alcohol"]
    
    private var isFormValid: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty && (Double(precio) ?? 0) > 0
    }
    
    private var bebidaID: UUID?
    
    init(mode: EditarBebidaMode, onSave: @escaping () -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .editar(let bebida) = mode {
            _nombre = State(initialValue: bebida.nombre ?? "")
            _emoji = State(initialValue: bebida.emoji ?? "📦")
            _precio = State(initialValue: String(format: "%.2f", bebida.precioBase))
            _categoria = State(initialValue: bebida.categoria ?? "Alcohol")
            bebidaID = bebida.id
        }
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
        }
    }
    
    @State private var showingEmojiPicker = false
    
    private func save() {
        guard let precioDouble = Double(precio), precioDouble > 0 else { return }
        let nombreTrimmed = nombre.trimmingCharacters(in: .whitespaces)
        
        if case .editar = mode, let id = bebidaID {
            CoreDataManager.shared.updateBebidaByID(id, nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
        } else {
            _ = CoreDataManager.shared.createBebida(nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
        }
        
        onSave()
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
