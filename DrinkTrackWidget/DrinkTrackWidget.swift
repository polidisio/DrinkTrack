import WidgetKit
import SwiftUI

struct DrinkTrackEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct DrinkTrackTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DrinkTrackEntry {
        DrinkTrackEntry(date: Date(), snapshot: WidgetSnapshot(totalCantidad: 3, totalCoste: 12.5, currencyCode: "EUR", budgetProgress: 0.4))
    }

    func getSnapshot(in context: Context, completion: @escaping (DrinkTrackEntry) -> Void) {
        completion(DrinkTrackEntry(date: Date(), snapshot: WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DrinkTrackEntry>) -> Void) {
        let entry = DrinkTrackEntry(date: Date(), snapshot: WidgetSnapshot.load())
        // The app pushes a fresh snapshot + WidgetCenter.reloadAllTimelines() on every
        // counter change, so no periodic refresh policy is needed here.
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct DrinkTrackWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DrinkTrackEntry

    var body: some View {
        if let snapshot = entry.snapshot {
            VStack(alignment: .leading, spacing: 6) {
                Text("total_hoy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(snapshot.totalCantidad)")
                    .font(.system(size: 34, weight: .bold))
                Text(snapshot.totalCoste, format: .currency(code: snapshot.currencyCode))
                    .font(.headline)
                    .foregroundColor(.orange)

                if family == .systemMedium, let progress = snapshot.budgetProgress {
                    Spacer(minLength: 4)
                    ProgressView(value: min(progress, 1.0), total: 1.0)
                        .tint(progress >= 1.0 ? .red : (progress >= 0.8 ? .orange : .green))
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            Text("total_hoy")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

struct DrinkTrackWidget: Widget {
    let kind: String = "DrinkTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DrinkTrackTimelineProvider()) { entry in
            DrinkTrackWidgetView(entry: entry)
        }
        .configurationDisplayName("DrinkTrack")
        .description("Muestra tu contador y gasto acumulado")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
