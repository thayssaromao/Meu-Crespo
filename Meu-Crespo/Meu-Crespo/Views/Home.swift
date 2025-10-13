//
//  Home.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//
import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var preferredScheme: ColorScheme? = nil
    @StateObject private var weatherManager = WeatherManager() // ✅ adiciona aqui

    var body: some View {
        NavigationStack {
            VStack(spacing:30){
                VStack(spacing:30){
                    WeekSlider()
                    CardHead()
                }.padding(.top,200)
                    .padding(.bottom,10)
                
                VStack(alignment:.leading){
                    Text("Recomendações")
                        .bold()
                        .font(.system(size: 28))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.32, green: 0.13, blue: 0.02) : .primary)
                        .padding(.leading,25)
                    
                    ZStack{
                        Image("bgRecomendacao")
                        
                            CardListView()
                                .padding(.bottom,200)
                    }
                }
                
            }.ignoresSafeArea()
            // The .toolbar modifier must be applied to the content *inside* the NavigationStack
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Menu {
//                        Button("Automático") { preferredScheme = nil }
//                        Button("Claro") { preferredScheme = .light }
//                        Button("Escuro") { preferredScheme = .dark }
//                    } label: {
//                        Label("Tema", systemImage: "circle.lefthalf.filled")
//                    }
//                }
//            }
        }
        .preferredColorScheme(.light)
    }
}
#Preview {
    ContentView()
}
