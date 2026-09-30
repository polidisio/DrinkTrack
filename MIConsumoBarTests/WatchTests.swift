import XCTest
@testable import MyBarTrack

final class WatchTests: XCTestCase {

    func testStateRoundTrip() throws {
        let state = WatchState(
            drinks: [.init(id: UUID(), emoji: "🍺", count: 3)],
            totalCantidad: 3, totalCoste: 10.5, currencyCode: "EUR", budgetProgress: 0.4
        )
        let decoded = try JSONDecoder().decode(WatchState.self, from: JSONEncoder().encode(state))
        XCTAssertEqual(decoded, state)
    }

    func testCommandRoundTripKeepsIdAndKind() throws {
        let command = WatchCommand(kind: .undo, bebidaID: UUID())
        let decoded = try JSONDecoder().decode(WatchCommand.self, from: JSONEncoder().encode(command))
        XCTAssertEqual(decoded, command)
    }

    func testMarkProcessedRejectsDuplicatesAndCapsMemory() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "WatchTests-\(UUID().uuidString)"))
        let id = UUID()
        XCTAssertTrue(WatchBridge.markProcessed(id, defaults: defaults))
        XCTAssertFalse(WatchBridge.markProcessed(id, defaults: defaults))

        for _ in 0..<600 { _ = WatchBridge.markProcessed(UUID(), defaults: defaults) }
        XCTAssertLessThanOrEqual(defaults.stringArray(forKey: "watchProcessedCommands")?.count ?? 0, 500)
    }
}
