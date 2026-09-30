import Foundation
import WatchConnectivity
#if os(watchOS)
import WidgetKit
#endif

/// WatchConnectivity compartido. iPhone = fuente de verdad:
/// - iPhone → Watch: `updateApplicationContext` (gana el último estado).
/// - Watch → iPhone: `transferUserInfo` (cola fiable, también sin conexión).
final class WatchSyncService: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSyncService()

    private static let stateKey = "state"
    private static let commandKey = "command"

    #if os(watchOS)
    @Published private(set) var state: WatchState?
    /// Última bebida tocada en este reloj; objetivo del "deshacer".
    @Published private(set) var lastAddedID: UUID?
    #else
    var onCommand: ((WatchCommand) -> Void)?
    /// El estado que se mandó antes de activar la sesión se pierde: se reenvía al activarse o cambiar el reloj.
    var onNeedsState: (() -> Void)?
    #endif

    private override init() { super.init() }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        #if os(watchOS)
        receive(session.receivedApplicationContext)
        #else
        onNeedsState?()
        #endif
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    func sessionWatchStateDidChange(_ session: WCSession) { onNeedsState?() }

    func push(_ state: WatchState) {
        let session = WCSession.default
        guard WCSession.isSupported(), session.activationState == .activated,
              session.isPaired, session.isWatchAppInstalled,
              let data = try? JSONEncoder().encode(state) else { return }
        try? session.updateApplicationContext([Self.stateKey: data])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo[Self.commandKey] as? Data,
              let command = try? JSONDecoder().decode(WatchCommand.self, from: data) else { return }
        onCommand?(command)
    }
    #else
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        receive(applicationContext)
    }

    /// Envía el comando y refleja el cambio al instante; el iPhone confirma después con el estado real.
    func send(_ kind: WatchCommand.Kind, bebidaID: UUID) {
        guard let data = try? JSONEncoder().encode(WatchCommand(kind: kind, bebidaID: bebidaID)) else { return }
        WCSession.default.transferUserInfo([Self.commandKey: data])
        applyLocally(kind, bebidaID: bebidaID)
    }

    private func receive(_ context: [String: Any]) {
        guard let data = context[Self.stateKey] as? Data,
              let state = try? JSONDecoder().decode(WatchState.self, from: data) else { return }
        DispatchQueue.main.async {
            self.state = state
            WidgetSnapshot(totalCantidad: state.totalCantidad, totalCoste: state.totalCoste,
                           currencyCode: state.currencyCode, budgetProgress: state.budgetProgress).save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func applyLocally(_ kind: WatchCommand.Kind, bebidaID: UUID) {
        DispatchQueue.main.async {
            guard var state = self.state, let i = state.drinks.firstIndex(where: { $0.id == bebidaID }) else { return }
            let delta = kind == .add ? 1 : -1
            guard state.drinks[i].count + delta >= 0 else { return }
            state.drinks[i].count += delta
            state.totalCantidad += delta
            self.state = state
            self.lastAddedID = kind == .add ? bebidaID : nil
        }
    }
    #endif
}
