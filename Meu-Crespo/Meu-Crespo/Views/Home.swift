//
//  Home.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing:20){
          
            VStack(spacing:40){
                WeekSlider()
                CardHead()
            }.padding(.top,90)
            VStack(alignment:.leading){
                Text("Recomendações")
                    .bold()
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                    .padding(.leading,25)

                ZStack{
                    Image("bgRecomendacao")
                    VStack(spacing:27){
                        CardSheet()
                        CardSheet()
                        CardSheet()

                    }.frame(maxWidth: .infinity) // expanda-se horizontalmente para preencher todo o espaço que seu pai (VStack principal) lhe der
                        .padding(.bottom,65)
                }
            }.padding(.top,20)
                
        }.ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
