import SwiftUI

struct CardWheather: View {

    @EnvironmentObject var weatherManager: WeatherManager
    
    var cardName: String
    var isTemp: Bool = false
    var isWeather: Bool = false
    var isUv: Bool = false
    var isHumidity: Bool = false
    var isWind: Bool = false

    var body: some View {

        ZStack {
            Image(cardName)
                .resizable()
                .frame(height:  UIDevice.current.userInterfaceIdiom == .phone ? 115 : 180)
            
            VStack(alignment: .center, spacing: 10) {
                
                if(isTemp){
                    Temp().environmentObject(weatherManager)
                }
                if(isWeather){
                    Weather().environmentObject(weatherManager)
                }
                if(isWind){
                    Wind().environmentObject(weatherManager)
                }
            }
        }
        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 115 : 180)
        .opacity(weatherManager.status == .loaded ? 1 : 0.6)
    }
}

struct Weather: View {
    @EnvironmentObject var weatherManager: WeatherManager

    var body: some View {
        
        VStack(alignment: .center,  spacing: 8){
            Text(weatherManager.condition)
                .lineLimit(2)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 24)).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(width:100)
                .padding(.top,3)
            
            Image(systemName:  weatherManager.symbolName)
                .font(Font.custom("SF Pro", size:  UIDevice.current.userInterfaceIdiom == .phone ? 40 : 60)).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                
        }
    }
}

struct Temp: View {
    @EnvironmentObject var weatherManager: WeatherManager

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(weatherManager.cityName)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 26)).bold()
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
               
            
            Text(weatherManager.temperature)
                .font(.system(size: 30).bold())
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                
        }
        .frame(width: 120)
    }
}

struct Wind: View {
    @EnvironmentObject var weatherManager: WeatherManager

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(
                "Vento \(weatherManager.windStatus)\n\(weatherManager.windSpeed)"
            )
            .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 24 )).bold()
            .multilineTextAlignment(.center)
            .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
            .frame(width: 120)
            
            Image(systemName: weatherManager.windSymbol)
                .font(Font.custom("SF Pro", size: 40))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
        }
    }
}

struct Humidity: View {
    @EnvironmentObject var weatherManager: WeatherManager

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Umidade \(weatherManager.humidity)")
                .font(.system(size:14)).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(width: 100)
            
            Image(systemName: "drop.fill")
                .font(Font.custom("SF Pro", size: 35))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
               
        }
    }
}

struct Uv: View {
    @EnvironmentObject var weatherManager: WeatherManager

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Índice Uv\n\(weatherManager.uvIndex)")
                .font(.system(size:18)).bold()
                .multilineTextAlignment(.center)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .frame(width: 100)

            Image(systemName: weatherManager.uvSymbol)
                .font(Font.custom("SF Pro", size: 46))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
        }
    }
}

struct CardHead: View {
    var body: some View {
        HStack(spacing: 10){
            CardWheather(cardName: "cardGrau", isTemp: true)
            CardWheather(cardName: "cardClima", isWeather: true)
            CardWheather(cardName: "cardUv", isWind: true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CardHead()
        .environmentObject(WeatherManager())
}
