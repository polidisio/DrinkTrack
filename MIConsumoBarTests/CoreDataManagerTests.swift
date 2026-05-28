import XCTest
@testable import MyBarTrack

final class CoreDataManagerTests: XCTestCase {
    let manager = CoreDataManager.shared

    override func setUp() {
        super.setUp()
        // Ensure default bebidas exist
        let bebidas = manager.fetchBebidas()
        if bebidas.isEmpty {
            manager.createDefaultBebidas()
        }
    }

    override func tearDown() {
        // Clean up all consumiciones created during tests
        let all = manager.fetchAllConsumiciones()
        for c in all {
            manager.deleteConsumicion(c)
        }
        super.tearDown()
    }

    func testFetchConsumicionesOnlyForToday() {
        let bebidas = manager.fetchBebidas()
        guard let bebida = bebidas.first, let bebidaID = bebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        // Add a consumicion today
        manager.addConsumicion(bebidaID: bebidaID, cantidad: 2, precioUnitario: 3.0)

        // Add a consumicion yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let consumicionAyer = Consumicion(context: manager.context)
        consumicionAyer.id = UUID()
        consumicionAyer.bebidaID = bebidaID
        consumicionAyer.cantidad = 5
        consumicionAyer.precioUnitario = 2.0
        consumicionAyer.timestamp = yesterday
        manager.save()

        // fetchConsumiciones(for: Date()) should return only today's
        let todayConsumiciones = manager.fetchConsumiciones(for: Date())
        XCTAssertGreaterThanOrEqual(todayConsumiciones.count, 1)
        for c in todayConsumiciones {
            guard let ts = c.timestamp else {
                XCTFail("Consumicion without timestamp")
                continue
            }
            XCTAssertTrue(Calendar.current.isDateInToday(ts), "All returned consumiciones should be from today")
        }
    }

    func testFetchConsumicionesLastDaysReturnsCorrectCount() {
        let bebidas = manager.fetchBebidas()
        guard let bebida = bebidas.first, let bebidaID = bebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        // Add consumiciones across multiple days
        for dayOffset in 0..<5 {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            let c = Consumicion(context: manager.context)
            c.id = UUID()
            c.bebidaID = bebidaID
            c.cantidad = 1
            c.precioUnitario = 1.0
            c.timestamp = date
        }
        manager.save()

        // Should return consumiciones from the last 3 days (today + 2 previous)
        let last3 = manager.fetchConsumiciones(lastDays: 3)
        XCTAssertGreaterThanOrEqual(last3.count, 3)

        // Should return all 5 when requesting 7 days
        let last7 = manager.fetchConsumiciones(lastDays: 7)
        XCTAssertGreaterThanOrEqual(last7.count, 5)
    }

    func testGetTotalSpendingSince() {
        let bebidas = manager.fetchBebidas()
        guard let bebida = bebidas.first, let bebidaID = bebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        // Add consumiciones with known prices
        manager.addConsumicion(bebidaID: bebidaID, cantidad: 2, precioUnitario: 3.0)
        manager.addConsumicion(bebidaID: bebidaID, cantidad: 1, precioUnitario: 5.0)
        // Total: 2*3 + 1*5 = 11

        let total = manager.getTotalSpending(since: Calendar.current.startOfDay(for: Date()))
        XCTAssertEqual(total, 11.0, accuracy: 0.001)
    }

    func testFetchConsumicionesLastDaysWithZeroReturnsAll() {
        // fetchConsumiciones(lastDays: 0) or negative should return all
        let allExisting = manager.fetchConsumiciones(lastDays: 0)
        let allFromMethod = manager.fetchAllConsumiciones()
        XCTAssertEqual(allExisting.count, allFromMethod.count)
    }
}

final class BebidaImporterTests: XCTestCase {
    let manager = CoreDataManager.shared
    let importer = BebidaImporter.shared

    override func setUp() {
        super.setUp()
        let bebidas = manager.fetchBebidas()
        if bebidas.isEmpty {
            manager.createDefaultBebidas()
        }
    }

    override func tearDown() {
        let all = manager.fetchAllConsumiciones()
        for c in all {
            manager.deleteConsumicion(c)
        }
        super.tearDown()
    }

