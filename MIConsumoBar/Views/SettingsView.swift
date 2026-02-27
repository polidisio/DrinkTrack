import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("retentionDays") private var retentionDays: Int = 0
    @State private var showingClearAlert = false
    @State private var showingImportPicker = false
    @State private var showingImportAlert = false
    @State private var pendingImportURL: URL?
    @State private var hasSecurityAccess = false
    @State private var importError: String?
    @State private var importSuccess = false
    
    var onDismiss: (() -> Void)?
    
    private let retentionOptions: [(key: String, days: Int)] = [
        ("retention_0", 0),
        ("retention_7", 7),
        ("retention_30", 30),
        ("retention_90", 90),
        ("retention_365", 365)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: $retentionDays) {
                        ForEach(retentionOptions, id: \.days) { option in
                            Text(localizedRetention(key: option.key, days: option.days))
                                .tag(option.days)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.orange)
                            Text("retention_label")
                        }
                    }
                } header: {
                    Text("retention_section")
                } footer: {
                    Text("retention_footer")
                }
                
                Section {
                    Button {
                        showingImportPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.orange)
                            Text("import_drinks_button")
                        }
                    }
                } header: {
                    Text("data_section")
                } footer: {
                    Text("import_drinks_footer")
                }
                
                Section {
                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("clear_all_button")
                        }
                    }
                } header: {
                    Text("clear_section")
                } footer: {
                    Text("clear_footer")
                }
                
                Section {
                    HStack {
                        Text("version_label")
                        Spacer()
                        Text(TextBundle.current.appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("about_section")
                }
            }
            .navigationTitle("settings_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done_button") {
                        dismiss()
                    }
                }
            }
            .alert("clear_all_title", isPresented: $showingClearAlert) {
                Button("cancel_button", role: .cancel) {}
                Button("clear_confirm_button", role: .destructive) {
                    clearAllConsumiciones()
                }
            } message: {
                Text("clear_all_message")
            }
            .alert("import_drinks_title", isPresented: $showingImportAlert) {
                Button("merge_button") {
                    processImport(mode: .merge)
                }
                Button("replace_button") {
                    processImport(mode: .overwrite)
                }
                Button("cancel_button", role: .cancel) {}
            } message: {
                Text("import_drinks_message")
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
        }
    }
    
    private func localizedRetention(key: String, days: Int) -> String {
        if days == 0 {
            return NSLocalizedString("retention_indefinite", comment: "")
        } else {
            return String(format: NSLocalizedString("retention_days", comment: ""), days)
        }
    }
    
    private func clearAllConsumiciones() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Consumicion> = Consumicion.fetchRequest()
        
        do {
            let allConsumiciones = try context.fetch(request)
            for consumicion in allConsumiciones {
                context.delete(consumicion)
            }
            try context.save()
        } catch {
            print("Error clearing consumiciones: \(error)")
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                importError = "access_denied"
                return
            }
            
            hasSecurityAccess = true
            pendingImportURL = url
            showingImportAlert = true
            
        case .failure(let error):
            importError = error.localizedDescription
        }
    }
    
    private func processImport(mode: BebidaImporter.ImportMode) {
        guard let url = pendingImportURL else { return }
        
        print("DEBUG: Starting import with URL: \(url)")
        print("DEBUG: Import mode: \(mode == .overwrite ? "OVERWRITE" : "MERGE")")
        
        if let exportData = BebidaImporter.shared.parseExportData(from: url) {
            print("DEBUG: Parsed export data with \(exportData.bebidas.count) drinks")
            
            let context = CoreDataManager.shared.context
            
            // Check current bebidas before import
            let bebidasRequest: NSFetchRequest<Bebida> = Bebida.fetchRequest()
            let currentBebidas = (try? context.fetch(bebidasRequest)) ?? []
            print("DEBUG: Current bebidas count BEFORE import: \(currentBebidas.count)")
            
            switch mode {
            case .merge:
                BebidaImporter.shared.mergeBebidasSync(exportData.bebidas, context: context)
            case .overwrite:
                BebidaImporter.shared.overwriteBebidasSync(exportData.bebidas, context: context)
            case .cancel:
                break
            }
            
            // Check bebidas after import
            let bebidasAfter = (try? context.fetch(bebidasRequest)) ?? []
            print("DEBUG: Bebidas count AFTER import: \(bebidasAfter.count)")
            
            print("DEBUG: Import completed!")
            importSuccess = true
            let callback = self.onDismiss
            dismiss()
            callback?()
        } else {
            print("DEBUG: Failed to parse export data")
            importError = "parse_error"
        }
        
        if hasSecurityAccess, let url = pendingImportURL {
            url.stopAccessingSecurityScopedResource()
            hasSecurityAccess = false
        }
    }
}

enum TextBundle {
    case current
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
