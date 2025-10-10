//
//  ContentView.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

enum Tabs{
    case home, learn, teste
}

//(Injeção de Dependência)

struct ContentView: View {
    @StateObject var weatherManager = WeatherManager()
    @State var selectedTab: Tabs = .home
    
    var body: some View {
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
            Tab("teste", systemImage: "book.fill", value: .teste){
                WeatherInfoView()
                    .environmentObject(weatherManager)
            }
        }.tint(Color(red: 0.95, green: 0.42, blue: 0.37))
        
    }
}

#Preview {
    ContentView()
}
