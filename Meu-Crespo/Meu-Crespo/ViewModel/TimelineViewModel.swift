import SwiftUI
internal import Combine

enum HairTreatment: String {
    case hydration = "Hidratação"
    case nutrition = "Nutrição"
    case reconstruction = "Reconstrução"
    case umectation = "Umectação"
}

class TimelineViewModel: ObservableObject {
    
    @AppStorage("userName") var userName: String = ""
    @AppStorage("hairPorosity") var porosity: String = ""
    @AppStorage("washFrequency") var washFrequency: String = ""
    @AppStorage("hasChemical") var hasChemical: Bool = false
    @AppStorage("hairDryness") var dryness: String = ""
    
    @Published var selectedDate: Date = Date()
    @Published var customTreatments: [Date: HairTreatment] = [:]

    func treatmentForSelectedDay() -> HairTreatment {
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        
        if let custom = customTreatments[normalizedDate] {
            return custom
        }
        
        return treatmentForDay(selectedDate)
    }
    
    func treatmentForDay(_ date: Date) -> HairTreatment {

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        var treatments: [HairTreatment] = [
            .hydration,
            .nutrition,
            .reconstruction,
            .umectation
        ]

        if dryness == "Muito" {
            treatments = [.hydration, .nutrition, .umectation, .hydration, .umectation]
        }

        if hasChemical {
            treatments = [.hydration, .reconstruction, .umectation, .nutrition, .umectation]
        }

        if porosity == "Alta" {
            treatments = [.nutrition, .umectation, .hydration, .reconstruction, .umectation]
        }

        return treatments[(weekday - 1) % treatments.count]
    }
}
