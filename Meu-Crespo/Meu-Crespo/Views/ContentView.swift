import SwiftUI
import PostHog
import StoreKit

enum Tabs {
    case home, timeline
}

struct ContentView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("appearanceMode") private var storedAppearance: String = AppearanceMode.system.rawValue
    @AppStorage("timelineVisitCount") private var timelineVisitCount: Int = 0
    @Environment(\.requestReview) private var requestReview
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
                        HomeView()
                            .environmentObject(weatherManager)
                            .tabItem { Label(L("tab.home"), systemImage: "house") }
                            .tag(Tabs.home)

                        TimelineView()
                            .environmentObject(weatherManager)
                            .tabItem { Label(L("tab.timeline"), systemImage: "calendar") }
                            .tag(Tabs.timeline)

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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSplash = false
            }
            if hasCompletedOnboarding {
                weatherManager.start()
                NotificationManager.shared.requestPermissionIfNeeded(thenSchedule: true)
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            if newValue {
                weatherManager.start()
                NotificationManager.shared.requestPermissionIfNeeded(thenSchedule: true)
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            let tabName: String
            switch newTab {
            case .home: tabName = "home"
            case .timeline: tabName = "timeline"
            }
            PostHogSDK.shared.capture("tab_viewed", properties: ["tab": tabName])

            if newTab == .timeline {
                timelineVisitCount += 1
                if timelineVisitCount == 3 {
                    requestReview()
                }
            }
        }
        .onChange(of: languageManager.currentLanguage) { _, _ in
            // Reschedule only if already authorized — checks auth before touching UNUserNotificationCenter
            NotificationManager.shared.scheduleIfAuthorized()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WeatherManager())
        .environmentObject(LanguageManager.shared)
}
