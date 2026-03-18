import XCTest
@testable import MIConsumoBar

final class ConsumicionViewModelTests: XCTestCase {
    
    func testResetCountersRemovesAllConsumicionesForBebida() throws {
        let viewModel = ConsumicionViewModel()
        
        viewModel.loadData()
        
        guard let primeraBebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available in test environment")
            return
        }
        
        let countBefore = viewModel.getConsumicionCount(for: primeraBebida)
        
        viewModel.addConsumicion(bebida: primeraBebida, cantidad: 3)
        
        let countAfterAdd = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(countAfterAdd, countBefore + 3, "Should add 3 consumiciones")
        
        viewModel.resetCounters(for: primeraBebida)
        
        let countAfterReset = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(countAfterReset, 0, "Reset should remove all consumiciones for this bebida")
    }
    
    func testDecrementConsumicionReducesCount() throws {
        let viewModel = ConsumicionViewModel()
        
        viewModel.loadData()
        
        guard let primeraBebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available in test environment")
            return
        }
        
        viewModel.addConsumicion(bebida: primeraBebida, cantidad: 2)
        
        let countAfterAdd = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(countAfterAdd, 2, "Should have 2 consumiciones")
        
        viewModel.decrementConsumicion(bebida: primeraBebida)
        
        let countAfterDecrement = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(countAfterDecrement, 1, "Decrement should reduce count by 1")
    }
    
    func testCleanupIsDisabled() throws {
        let viewModel = ConsumicionViewModel()
        
        viewModel.loadData()
        
        guard let primeraBebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available in test environment")
            return
        }
        
        let initialCount = viewModel.getConsumicionCount(for: primeraBebida)
        
        if initialCount > 0 {
            viewModel.resetCounters(for: primeraBebida)
            let countAfterReset = viewModel.getConsumicionCount(for: primeraBebida)
            XCTAssertEqual(countAfterReset, 0, "After reset, count should be 0")
            
            viewModel.loadData()
            
            let countAfterReload = viewModel.getConsumicionCount(for: primeraBebida)
            XCTAssertEqual(countAfterReload, 0, "After reload, count should still be 0 (no automatic cleanup)")
        } else {
            viewModel.addConsumicion(bebida: primeraBebida, cantidad: 1)
            
            viewModel.loadData()
            
            let countAfterReload = viewModel.getConsumicionCount(for: primeraBebida)
            XCTAssertEqual(countAfterReload, 1, "Consumiciones should persist after reload - NO automatic cleanup")
        }
    }
    
    func testConsumicionesPersistUntilManuallyReset() throws {
        let viewModel = ConsumicionViewModel()
        
        viewModel.loadData()
        
        guard let primeraBebida = viewModel.bebidas.first else {
            XCTSkip("No bebidas available in test environment")
            return
        }
        
        let initialCount = viewModel.getConsumicionCount(for: primeraBebida)
        
        viewModel.addConsumicion(bebida: primeraBebida, cantidad: 5)
        
        var currentCount = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(currentCount, initialCount + 5)
        
        for _ in 0..<5 {
            viewModel.decrementConsumicion(bebida: primeraBebida)
        }
        
        currentCount = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(currentCount, initialCount, "All manually added consumiciones should be removed")
        
        viewModel.loadData()
        
        currentCount = viewModel.getConsumicionCount(for: primeraBebida)
        XCTAssertEqual(currentCount, initialCount, "Count should persist after reload - manual reset only")
    }
}
