import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var preferredScheme: ColorScheme? = nil
//    @StateObject private var weatherManager = WeatherManager()
    @EnvironmentObject var weatherManager: WeatherManager

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
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
