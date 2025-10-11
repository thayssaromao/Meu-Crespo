//
//  CardSheet.swift
//  Meu-Crespo
//
//  Created by Thayssa Romão on 08/10/25.
//

import SwiftUI

// MARK: - Modelo de dados (para o JSON)
struct ConteudoItem: Codable, Identifiable {
    var id = UUID()
    var tipo: String
    var titulo: String
    var conteudo: [String]
    
    private enum CodingKeys: String, CodingKey {
           case tipo, titulo, conteudo // id fica fora, não tenta decodificar
       }
}

struct CardListView: View {
    @State private var selectedItem: ConteudoItem? = nil
    @State private var dados: [ConteudoItem] = []

    var body: some View {
        VStack(spacing: 20) {
            ForEach(dados) { item in
                CardSheet(item: item) {
                    selectedItem = item
                }
            }
        }
        .onAppear {
            carregarJSON()
        }
        .sheet(item: $selectedItem) { item in
            SheetView(item: item)
        }
    }

    func carregarJSON() {
        if let url = Bundle.main.url(forResource: "dados", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([ConteudoItem].self, from: data)
                self.dados = decoded
            } catch {
                print("Erro ao carregar JSON: \(error)")
            }
        }
    }
}

struct CardSheet: View {
    var item: ConteudoItem
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 323, height: 105)
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.25), radius: 1.83003, x: 0, y: 3.66006)

                HStack(spacing: 20) {
                    Image("garfo") // pode trocar por item.tipo se quiser
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105)
                        .padding(.trailing, 40)
                        .padding(.top, 10)

                    Text(item.tipo.capitalized)
                        .font(.system(size: 17)).bold()
                        .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                }
            }
        }
    }
}


struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    var item: ConteudoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button("Fechar") {
                    dismiss()
                }
                .padding(.top, 10)
            }

            // 🔍 DEBUG
            Text(item.titulo)
                .onAppear {
                    print("🧾 Abrindo sheet: \(item.tipo)")
                }

            Text(item.titulo)
                .font(.title3)
                .bold()
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                .padding(.bottom, 10)

            ForEach(item.conteudo, id: \.self) { linha in
                Text("• \(linha)")
                    .font(.body)
                    .foregroundColor(.black)
            }

            Spacer()
        }
        .padding()
    }
}


#Preview {
    CardListView()
        .padding()
}
