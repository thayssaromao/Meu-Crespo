import SwiftUI
import PostHog

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

        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            let ud = UserDefaults.standard
            PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: [
                "name": ud.string(forKey: "userName") ?? "",
                "hair_porosity": ud.string(forKey: "hairPorosity") ?? "",
                "hair_dryness": ud.string(forKey: "hairDryness") ?? "",
                "wash_frequency": ud.integer(forKey: "washFrequency"),
                "has_chemical_treatment": ud.bool(forKey: "hasChemical"),
            ])
        }

        LanguageManager.migrateIfNeeded()
        NotificationManager.shared.requestPermissionIfNeeded(thenSchedule: true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherManager)
                .environmentObject(languageManager)
        }
    }
}
