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
        print("DEBUG: Received URL: \(url)")
        print("DEBUG: Path extension: \(url.pathExtension)")
        
        guard url.pathExtension == "json" else { 
            print("DEBUG: Not a JSON file")
            return 
        }
        
        // Start accessing security-scoped resource
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        
        do {
            // Get Documents directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsURL.appendingPathComponent("imported_bebidas.json")
            
            // Remove existing file if exists
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file to Documents
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("DEBUG: File copied to: \(destinationURL)")
            
            pendingImportURL = destinationURL
            showingImportAlert = true
            
        } catch {
            print("DEBUG: Error copying file: \(error)")
            
            // Fallback: try to use the URL directly
            pendingImportURL = url
            showingImportAlert = true
        }
        
        if shouldStopAccessing {
            url.stopAccessingSecurityScopedResource()
        }
    }
}

class ImportViewModel: ObservableObject {
    var importMode: BebidaImporter.ImportMode = .merge
    var onImportComplete: (() -> Void)?
    
    func processImport(url: URL?) {
        guard let url = url else { 
            print("DEBUG: No URL provided for import")
            return 
        }
        
        print("DEBUG: Processing import from: \(url)")
        
        Task { @MainActor in
            do {
                if let exportData = BebidaImporter.shared.parseExportData(from: url) {
                    print("DEBUG: Parsed \(exportData.bebidas.count) bebidas")
                    
                    try await BebidaImporter.shared.importBebidas(
                        from: exportData,
                        mode: importMode,
                        context: CoreDataManager.shared.context
                    )
                    
                    print("DEBUG: Bebidas importadas exitosamente")
                    onImportComplete?()
                } else {
                    print("DEBUG: Failed to parse export data")
                }
            } catch {
                print("DEBUG: Error importando bebidas: \(error)")
            }
        }
    }
}
