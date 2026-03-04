import Foundation

struct ContentModel: Identifiable, Decodable {
    let id: Int
    let titulo: String
    let texto: String
}
