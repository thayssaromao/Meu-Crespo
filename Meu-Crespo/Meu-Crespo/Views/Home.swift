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
    
    var body: some View {
        // Wrap the main content in a NavigationStack
        NavigationStack {
            VStack(spacing:20){
                
                VStack(spacing:40){
                    WeekSlider()
                    CardHead()
                }.padding(.top,90)
                VStack(alignment:.leading){
                    Text("Recomendações")
                        .bold()
                        .font(.system(size: 28))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.32, green: 0.13, blue: 0.02) : .primary)
                        .padding(.leading,25)
                    
                    ZStack{
                        Image("bgRecomendacao")
                        VStack(spacing:20){
                            CardSheet()
                            CardSheet()
                            CardSheet()
                            
                        }.frame(maxWidth: .infinity)
                            .padding(.bottom,80)
                    }
                }.padding(.top,10)
                
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
        } // End of NavigationStack
        // Apply the color scheme modifier to the entire stack if you want it to affect all children
        .preferredColorScheme(.light)
    }
}
#Preview {
    ContentView()
}
