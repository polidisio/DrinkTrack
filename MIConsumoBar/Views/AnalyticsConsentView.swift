import SwiftUI

struct AnalyticsConsentView: View {
    let onChoice: (Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 56))
                .foregroundColor(.orange)
            Text("analytics_prompt_title").font(.title2.bold())
            Text("analytics_prompt_body")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button { onChoice(true) } label: {
                Text("analytics_accept").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button { onChoice(false) } label: {
                Text("analytics_decline").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
