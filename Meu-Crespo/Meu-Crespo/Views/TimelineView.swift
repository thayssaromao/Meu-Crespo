import SwiftUI

import SwiftUI

struct TimelineView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weatherManager: WeatherManager
        
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Cronograma Capilar")
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(colorScheme == .light ? .pinky : .white)
                    
                    Text("Nosso cronograma é baseado no clima da sua região.")
                        .font(Font.custom("SF Pro", size: 18))
                        .foregroundColor(colorScheme == .light ? .redBrown : .white)
                    
                    //WeekSlider()
                    
                    
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            
                        } label: {
                            Label("Tema", systemImage: "questionmark")
                        }
                    }
                }
            }
        }
                
    }

}

#Preview {
    TimelineView()
        .environmentObject(WeatherManager())
}
