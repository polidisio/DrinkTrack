import SwiftUI

struct AddConsumicionView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void
    
    @State private var bebidas: [Bebida] = []
    @State private var selectedBebidaIndex = 0
    @State private var cantidad: String = "1"
    @State private var precioUnitario: String = ""
    @State private var notas: String = ""
    @State private var timestamp: Date = Date()
    @State private var showingGestionar = false
    
    private var selectedBebida: Bebida? {
        bebidas.indices.contains(selectedBebidaIndex) ? bebidas[selectedBebidaIndex] : nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("tipo_label", selection: $selectedBebidaIndex) {
                        ForEach(0..<bebidas.count, id: \.self) { index in
                            let bebida = bebidas[index]
                            Text((bebida.emoji ?? "") + " " + CoreDataManager.shared.localizedNombre(for: bebida.nombre ?? ""))
                        }
                    }
                } header: {
                    Text("bebida_section")
                }
                
                Section {
                    HStack {
                        Text("cantidad_label")
                        Spacer()
                        TextField("1", text: $cantidad)
                            .frame(width: 50)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Text("precio_unitario_label")
                        Spacer()
                        TextField("0.00", text: $precioUnitario)
                            .frame(width: 80)
                            .keyboardType(.decimalPad)
                            .onChange(of: precioUnitario) { _, newValue in
                                let filtered = newValue.replacingOccurrences(of: ",", with: ".")
                                if filtered != newValue {
                                    precioUnitario = filtered
                                }
                            }
                    }
                    
                    HStack {
                        Text("total_label")
                        Spacer()
                        Text(totalCost, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                } header: {
                    Text("detalles_section")
                }
                
                Section {
                    DatePicker("fecha_hora_section", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("fecha_hora_section")
                }
                
                Section {
                    TextField("notas_placeholder", text: $notas)
                        .lineLimit(3...6)
                } header: {
                    Text("notas_section")
                }
            }
            .navigationTitle("add_consumption_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancelar_button") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        showingGestionar = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "gear")
                            Text("gestionar_button")
                        }
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("guardar_button") {
                        saveConsumicion()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingGestionar) {
                GestionarBebidasView {
                    reloadBebidas()
                }
            }
            .onAppear {
                reloadBebidas()
            }
            .onChange(of: selectedBebidaIndex) { _, _ in
                updatePrecioUnitario()
            }
        }
    }
    
    private var totalCost: Double {
        let cantidadDouble = Double(cantidad) ?? 0
        let precioDouble = Double(precioUnitario) ?? 0
        return cantidadDouble * precioDouble
    }
    
    private var isFormValid: Bool {
        guard selectedBebida != nil else { return false }
        guard let cantidadDouble = Double(cantidad), cantidadDouble > 0 else { return false }
        guard let precioDouble = Double(precioUnitario), precioDouble > 0 else { return false }
        return true
    }
    
    private func reloadBebidas() {
        let freshBebidas = CoreDataManager.shared.fetchBebidas()
        guard !freshBebidas.isEmpty else {
            bebidas = []
            return
        }
        
        bebidas = freshBebidas
        
        if selectedBebidaIndex >= bebidas.count {
            selectedBebidaIndex = 0
        }
        
        if let index = bebidas.indices.contains(selectedBebidaIndex) ? selectedBebidaIndex : nil {
            let currentBebida = bebidas[index]
            if let freshBebida = CoreDataManager.shared.fetchBebidas().first(where: { $0.id == currentBebida.id }) {
                precioUnitario = String(format: "%.2f", freshBebida.precioBase)
            }
        }
    }
    
    private func updatePrecioUnitario() {
        if let index = bebidas.indices.contains(selectedBebidaIndex) ? selectedBebidaIndex : nil {
            let currentBebida = bebidas[index]
            if let freshBebida = CoreDataManager.shared.fetchBebidas().first(where: { $0.id == currentBebida.id }) {
                precioUnitario = String(format: "%.2f", freshBebida.precioBase)
            }
        }
    }
    
    private func saveConsumicion() {
        guard let bebida = selectedBebida,
              let bebidaID = bebida.id else {
            print("ERROR: No hay bebida seleccionada")
            return
        }
        
        guard let cantidadInt = Int(cantidad), cantidadInt > 0 else {
            print("ERROR: Cantidad inválida: \(cantidad)")
            return
        }
        
        guard let precioDouble = Double(precioUnitario), precioDouble > 0 else {
            print("ERROR: Precio inválido: \(precioUnitario)")
            return
        }
        
        print("GUARDANDO CONSUMICION: bebidaID=\(bebidaID), cantidad=\(cantidadInt), precio=\(precioDouble)")
        
        let currentNombre = bebida.nombre ?? ""
        let currentEmoji = bebida.emoji ?? "📦"
        let currentCategoria = bebida.categoria ?? "Alcohol"
        
        CoreDataManager.shared.updateBebidaByID(
            bebidaID,
            nombre: currentNombre,
            emoji: currentEmoji,
            precio: precioDouble,
            categoria: currentCategoria
        )
        print("PRECIO DE BEBIDA ACTUALIZADO A: \(precioDouble)")
        
        CoreDataManager.shared.addConsumicion(
            bebidaID: bebidaID,
            cantidad: cantidadInt,
            precioUnitario: precioDouble,
            notas: notas.isEmpty ? nil : notas
        )
        
        print("CONSUMICION GUARDADA - LLAMANDO onSave()")
        onSave()
        print("DESPACHO dismiss()")
        dismiss()
    }
}
