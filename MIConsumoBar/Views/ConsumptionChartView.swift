import SwiftUI
import Charts

struct DailyConsumption: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let hasAlcohol: Bool
    
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}

struct TypeConsumption: Identifiable {
    let id = UUID()
    let nombre: String
    let emoji: String
    let count: Int
}

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
    
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}

struct ConsumptionChartView: View {
    let consumiciones: [Consumicion]
    let bebidas: [Bebida]
    
    private var dailyData: [DailyConsumption] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayConsumiciones = filterConsumiciones(for: date)
            let hasAlcohol = dayConsumiciones.contains { consumicion in
                guard let bebida = bebidas.first(where: { $0.id == consumicion.bebidaID }) else { return false }
                return bebida.categoria == "Alcohol"
            }
            
            return DailyConsumption(
                date: date,
                count: dayConsumiciones.reduce(0) { $0 + Int($1.cantidad) },
                hasAlcohol: hasAlcohol
            )
        }.reversed()
    }
    
    private var typeData: [TypeConsumption] {
        let lastWeekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let lastWeekConsumiciones = consumiciones.filter { ($0.timestamp ?? Date()) >= lastWeekStart }
        
        return bebidas.map { bebida in
            let count = lastWeekConsumiciones
                .filter { $0.bebidaID == bebida.id }
                .reduce(0) { $0 + Int($1.cantidad) }
            
            return TypeConsumption(
                nombre: CoreDataManager.shared.localizedNombre(for: bebida.nombre ?? ""),
                emoji: bebida.emoji ?? "",
                count: count
            )
        }.filter { $0.count > 0 }.sorted { $0.count > $1.count }
    }
    
    private var spendingData: [DailySpending] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayConsumiciones = filterConsumiciones(for: date)
            let total = dayConsumiciones.reduce(0.0) {
                $0 + (Double($1.cantidad) * $1.precioUnitario)
            }
            
            return DailySpending(date: date, total: total)
        }.reversed()
    }
    
    private var totalConsumption: Int {
        dailyData.reduce(0) { $0 + $1.count }
    }
    
    private var totalSpending: Double {
        spendingData.reduce(0) { $0 + $1.total }
    }
    
    private var currencySymbol: String {
        Locale.current.currencySymbol ?? "€"
    }
    
    private func filterConsumiciones(for date: Date) -> [Consumicion] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        return consumiciones.filter { consumicion in
            guard let timestamp = consumicion.timestamp else { return false }
            return timestamp >= startOfDay && timestamp < endOfDay
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if dailyData.allSatisfy({ $0.count == 0 }) && typeData.isEmpty {
                emptyStateView
            } else {
                summaryView
                
                if !dailyData.isEmpty {
                    dailyConsumptionChart
                }
                
                if !typeData.isEmpty {
                    typeConsumptionChart
                }
                
                if !spendingData.isEmpty {
                    spendingChart
                }
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("chart_no_data")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var summaryView: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "chart_total_drinks",
                value: "\(totalConsumption)",
                icon: "cup.and.saucer.fill",
                color: .orange
            )
            
            SummaryCard(
                title: "chart_total_spending",
                value: String(format: "%.2f \(currencySymbol)", totalSpending),
                icon: "dollarsign.circle.fill",
                color: .green
            )
        }
    }
    
    private var dailyConsumptionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("chart_daily_consumption")
                .font(.headline)
            
            Chart(dailyData) { day in
                BarMark(
                    x: .value("chart_quantity", day.count),
                    y: .value("chart_day", day.shortDayName)
                )
                .foregroundStyle(day.hasAlcohol ? Color.orange : Color.blue)
            }
            .frame(height: CGFloat(dailyData.count * 40))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var typeConsumptionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("chart_by_type")
                .font(.headline)
            
            if typeData.isEmpty {
                Text("chart_no_drinks_yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            } else {
                Chart(typeData) { type in
                    BarMark(
                        x: .value("chart_quantity", type.count),
                        y: .value("chart_drink", type.emoji + " " + type.nombre)
                    )
                    .foregroundStyle(Color.orange.gradient)
                }
                .frame(height: CGFloat(typeData.count * 40))
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("chart_spending")
                .font(.headline)
            
            Chart(spendingData) { day in
                BarMark(
                    x: .value("chart_day", day.shortDayName),
                    y: .value("chart_amount", day.total)
                )
                .foregroundStyle(Color.green.gradient)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(String(format: "%.1f \(currencySymbol)", amount))
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}
