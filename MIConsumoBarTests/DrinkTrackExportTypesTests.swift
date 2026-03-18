import XCTest
@testable import MyBarTrack

final class DrinkTrackExportTypesTests: XCTestCase {
    
    func testBebidaExportDataCodable() throws {
        let exportItem = BebidaExportItem(
            id: UUID(),
            nombre: "Cerveza",
            emoji: "🍺",
            precioBase: 3.5,
            categoria: "Alcohol",
            orden: 1,
            cantidad: 2
        )
        
        let exportData = BebidaExportData(
            version: "1.0",
            exportDate: Date(),
            bebidas: [exportItem]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertEqual(decoded.version, "1.0")
        XCTAssertEqual(decoded.bebidas.count, 1)
        XCTAssertEqual(decoded.bebidas[0].nombre, "Cerveza")
        XCTAssertEqual(decoded.bebidas[0].emoji, "🍺")
        XCTAssertEqual(decoded.bebidas[0].precioBase, 3.5)
        XCTAssertEqual(decoded.bebidas[0].categoria, "Alcohol")
        XCTAssertEqual(decoded.bebidas[0].orden, 1)
        XCTAssertEqual(decoded.bebidas[0].cantidad, 2)
    }
    
    func testBebidaExportItemWithoutCantidad() throws {
        let exportItem = BebidaExportItem(
            id: UUID(),
            nombre: "Agua",
            emoji: "💧",
            precioBase: 1.5,
            categoria: "Sin Alcohol",
            orden: 3,
            cantidad: nil
        )
        
        let exportData = BebidaExportData(
            version: "1.0",
            exportDate: Date(),
            bebidas: [exportItem]
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertNil(decoded.bebidas[0].cantidad)
    }
    
    func testMultipleBebidasExport() throws {
        let bebidas = [
            BebidaExportItem(id: UUID(), nombre: "Cerveza", emoji: "🍺", precioBase: 3.5, categoria: "Alcohol", orden: 1, cantidad: 5),
            BebidaExportItem(id: UUID(), nombre: "Refresco", emoji: "🥤", precioBase: 2.0, categoria: "Sin Alcohol", orden: 2, cantidad: 3),
            BebidaExportItem(id: UUID(), nombre: "Vino", emoji: "🍷", precioBase: 4.0, categoria: "Alcohol", orden: 3, cantidad: nil)
        ]
        
        let exportData = BebidaExportData(version: "1.0", exportDate: Date(), bebidas: bebidas)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(exportData)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(BebidaExportData.self, from: jsonData)
        
        XCTAssertEqual(decoded.bebidas.count, 3)
        XCTAssertEqual(decoded.bebidas[0].cantidad, 5)
        XCTAssertEqual(decoded.bebidas[1].cantidad, 3)
        XCTAssertNil(decoded.bebidas[2].cantidad)
    }
}
