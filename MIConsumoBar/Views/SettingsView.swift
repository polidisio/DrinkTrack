import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("retentionDays") private var retentionDays: Int = 0
    
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
        }
    }
    
    private func localizedRetention(key: String, days: Int) -> String {
        if days == 0 {
            return NSLocalizedString("retention_indefinite", comment: "")
        } else {
            return String(format: NSLocalizedString("retention_days", comment: ""), days)
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
