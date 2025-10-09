//
//  CardWheather.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

struct CardWheather: View {
    var cardName: String
    var isTemp: Bool = false
    var isWeather: Bool = false
    var isUv: Bool = false
    
    var body: some View {
        ZStack {
            
            Image(cardName)
                .frame(width: 115, height: 115)
            VStack(alignment: .center, spacing: 10) {

                if(isTemp){
                    Temp()
                }
                if(isWeather){
                    Weather()
                }
                if(isUv){
                    Uv()
                }
            }
        }
        .frame(width: 115, height: 115)
    }
}

struct Uv: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Moderado")
                .font(.system(size:18)).bold()
                .multilineTextAlignment(.center)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(width: 100)
            
            Image(systemName: "sun.max.fill")
                .font(Font.custom("SF Pro", size: 46))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(
                    maxWidth: .infinity,
                    minHeight: 54,
                    maxHeight: 54,
                    alignment: .center
                )
        }
    }
}
struct Weather: View {
    var body: some View {
        
        Text("70%")
            .font(.system(size:18)).bold()
            .multilineTextAlignment(.center)
            .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
            .frame(maxWidth: .infinity, alignment: .top)
        Image(systemName: "cloud.rain.fill")
            .font(Font.custom("SF Pro", size: 46))
            .multilineTextAlignment(.center)
            .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
            .frame(
                maxWidth: .infinity,
                minHeight: 54,
                maxHeight: 54,
                alignment: .center
            )
    }
}
struct Temp: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Curitiba")
                .font(.system(size:18)).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(maxWidth: .infinity, alignment: .top)
            
            Text("24°")
                .font(.system(size: 40).bold())
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                
        }
        .frame(width: 71)
    }
}

struct CardHead: View {
    var body: some View {
        HStack{
            Spacer()
            CardWheather(cardName: "cardGrau", isTemp: true)
            CardWheather(cardName: "cardClima", isWeather: true)
            CardWheather(cardName: "cardUv", isUv: true)
            Spacer()
        }
    }
}

#Preview {
    CardHead()
}
