import Foundation

class ContentService {
    
    static func loadContents() -> [ContentModel] {
        guard let url = Bundle.main.url(forResource: "conteudos", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let contents = try? JSONDecoder().decode([ContentModel].self, from: data)
        else {
            return []
        }
        
        return contents
    }
}
