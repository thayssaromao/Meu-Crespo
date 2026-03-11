import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
//    @StateObject private var weatherManager = WeatherManager()
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing:30){
                Spacer()

                VStack(spacing:20){
                    WeekSlider(selectedDate: $selectedDate)
                        .padding(.top, 80)
                        .frame(maxWidth: 600)
                        .frame(maxWidth: .infinity)
                    CardHead()
                        
                }.padding(.top, 30)
                                
                VStack(alignment:.leading){
                    Text("Recomendações")
                        .bold()
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 38 : 28))
                        .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)
                        .padding(.leading, 25)
                
                    ZStack{
                        Image("bgRecomendacao")
                            .resizable()
                                .scaledToFill()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 700 : 370 , height: UIDevice.current.userInterfaceIdiom == .pad ? 700 : 450)
                                .clipped()
                                .cornerRadius(30)
                        
                        CardListView()
                          
                    }
                }
                
                    .padding(.bottom, 120)
                
            }
            .background(colorScheme == .light ? Color.white : Color.brownBg)
            .ignoresSafeArea()
        }
       // .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .environmentObject(WeatherManager())
}
