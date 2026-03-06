import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
//    @StateObject private var weatherManager = WeatherManager()
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing:30){
                VStack(spacing:30){
                    WeekSlider(selectedDate: $selectedDate)
                    CardHead()
                }.padding(.top,200)
                    .padding(.bottom,10)
                
                VStack(alignment:.leading){
                    Text("Recomendações")
                        .bold()
                        .font(.system(size: 28))
                        .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)
                        .padding(.leading,25)
                    
                    ZStack{
                        Image("bgRecomendacao")
                        
                        CardListView()
                          .padding(.bottom,200)
                    }
                }
                
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
