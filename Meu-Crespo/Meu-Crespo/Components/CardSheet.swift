//
//  CardSheet.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

struct CardSheet: View{
    @State private var showingSheet = false
    
    var body: some View{
        Button() {
            showingSheet.toggle()
        }label:{
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 323, height: 105)
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.25), radius: 1.83003, x: 0, y: 3.66006)
                
                HStack(spacing:30){
                    Image("garfo")
                        .rotationEffect(Angle(degrees: -123))
                        .padding(.trailing, 10)
                    Text("Penteados")
                        .font(.system(size: 17)).bold()
                        .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                }
                
            }
            .frame(width: 105, height: 105)
        }.sheet(isPresented: $showingSheet) {
            SheetView()
        }
    }
}
struct SheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button() {
            dismiss()
        }label:{
            HStack(alignment: .center, spacing: 11.70149) {
                Text("Saia por aqui")
            }
            .padding(.horizontal, 3.9005)
            .padding(.vertical, 0)
            .frame(height: 42.90547, alignment: .center)
            .cornerRadius(288.63681)
        }
    }
}

#Preview {
    CardSheet()
}