    func testParseExportDataWithISO8601Dates() {
        let item = BebidaExportItem(id: UUID(), nombre: "TestDrink", emoji: "🍺", precioBase: 2.5, categoria: "Alcohol", orden: 1, cantidad: 3)
        let data = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: [item])

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let jsonData = try? encoder.encode(data) else {
            XCTFail("Failed to encode export data")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        try? jsonData.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let parsed = importer.parseExportData(from: tempURL)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.bebidas.count, 1)
        XCTAssertEqual(parsed?.bebidas[0].nombre, "TestDrink")
        XCTAssertEqual(parsed?.bebidas[0].cantidad, 3)
    }

    func testParseExportDataWithDeferredDates() {
        let item = BebidaExportItem(id: UUID(), nombre: "TestDrink2", emoji: "🥤", precioBase: 1.5, categoria: "Sin Alcohol", orden: 2, cantidad: nil)
        let data = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: [item])

        let encoder = JSONEncoder()
        // Default date encoding strategy (deferredToDate)
        guard let jsonData = try? encoder.encode(data) else {
            XCTFail("Failed to encode export data")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        try? jsonData.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // Should still parse successfully via fallback
        let parsed = importer.parseExportData(from: tempURL)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.bebidas[0].nombre, "TestDrink2")
        XCTAssertNil(parsed?.bebidas[0].cantidad)
    }

    func testParseExportDataInvalidFileReturnsNil() {
        let invalidURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        try? "not json".write(to: invalidURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: invalidURL) }

        let parsed = importer.parseExportData(from: invalidURL)
        XCTAssertNil(parsed)
    }

    func testMergeImportCreatesConsumiciones() {
        let bebidas = manager.fetchBebidas()
        guard let existingBebida = bebidas.first, let existingID = existingBebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        let importItem = BebidaExportItem(id: existingID, nombre: existingBebida.nombre ?? "", emoji: existingBebida.emoji ?? "", precioBase: existingBebida.precioBase, categoria: existingBebida.categoria ?? "", orden: existingBebida.orden, cantidad: 3)

        importer.mergeBebidasSync([importItem], context: manager.context)

        let totalQuantity = manager.fetchAllConsumiciones().reduce(0) { $0 + Int($1.cantidad) }
        XCTAssertEqual(totalQuantity, 3, "Merge should add total quantity of 3")
    }

    func testOverwriteImportReplacesAll() {
        let importItems = [
            BebidaExportItem(id: UUID(), nombre: "ImportedDrink", emoji: "🍹", precioBase: 5.0, categoria: "Alcohol", orden: 1, cantidad: 2)
        ]

        importer.overwriteBebidasSync(importItems, context: manager.context)

        let bebidasAfter = manager.fetchBebidas()
        XCTAssertEqual(bebidasAfter.count, 1)
        XCTAssertEqual(bebidasAfter.first?.nombre, "ImportedDrink")

        let totalQuantity = manager.fetchAllConsumiciones().reduce(0) { $0 + Int($1.cantidad) }
        XCTAssertEqual(totalQuantity, 2, "Overwrite should create consumicion with cantidad 2")
    }
}

final class BebidaCSVExporterTests: XCTestCase {
    let manager = CoreDataManager.shared
    let exporter = BebidaExporter.shared

    override func tearDown() {
        let all = manager.fetchAllConsumiciones()
        for c in all {
            manager.deleteConsumicion(c)
        }
        super.tearDown()
    }

    func testExportToCSVGeneratesValidContent() {
        let bebidas = manager.fetchBebidas()
        guard let bebida = bebidas.first, let bebidaID = bebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        // Add a consumicion so we have data to export
        manager.addConsumicion(bebidaID: bebidaID, cantidad: 2, precioUnitario: 3.5)

        let allConsumiciones = manager.fetchAllConsumiciones()
        var lookup: [UUID: Bebida] = [:]
        for b in bebidas {
            if let id = b.id { lookup[id] = b }
        }

        guard let csvURL = exporter.exportToCSV(consumiciones: allConsumiciones, bebidasLookup: lookup) else {
            XCTFail("CSV export returned nil")
            return
        }
        defer { try? FileManager.default.removeItem(at: csvURL) }

        guard let csvContent = try? String(contentsOf: csvURL, encoding: .utf8) else {
            XCTFail("Failed to read CSV file")
            return
        }

        XCTAssertTrue(csvContent.hasPrefix("Date,Drink,Emoji,Quantity,Unit Price,Total,Notes\n"))
        XCTAssertTrue(csvContent.contains(bebida.nombre ?? ""))
        XCTAssertTrue(csvContent.contains("2"))
        XCTAssertTrue(csvContent.contains("3.5"))
    }
}

