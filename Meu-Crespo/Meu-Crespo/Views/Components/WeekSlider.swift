import SwiftUI

struct WeekDay: Identifiable {
    let id = UUID()
    let date: Date
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "pt_BR")
        return String(formatter.string(from: date).prefix(1)).capitalized
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct DayView: View {
    let day: WeekDay
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text(day.dayLetter)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
            
            Text(day.dayNumber)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(width: 45, height: 80)
        .background(
            ZStack {
                if isSelected {
                    Capsule()
                        .fill(Color.pinky)
                        .matchedGeometryEffect(id: "selectedBackground", in: namespace)
                }
                
                if day.isToday {
                    Circle()
                        .fill(isSelected ? .clear : Color(red: 0.95, green: 0.42, blue: 0.37).opacity(0.5))
                        .frame(width: 40, height: 40)
                }
            }
        )
    }
    var namespace: Namespace.ID
}


struct WeekSlider: View {
    
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var days: [WeekDay] = []
    @State private var selectedDayId: UUID?
    
    // Namespace para a animação suave da seleção
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(days) { day in
                            DayView(
                                day: day,
                                isSelected: day.id == selectedDayId,
                                namespace: namespace
                            )
                            .id(day.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedDayId = day.id
                                    
                                    weatherManager.updateWeather(for: day.date)

                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    self.days = generateDays()
                    
                    let todayId = days.first(where: { $0.isToday })?.id
                    self.selectedDayId = todayId
                    
                    if let today = days.first(where: { $0.isToday })?.date {
                                             weatherManager.updateWeather(for: today)
                                        }
                    
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(todayId, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: 90)
        }
    }
    
    private func generateDays() -> [WeekDay] {
        let calendar = Calendar.current
        let today = Date()
        var tempDays: [WeekDay] = []
        
        // Gera 9 dias no futuro
        for i in -0...9 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                tempDays.append(WeekDay(date: date))
            }
        }
        return tempDays
    }
}
#Preview {
    WeekSlider().environmentObject(WeatherManager())
}
