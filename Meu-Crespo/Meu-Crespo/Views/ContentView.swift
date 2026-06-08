import SwiftUI
import PostHog
import StoreKit

enum Tabs {
    case home, timeline
}

struct ContentView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("timelineVisitCount") private var timelineVisitCount: Int = 0
    @Environment(\.requestReview) private var requestReview
    @State var selectedTab: Tabs = .home
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
        .preferredColorScheme(.light)
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
            NotificationManager.shared.scheduleIfAuthorized()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WeatherManager())
        .environmentObject(LanguageManager.shared)
}
