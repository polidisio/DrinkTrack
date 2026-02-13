import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ShareBebidasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: Set<String> = []
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    let bebidas: [BebidaExportItem]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Button("share_select_all") {
                            selectedItems = Set(bebidas.map { $0.id.uuidString })
                        }
                        Spacer()
                        Button("share_deselect_all") {
                            selectedItems.removeAll()
                        }
                    }
                    .font(.subheadline)
                }
                
                Section {
                    ForEach(bebidas) { item in
                        Button(action: {
                            toggleSelection(itemID: item.id.uuidString)
                        }) {
                            HStack {
                                Text(item.emoji)
                                    .font(.title2)
                                Text(item.nombre)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: selectedItems.contains(item.id.uuidString) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedItems.contains(item.id.uuidString) ? .orange : .gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("share_bebidas_title")
            .navigationBarItems(
                leading: Button("cancelar") { dismiss() },
                trailing: shareButton
            )
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareURL {
                    ShareActivityView(activityItems: [url])
                }
            }
        }
    }
    
    private func toggleSelection(itemID: String) {
        if selectedItems.contains(itemID) {
            selectedItems.remove(itemID)
        } else {
            selectedItems.insert(itemID)
        }
    }
    
    private var shareButton: some View {
        Button(action: shareTapped) {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(selectedItems.isEmpty)
    }
    
    private func shareTapped() {
        let selectedBebidas = bebidas.filter { selectedItems.contains($0.id.uuidString) }
        shareURL = createExportURL(selectedBebidas)
        if shareURL != nil {
            showingShareSheet = true
        }
    }
    
    private func createExportURL(_ items: [BebidaExportItem]) -> URL? {
        let data = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: items)
        
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("bebidas.json")
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
}

struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
