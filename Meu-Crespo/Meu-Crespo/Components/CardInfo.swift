//
//  CardInfo.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 09/10/25.
//

import SwiftUI

struct CardInfo: View {
    @State private var showingSheet = false
    @State private var assunto: String = "O que é Umectação?"

        var body: some View{
            Button() {
                showingSheet.toggle()
            }label:{
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 360, height: 88)
                      .background(
                        Image("cardInfoBg")
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 360, height: 88)
                          .clipped()
                      )
                      .cornerRadius(8)
                    
                    
                    HStack(alignment:.center){
                            Text(assunto)
                        Spacer()
                            Image(systemName: "chevron.right")
                        }.frame(width: 301)
                        .font(.system(size: 18).bold())
                          .foregroundColor(.black)
                        
                    
                    
                }
                .frame(width: 350)
            }.sheet(isPresented: $showingSheet) {
                SheetView()
            }
    }
}

#Preview {
    LearnView()
}
