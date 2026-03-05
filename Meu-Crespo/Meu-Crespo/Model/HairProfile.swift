import Foundation

struct HairProfile: Codable {

    var porosity: HairPorosity
    var washFrequency: WashFrequency
    var hasChemistry: Bool
    var drynessLevel: HairDryness
}

enum HairPorosity: String, Codable, CaseIterable {
    case low = "Baixa"
    case medium = "Média"
    case high = "Alta"
}

enum HairDryness: String, Codable, CaseIterable {
    case low = "Pouco"
    case medium = "Moderado"
    case high = "Muito"
}

enum WashFrequency: Int, CaseIterable, Codable {
    case once = 1
    case twice = 2
    case three = 3
    case four = 4
    
    var label: String {
            "\(rawValue)x"
        }
}
