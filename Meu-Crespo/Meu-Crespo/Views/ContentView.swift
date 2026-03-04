import SwiftUI

enum Tabs{
    case home, learn
}

//(Injeção de Dependência)

struct ContentView: View {
    @StateObject var weatherManager = WeatherManager()
    @State var selectedTab: Tabs = .home
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            TabView(selection:
                        $selectedTab){
                
                Tab("Home", systemImage: "house", value: .home){
                    HomeView()
                        .environmentObject(weatherManager)

                }
                Tab("Conteúdo", systemImage: "book.fill", value: .learn){
                    LearnView()
                        .environmentObject(weatherManager)

                }
               
            }.tint(Color(red: 0.95, green: 0.42, blue: 0.37))
            .opacity(showSplash ? 0 : 1)
                        
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            }

        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onChange(of: weatherManager.status) { oldValue, newValue in
            if newValue == .loaded || newValue == .failed {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
