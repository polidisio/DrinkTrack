import SwiftUI

struct AddConsumicionView: View {
    @Environment(\.dismiss) var dismiss
    let bebidas: [Bebida]
    let onRefresh: () -> Void
    
    @State private var selectedBebidaIndex = 0
    @State private var cantidad: String = "1"
    @State private var precioUnitario: String = ""
    @State private var notas: String = ""
    @State private var timestamp: Date = Date()
    
    private var selectedBebida: Bebida? {
        bebidas.indices.contains(selectedBebidaIndex) ? bebidas[selectedBebidaIndex] : nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bebida") {
                    Picker("Tipo", selection: $selectedBebidaIndex) {
                        ForEach(0..<bebidas.count, id: \.self) { index in
                            let bebida = bebidas[index]
                            Text((bebida.emoji ?? "") + " " + (bebida.nombre ?? ""))
                        }
                    }
                }
                
                Section("Detalles") {
                    HStack {
                        Text("Cantidad")
                        Spacer()
                        TextField("1", text: $cantidad)
                            .frame(width: 50)
                    }
                    
                    HStack {
                        Text("Precio unitario")
                        Spacer()
                        TextField("0.00", text: $precioUnitario)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Total")
                        Spacer()
                        Text("€\(String(format: "%.2f", totalCost))")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Fecha y hora") {
                    DatePicker("Fecha y hora", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Notas") {
                    TextField("Notas opcionales", text: $notas)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Añadir Consumición")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveConsumicion()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                updatePrecioUnitario()
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
    
    private func updatePrecioUnitario() {
        if let bebida = selectedBebida, precioUnitario.isEmpty {
            precioUnitario = String(format: "%.2f", bebida.precioBase)
        }
    }
    
    private func saveConsumicion() {
        guard let bebida = selectedBebida,
              let bebidaID = bebida.id else { return }
        guard let cantidadInt = Int(cantidad) else { return }
        guard let precioDouble = Double(precioUnitario) else { return }
        
        CoreDataManager.shared.addConsumicion(
            bebidaID: bebidaID,
            cantidad: cantidadInt,
            precioUnitario: precioDouble,
            notas: notas.isEmpty ? nil : notas
        )
        
        onRefresh()
        dismiss()
    }
}
