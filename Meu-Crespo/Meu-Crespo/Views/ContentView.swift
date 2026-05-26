import SwiftUI
import PostHog

enum Tabs {
    case home, timeline, learn, settings
}

struct ContentView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("appearanceMode") private var storedAppearance: String = AppearanceMode.system.rawValue
    @State var selectedTab: Tabs = .home

    private var preferredScheme: ColorScheme? {
        AppearanceMode(rawValue: storedAppearance)?.colorScheme
    }
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var body: some View {
        ZStack {
            Group {
                if hasCompletedOnboarding {
                    TabView(selection: $selectedTab) {

                        Tab(L("tab.home"), systemImage: "house", value: .home) {
                            HomeView()
                                .environmentObject(weatherManager)
                        }

                        Tab(L("tab.timeline"), systemImage: "calendar", value: .timeline) {
                            TimelineView()
                                .environmentObject(weatherManager)
                        }

                        Tab(L("tab.settings"), systemImage: "gearshape.fill", value: .settings) {
                            SettingsView()
                        }

                    }
                    .tint(Color(red: 0.95, green: 0.42, blue: 0.37))
                    .id(languageManager.currentLanguage)

                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(preferredScheme)
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onChange(of: selectedTab) { _, newTab in
            let tabName: String
            switch newTab {
            case .home: tabName = "home"
            case .timeline: tabName = "timeline"
            case .learn: tabName = "learn"
            case .settings: tabName = "settings"
            }
            PostHogSDK.shared.capture("tab_viewed", properties: ["tab": tabName])
        }
        .onChange(of: languageManager.currentLanguage) { _, _ in
            NotificationManager.shared.scheduleDailyNotification()
            if weatherManager.status == .loaded {
                let treatment = TimelineViewModel().treatmentForDay(Date())
                NotificationManager.shared.scheduleSmartDailyNotification(
                    treatment: treatment.localizedLabel,
                    humidity: weatherManager.humidity
                )
            }
        }
        .onChange(of: weatherManager.status) { _, newValue in
            if newValue == .loaded {
                let treatment = TimelineViewModel().treatmentForDay(Date())
                NotificationManager.shared.scheduleSmartDailyNotification(
                    treatment: treatment.localizedLabel,
                    humidity: weatherManager.humidity
                )
            }
            if newValue == .loaded || newValue == .failed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WeatherManager())
        .environmentObject(LanguageManager.shared)
}