final class ViewModelTests: XCTestCase {
    let manager = CoreDataManager.shared

    override func setUp() {
        super.setUp()
        let bebidas = manager.fetchBebidas()
        if bebidas.isEmpty {
            manager.createDefaultBebidas()
        }
    }

    override func tearDown() {
        let all = manager.fetchAllConsumiciones()
        for c in all {
            manager.deleteConsumicion(c)
        }
        super.tearDown()
    }

    func testRefreshTodayDataIncludesAllConsumiciones() {
        let viewModel = ConsumicionViewModel()
        viewModel.loadData()

        guard let bebida = viewModel.bebidas.first, let bebidaID = bebida.id else {
            XCTSkip("No bebidas available")
            return
        }

        // Add a consumicion today
        viewModel.addConsumicion(bebida: bebida, cantidad: 1, precioUnitario: 2.0)

        // Add a consumicion yesterday via CoreData directly
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let oldConsumicion = Consumicion(context: manager.context)
        oldConsumicion.id = UUID()
        oldConsumicion.bebidaID = bebidaID
        oldConsumicion.cantidad = 99
        oldConsumicion.precioUnitario = 10.0
        oldConsumicion.timestamp = yesterday
        manager.save()

        // Refresh - should INCLUDE yesterday's consumicion (counters are cumulative)
        viewModel.refreshTodayData()

        let totalCount = viewModel.getConsumicionCount(for: bebida)
        XCTAssertEqual(totalCount, 100, "Counters should show cumulative total (1 today + 99 yesterday)")
    }

    func testDecrementConsumicionRemovesMostRecent() {
        let viewModel = ConsumicionViewModel()
        viewModel.loadData()

        guard let bebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available")
            return
        }

        // Add two consumiciones with different timestamps
        viewModel.addConsumicion(bebida: bebida, cantidad: 1, precioUnitario: 2.0)

        // Manually add another with an older timestamp
        guard let bebidaID = bebida.id else { return }
        let earlier = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let oldConsumicion = Consumicion(context: manager.context)
        oldConsumicion.id = UUID()
        oldConsumicion.bebidaID = bebidaID
        oldConsumicion.cantidad = 1
        oldConsumicion.precioUnitario = 5.0
        oldConsumicion.timestamp = earlier
        manager.save()

        viewModel.refreshTodayData()

        let countBefore = viewModel.getConsumicionCount(for: bebida)
        XCTAssertEqual(countBefore, 2, "Should have 2 consumiciones total")

        // Decrement once - should remove the most recent
        viewModel.decrementConsumicion(bebida: bebida)

        let countAfter = viewModel.getConsumicionCount(for: bebida)
        XCTAssertEqual(countAfter, 1, "Should have 1 consumicion after decrement")

        // The remaining one should be the one with precioUnitario 5.0 (the older one)
        let remainingCost = viewModel.getConsumicionCost(for: bebida)
        XCTAssertEqual(remainingCost, 5.0, accuracy: 0.001, "The remaining consumicion should be the older one with price 5.0")
    }

    func testGetConsumicionCostCalculatesCorrectly() {
        let viewModel = ConsumicionViewModel()
        viewModel.loadData()

        guard let bebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available")
            return
        }

        viewModel.addConsumicion(bebida: bebida, cantidad: 3, precioUnitario: 2.5)
        viewModel.addConsumicion(bebida: bebida, cantidad: 1, precioUnitario: 4.0)

        let cost = viewModel.getConsumicionCost(for: bebida)
        XCTAssertEqual(cost, 11.5, accuracy: 0.001, "3*2.5 + 1*4.0 = 11.5")
    }
}
