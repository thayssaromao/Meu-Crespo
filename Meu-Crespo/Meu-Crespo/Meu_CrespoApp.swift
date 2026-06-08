import SwiftUI
import PostHog

private func migrateStandardToSharedIfNeeded() {
    let standard = UserDefaults.standard
    let shared = SharedDefaults.store

    // Already migrated
    guard (shared.string(forKey: "hairPorosity") ?? "").isEmpty else { return }

    let stringKeys = ["hairPorosity", "hairDryness", "userName"]
    let intKeys    = ["washFrequency"]
    let boolKeys   = ["hasChemical"]
    let objectKeys = ["customTreatments_v2", "customRestDays_v1"]
    let doubleKeys = ["scheduleAnchorDate"]

    for key in stringKeys  { if let v = standard.string(forKey: key)  { shared.set(v, forKey: key) } }
    for key in intKeys     { let v = standard.integer(forKey: key); if v != 0 { shared.set(v, forKey: key) } }
    for key in boolKeys    { if standard.object(forKey: key) != nil  { shared.set(standard.bool(forKey: key), forKey: key) } }
    for key in objectKeys  { if let v = standard.object(forKey: key)  { shared.set(v, forKey: key) } }
    for key in doubleKeys  { let v = standard.double(forKey: key); if v != 0 { shared.set(v, forKey: key) } }
}

@main
struct Meu_CrespoApp: App {
    @StateObject var weatherManager = WeatherManager()
    @StateObject var languageManager = LanguageManager.shared

    init() {
        let info = Bundle.main.infoDictionary
        let token = info?["POSTHOG_PROJECT_TOKEN"] as? String ?? ""
        let host = info?["POSTHOG_HOST"] as? String ?? "https://us.i.posthog.com"
        let config = PostHogConfig(projectToken: token, host: host)
        config.captureApplicationLifecycleEvents = true
        config.sessionReplay = true
        config.sessionReplayConfig.maskAllTextInputs = true
        config.sessionReplayConfig.maskAllImages = false
        PostHogSDK.shared.setup(config)

        migrateStandardToSharedIfNeeded()
        LanguageManager.migrateIfNeeded()

        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            let ud = SharedDefaults.store
            PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: [
                "name": ud.string(forKey: "userName") ?? "",
                "hair_porosity": ud.string(forKey: "hairPorosity") ?? "",
                "hair_dryness": ud.string(forKey: "hairDryness") ?? "",
                "wash_frequency": ud.integer(forKey: "washFrequency"),
                "has_chemical_treatment": ud.bool(forKey: "hasChemical"),
            ])
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherManager)
                .environmentObject(languageManager)
        }
    }
}
