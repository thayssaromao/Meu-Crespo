import SwiftUI

enum Tabs{
    case home, timeline, learn
}

struct ContentView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @State var selectedTab: Tabs = .home
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if hasCompletedOnboarding {
                    TabView(selection:
                                $selectedTab){
                        
                        Tab("Início", systemImage: "house", value: .home){
                            HomeView()
                                .environmentObject(weatherManager)
                            
                        }
                        
                        Tab("Cronograma", systemImage: "calendar", value: .timeline){
                            TimelineView()
                            
                        }
                        
                        Tab("Conteúdo", systemImage: "book.fill", value: .learn){
                            LearnView()
                                .environmentObject(weatherManager)
                            
                        }
                        
                    }.tint(Color(red: 0.95, green: 0.42, blue: 0.37))
                    
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
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onChange(of: weatherManager.status) { oldValue, newValue in
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
}
