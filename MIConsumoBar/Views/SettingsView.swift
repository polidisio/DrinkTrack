import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("retentionDays") private var retentionDays: Int = 0
    @State private var showingClearAlert = false
    
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
}

enum TextBundle {
    case current
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
