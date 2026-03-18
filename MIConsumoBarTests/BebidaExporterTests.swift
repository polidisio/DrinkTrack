import XCTest
@testable import MIConsumoBar

final class BebidaExporterTests: XCTestCase {
    
    func testExportGeneratesValidJSON() throws {
        let exportItem = BebidaExportItem(
            id: UUID(),
            nombre: "Cerveza",
            emoji: "🍺",
            precioBase: 3.5,
            categoria: "Alcohol",
            orden: 1,
            cantidad: 5
        )
        
        let exportData = BebidaExportData(
            version: "1.0",
            exportDate: Date(),
            bebidas: [exportItem]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try encoder.encode(exportData)
        
        XCTAssertNotNil(jsonData)
        XCTAssertGreaterThan(jsonData.count, 0)
        
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("Cerveza"))
        XCTAssertTrue(jsonString!.contains("3.5"))
    }
    
    func testExportWithMultipleBebidas() throws {
        let bebidas = [
            BebidaExportItem(id: UUID(), nombre: "Cerveza", emoji: "🍺", precioBase: 3.5, categoria: "Alcohol", orden: 1, cantidad: 5),
            BebidaExportItem(id: UUID(), nombre: "Refresco", emoji: "🥤", precioBase: 2.0, categoria: "Sin Alcohol", orden: 2, cantidad: 3),
            BebidaExportItem(id: UUID(), nombre: "Agua", emoji: "💧", precioBase: 1.5, categoria: "Sin Alcohol", orden: 3, cantidad: nil)
        ]
        
        let exportData = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: bebidas)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertEqual(decoded.version, "1.0")
        XCTAssertEqual(decoded.bebidas.count, 3)
        XCTAssertEqual(decoded.bebidas[0].nombre, "Cerveza")
        XCTAssertEqual(decoded.bebidas[1].nombre, "Refresco")
        XCTAssertEqual(decoded.bebidas[2].nombre, "Agua")
    }
    
    func testExportWithNilCantidad() throws {
        let exportItem = BebidaExportItem(
            id: UUID(),
            nombre: "Test",
            emoji: "🍺",
            precioBase: 3.0,
            categoria: "Alcohol",
            orden: 1,
            cantidad: nil
        )
        
        let exportData = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: [exportItem])
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertNil(decoded.bebidas[0].cantidad)
    }
    
    func testExportDateIsISO8601() throws {
        let exportData = BebidaExportData(
            version: "1.0",
            exportDate: Date(),
            bebidas: []
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        XCTAssertTrue(jsonString.contains("exportDate"))
        XCTAssertTrue(jsonString.contains("202") || jsonString.contains("+"))
    }
    
    func testEmptyBebidasArray() throws {
        let exportData = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: [])
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertEqual(decoded.bebidas.count, 0)
        XCTAssertEqual(decoded.version, "1.0")
    }
}
