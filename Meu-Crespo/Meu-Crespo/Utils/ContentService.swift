import Foundation

class ContentService {

    static func loadContents() -> [ContentModel] {
        let bundle = LanguageManager.shared.bundle
        if let url = bundle.url(forResource: "conteudos", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let contents = try? JSONDecoder().decode([ContentModel].self, from: data) {
            return contents
        }
        // Fallback to main bundle
        guard let url = Bundle.main.url(forResource: "conteudos", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONDecoder().decode([ContentModel].self, from: data)
        else { return [] }
        return contents
    }
}
