import SwiftUI

// MARK: - Modelo de dados (para o JSON)
struct ConteudoItem: Codable, Identifiable {
    var id = UUID()
    var tipo: String
    var titulo: String
    var climas: [String: [String]]

    private enum CodingKeys: String, CodingKey {
        case tipo, titulo, climas
    }
}
