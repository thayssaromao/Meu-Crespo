//
//  LearnView.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

struct LearnView: View {
    @State var nome: String = "Fulano"
    var body: some View {
        VStack(spacing: 24){
            Text("Olá,\(nome)!")
                .font(.system(size:30, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 342, alignment: .topLeading)
            
            Text("aqui blabla bla explicaçao blabla bla aqui blabla bla explicaçao blabla blaaqui blabla bla explicaçao blabla bla")
              .font(Font.custom("SF Pro", size: 18))
              .foregroundColor(.black)
              .frame(width: 342, alignment: .topLeading)
            
            VStack(spacing:20){
                CardInfo()
                CardInfo()
                CardInfo()
                CardInfo()
            }.padding(.top,60)
        }
            
    }
}

#Preview {
    LearnView()
}
