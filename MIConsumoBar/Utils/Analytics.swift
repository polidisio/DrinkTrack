import Foundation
import PostHog

/// Wrapper fino sobre PostHog. Opt-in: nada se envía hasta que el usuario activa el consentimiento.
/// Regla: solo contadores, booleanos y categorías — nunca nombres de bebida, precios, importes ni notas.
enum Analytics {
    static let consentKey = "analyticsEnabled"
    static let promptedKey = "analyticsPrompted"

    static var isEnabled: Bool { UserDefaults.standard.bool(forKey: consentKey) }

    private static var isConfigured = false

    static func setup() {
        #if DEBUG
        if let key = Bundle.main.object(forInfoDictionaryKey: "PostHogAPIKey") as? String, !key.hasPrefix("phc_") {
            print("⚠️ Analytics desactivado: PostHogAPIKey debe ser el Project token (phc_…), no una personal API key (phx_…)")
        }
        #endif
        guard !isConfigured,
              let key = Bundle.main.object(forInfoDictionaryKey: "PostHogAPIKey") as? String,
              key.hasPrefix("phc_"), key != "phc_REPLACE_ME",
              let host = Bundle.main.object(forInfoDictionaryKey: "PostHogHost") as? String,
              !host.isEmpty
        else { return }

        let config = PostHogConfig(projectToken: key, host: "https://\(host)")
        config.captureApplicationLifecycleEvents = true
        config.captureScreenViews = false
        config.optOut = !isEnabled
        // Sin GeoIP; "Discard client IP data" es ajuste del proyecto PostHog (no del SDK).
        // `app` separa DrinkTrack de Synctrackers en el proyecto PostHog compartido.
        config.setBeforeSend { event in
            event.properties["$geoip_disable"] = true
            event.properties["app"] = "drinktrack"
            return event
        }
        PostHogSDK.shared.setup(config)
        isConfigured = true
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: consentKey)
        setup()
        guard isConfigured else { return }
        enabled ? PostHogSDK.shared.optIn() : PostHogSDK.shared.optOut()
    }

    static func track(_ event: String, _ properties: [String: Any] = [:]) {
        guard isEnabled, isConfigured else { return }
        PostHogSDK.shared.capture(event, properties: properties)
    }

    static func screen(_ name: String) {
        track("$screen", ["$screen_name": name])
    }
}
