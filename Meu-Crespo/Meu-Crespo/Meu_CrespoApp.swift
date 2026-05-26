import SwiftUI

@main
struct Meu_CrespoApp: App {
    @StateObject var weatherManager = WeatherManager()
    @StateObject var languageManager = LanguageManager.shared

    init() {
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
