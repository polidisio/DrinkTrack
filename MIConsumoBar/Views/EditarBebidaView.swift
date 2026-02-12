import SwiftUI
import CoreData

enum EditarBebidaMode {
    case nueva
    case editar(UUID)
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
    
    private var isFormValid: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty && (Double(precio) ?? 0) > 0
    }
    
    private var bebidaID: UUID?
    
    init(mode: EditarBebidaMode, onSave: @escaping (Bebida) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        if case .editar(let id) = mode {
            if let bebida = CoreDataManager.shared.fetchBebidaByID(id) {
                _nombre = State(initialValue: bebida.nombre ?? "")
                _emoji = State(initialValue: bebida.emoji ?? "📦")
                _precio = State(initialValue: String(format: "%.2f", bebida.precioBase))
                _categoria = State(initialValue: bebida.categoria ?? "Alcohol")
                bebidaID = id
            }
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
                            .keyboardType(.decimalPad)
                            .onChange(of: precio) { _, newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != newValue {
                                    precio = filtered
                                }
                            }
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
        guard let precioDouble = Double(precio), precioDouble > 0 else {
            print("ERROR: Precio inválido: \(precio)")
            return
        }
        let nombreTrimmed = nombre.trimmingCharacters(in: .whitespaces)
        
        if case .editar = mode, let id = bebidaID {
            print("EDITANDO BEBIDA ID: \(id)")
            print("  Nuevo nombre: \(nombreTrimmed)")
            print("  Nuevo emoji: \(emoji)")
            print("  Nuevo precio: \(precioDouble)")
            print("  Nueva categoría: \(categoria)")
            CoreDataManager.shared.updateBebidaByID(id, nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
            if let bebidaActualizada = CoreDataManager.shared.fetchBebidaByID(id) {
                onSave(bebidaActualizada)
            }
        } else {
            print("CREANDO NUEVA BEBIDA")
            let nuevaBebida = CoreDataManager.shared.createBebida(nombre: nombreTrimmed, emoji: emoji, precio: precioDouble, categoria: categoria)
            print("  Nueva bebida ID: \(nuevaBebida.id?.uuidString ?? "nil")")
            onSave(nuevaBebida)
        }
        
        print("DESPACHO dismiss()")
        dismiss()
    }
}

extension EditarBebidaMode {
    var isNueva: Bool {
        if case .nueva = self { return true }
        return false
    }
}
