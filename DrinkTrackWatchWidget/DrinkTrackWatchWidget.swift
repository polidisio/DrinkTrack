import WidgetKit
import SwiftUI

struct WatchEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct WatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchEntry {
        WatchEntry(date: Date(), snapshot: WidgetSnapshot(totalCantidad: 3, totalCoste: 12.5, currencyCode: "EUR", budgetProgress: 0.4))
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchEntry) -> Void) {
        completion(WatchEntry(date: Date(), snapshot: WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchEntry>) -> Void) {
        // La app del Watch guarda el snapshot y recarga las timelines al recibir el estado del iPhone.
        completion(Timeline(entries: [WatchEntry(date: Date(), snapshot: WidgetSnapshot.load())], policy: .never))
    }
}

struct WatchComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchEntry

    private var count: Int { entry.snapshot?.totalCantidad ?? 0 }
    private var progress: Double { min(entry.snapshot?.budgetProgress ?? 0, 1) }

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: progress) {
                Image(systemName: "wineglass")
            } currentValueLabel: {
                Text("\(count)")
            }
            .gaugeStyle(.accessoryCircular)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Label("\(count)", systemImage: "wineglass").font(.headline)
                if let snapshot = entry.snapshot {
                    Text(snapshot.totalCoste, format: .currency(code: snapshot.currencyCode))
                    if snapshot.budgetProgress != nil { ProgressView(value: progress) }
                }
            }
        case .accessoryInline:
            Text("\(count) 🍺")
        default:
            Text("\(count)")
        }
    }
}

@main
struct DrinkTrackWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DrinkTrackWatchWidget", provider: WatchProvider()) { entry in
            WatchComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("MyBarTrack")
        .description("Contador y progreso del presupuesto")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
