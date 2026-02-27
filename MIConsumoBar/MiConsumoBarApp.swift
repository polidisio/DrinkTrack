import SwiftUI
import Combine

@main
struct MiConsumoBarApp: App {
    @State private var showingImportAlert = false
    @State private var pendingImportURL: URL?
    @StateObject private var importViewModel = ImportViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(importViewModel)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onAppear {
                    CoreDataManager.shared.cleanupOldConsumiciones()
                }
                .alert("Importar Bebidas", isPresented: $showingImportAlert) {
                    Button("Combinar") {
                        importViewModel.importMode = .merge
                        importViewModel.processImport(url: pendingImportURL)
                    }
                    Button("Reemplazar") {
                        importViewModel.importMode = .overwrite
                        importViewModel.processImport(url: pendingImportURL)
                    }
                    Button("Cancelar", role: .cancel) {}
                } message: {
                    Text("¿Cómo quieres importar las bebidas?")
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.pathExtension == "json" else { return }
        pendingImportURL = url
        showingImportAlert = true
    }
}

class ImportViewModel: ObservableObject {
    var importMode: BebidaImporter.ImportMode = .merge
    
    func processImport(url: URL?) {
        guard let url = url else { return }
        
        if let exportData = BebidaImporter.shared.parseExportData(from: url) {
            let context = CoreDataManager.shared.context
            
            switch importMode {
            case .merge:
                BebidaImporter.shared.mergeBebidasSync(exportData.bebidas, context: context)
            case .overwrite:
                BebidaImporter.shared.overwriteBebidasSync(exportData.bebidas, context: context)
            case .cancel:
                break
            }
            
            print("Bebidas importadas exitosamente")
        }
    }
}
