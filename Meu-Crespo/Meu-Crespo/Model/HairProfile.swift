import Foundation

struct HairProfile: Codable {
    var porosity: HairPorosity
    var washFrequency: WashFrequency
    var hasChemistry: Bool
    var drynessLevel: HairDryness
}

enum HairPorosity: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var localizedLabel: String { L("porosity.\(rawValue)") }
}

enum HairDryness: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var localizedLabel: String { L("dryness.\(rawValue)") }
}

enum WashFrequency: Int, CaseIterable, Codable {
    case once = 1
    case twice = 2
    case three = 3
    case four = 4

    var label: String { "\(rawValue)x" }
}
