import Foundation

class HairProfileManager {
    
    static let shared = HairProfileManager()
    
    private let key = "hair_profile"
    
    func save(profile: HairProfile) {
        
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> HairProfile? {
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        return try? JSONDecoder().decode(HairProfile.self, from: data)
    }
}
