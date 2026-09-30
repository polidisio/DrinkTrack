import SwiftUI
import WatchKit

struct WatchContentView: View {
    @EnvironmentObject private var sync: WatchSyncService

    var body: some View {
        NavigationStack {
            if let state = sync.state {
                List {
                    summary(state)
                    ForEach(state.drinks) { drink in
                        Button {
                            sync.send(.add, bebidaID: drink.id)
                            WKInterfaceDevice.current().play(.click)
                        } label: {
                            HStack {
                                Text(drink.emoji).font(.title3)
                                Spacer()
                                Text("\(drink.count)").font(.title3.bold().monospacedDigit())
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            if let id = sync.lastAddedID { sync.send(.undo, bebidaID: id) }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }
                        .disabled(sync.lastAddedID == nil)
                    }
                }
                // Aviso háptico al cruzar el presupuesto (el iPhone confirma el progreso real).
                .onChange(of: state.budgetProgress ?? 0) { old, new in
                    if old < 1, new >= 1 { WKInterfaceDevice.current().play(.notification) }
                }
            } else {
                Text("watch_empty")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func summary(_ state: WatchState) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("total_hoy").font(.caption2).foregroundStyle(.secondary)
            Text("\(state.totalCantidad)").font(.title.bold())
            Text(state.totalCoste, format: .currency(code: state.currencyCode))
                .font(.footnote).foregroundStyle(.orange)
            if let progress = state.budgetProgress {
                ProgressView(value: min(progress, 1.0))
                    .tint(progress >= 1.0 ? .red : (progress >= 0.8 ? .orange : .green))
            }
        }
    }
}
