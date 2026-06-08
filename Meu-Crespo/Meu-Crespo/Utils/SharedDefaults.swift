import Foundation

enum SharedDefaults {
    static let suiteName = "group.apple.thayssaromao.MeuCrespo"
    static let store = UserDefaults(suiteName: suiteName) ?? .standard
}
