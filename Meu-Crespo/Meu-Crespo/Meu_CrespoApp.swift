import SwiftUI

@main
struct Meu_CrespoApp: App {
    @StateObject var weatherManager = WeatherManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherManager)
        }
    }
}
