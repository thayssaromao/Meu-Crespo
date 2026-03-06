import SwiftUI

struct TimelineView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weatherManager: WeatherManager
    @StateObject private var viewModel = TimelineViewModel()
  
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 26) {
                    
                    Text("Cronograma Capilar")
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(colorScheme == .light ? .pinky : .white)
                    
                    Text("Edite \(Image(systemName: "pencil.circle.fill")) seu cronograma capilar e mantenha-se bem cuidado!")
                        .font(Font.custom("SF Pro", size: 18))
                        .foregroundColor(colorScheme == .light ? .redBrown : .white)

                    WeekSlider(selectedDate: $viewModel.selectedDate)
                    
                    cardRecomendation

                    Spacer()
                }
                .padding()
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Menu {
//                            
//                        } label: {
//                            Label("Tema", systemImage: "questionmark")
//                        }
//                    }
//                }
            }
        }
                
    }
    func formatarData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

extension TimelineView {
    private var cardRecomendation: some View {
        VStack(alignment:.leading, spacing: 20){
            Text("Recomendação")
                .bold()
                .font(.system(size: 28))
                .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)
            
            Text("\(formatarData(weatherManager.selectedDate))")
                .foregroundColor(colorScheme == .light ? Color.gray : .primary)
            
            let treatment = viewModel.treatmentForSelectedDay()
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 20) {
                    Text(treatment.rawValue)
                        .font(.title2.bold())
                    
                    Menu {
                        ForEach([
                            HairTreatment.hydration,
                            .nutrition,
                            .reconstruction,
                            .umectation
                        ], id: \.self) { option in
                            
                            Button(option.rawValue) {
                                let normalizedDate = Calendar.current.startOfDay(for: viewModel.selectedDate)
                                    viewModel.customTreatments[normalizedDate] = option
                            }
                        }
                        
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                    }
                }
                
                Text("Tratamento ideal para hoje baseado no seu perfil capilar.")
                
                
            }
            .foregroundColor(colorScheme == .light ? Color.redBrown : .pinky)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 140)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 32)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.black.opacity(0.03), lineWidth: 1)
            )
            
        }
    }
}

//#Preview {
//    TimelineView()
//        .environmentObject(WeatherManager())
//}
