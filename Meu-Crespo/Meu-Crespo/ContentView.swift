//
//  ContentView.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

enum Tabs{
    case home, learn
}

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection:
                    $selectedTab){
            Tab("Home", systemImage: "house", value: .home){
                HomeView()
            }
            Tab("Conteúdo", systemImage: "book.fill", value: .home){
                LearnView()
            }
        }.tint(Color(red: 0.95, green: 0.42, blue: 0.37))
        
    }
}

#Preview {
    ContentView()
}
