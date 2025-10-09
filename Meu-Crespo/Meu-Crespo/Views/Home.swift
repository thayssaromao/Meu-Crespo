//
//  Home.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment:.leading ,spacing:30){
            CardHead()
            
            Text("Recomendações")
                .bold()
                .font(.system(size: 26))
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .padding(.leading,25)

            VStack(spacing:27){
                CardSheet()
                CardSheet()
                CardSheet()

            }.frame(maxWidth: .infinity) // expanda-se horizontalmente para preencher todo o espaço que seu pai (VStack principal) lhe der
        }
    }
}

#Preview {
    HomeView()
}
