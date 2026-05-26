import Foundation
import SwiftUI
internal import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese = "pt-BR"
    case english = "en"
    case french = "fr"
    case german = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .portuguese: return "Português"
        case .english: return "English"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("app_language") private var storedLanguage: String = AppLanguage.portuguese.rawValue

    @Published private(set) var bundle: Bundle = .main
    @Published private(set) var currentLanguage: AppLanguage = .portuguese

    private init() {
        let initial = AppLanguage(rawValue: storedLanguage) ?? .portuguese
        currentLanguage = initial
        bundle = Self.makeBundle(for: initial)
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        storedLanguage = language.rawValue
        currentLanguage = language
        bundle = Self.makeBundle(for: language)
    }

    private static func makeBundle(for language: AppLanguage) -> Bundle {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return .main }
        return bundle
    }

    static func migrateIfNeeded() {
        let porosityMap = ["Baixa": "low", "Média": "medium", "Alta": "high"]
        let drynessMap  = ["Pouco": "low", "Moderado": "medium", "Muito": "high"]
        if let old = UserDefaults.standard.string(forKey: "hairPorosity"),
           let new = porosityMap[old] {
            UserDefaults.standard.set(new, forKey: "hairPorosity")
        }
        if let old = UserDefaults.standard.string(forKey: "hairDryness"),
           let new = drynessMap[old] {
            UserDefaults.standard.set(new, forKey: "hairDryness")
        }
    }
}

func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: LanguageManager.shared.bundle, comment: "")
}
