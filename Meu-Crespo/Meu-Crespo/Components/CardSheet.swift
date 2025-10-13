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
    var climas: [String: [String]]

    private enum CodingKeys: String, CodingKey {
        case tipo, titulo, climas
    }
}

// MARK: - Lista de Cards
struct CardListView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    
    @State private var selectedItem: ConteudoItem? = nil
    @State private var dadosOriginais: [ConteudoItem] = []
    @State private var dadosFiltrados: [ConteudoItem] = []
    @State private var climaAtualLabel: String = "Carregando clima..."
    @State private var climaChave: String = "nublado"
    @State private var temperaturaAtual: String = "--"
    @State private var ventoAtual: String = "--"
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(dadosFiltrados) { item in
                CardSheet(item: item) {
                    selectedItem = item
                }
            }
        }
        .onAppear {
            carregarJSON()
            atualizarConteudoConformeClima()
        }
        .onChange(of: weatherManager.condition) { _ in
            atualizarConteudoConformeClima()
        }
        .onChange(of: weatherManager.temperature) { _ in
            atualizarConteudoConformeClima()
        }
        .sheet(item: $selectedItem) { item in
            SheetView(
                item: item,
                climaAtual: climaAtualLabel,
                climaChave: climaChave,
                temperatura: temperaturaAtual,
                vento: ventoAtual,
                dataSelecionada: weatherManager.selectedDate
            )
            .environmentObject(weatherManager)
        }
    }
    
    // MARK: - Carrega o JSON inicial
    func carregarJSON() {
        guard let url = Bundle.main.url(forResource: "dados", withExtension: "json") else {
            print("⚠️ Arquivo dados.json não encontrado.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ConteudoItem].self, from: data)
            self.dadosOriginais = decoded
            atualizarConteudoConformeClima()
        } catch {
            print("❌ Erro ao carregar JSON: \(error)")
        }
    }
    
    // MARK: - Atualiza conteúdo conforme o clima atual
    func atualizarConteudoConformeClima() {
        let clima = weatherManager.condition.lowercased()
        let temperatura = Int(weatherManager.temperature.filter("0123456789".contains)) ?? 0
        let vento = weatherManager.windStatus.lowercased()
        let dataSelecionada = weatherManager.selectedDate

        var chave: String = "nublado"
        var climaLabel: String = "Dia nublado"

        // 🔹 Lógica refinada
        if clima.contains("chuva") || clima.contains("rain") {
            chave = "chuvoso"
            climaLabel = "Dia chuvoso"
        }
        else if clima.contains("sol") || clima.contains("ensolarado") || clima.contains("clear") {
            chave = "ensolarado"
            climaLabel = "Dia ensolarado"
        }
        else if clima.contains("mostly clear") || clima.contains("partly cloudy") || clima.contains("parcialmente") {
            chave = "nublado"
            climaLabel = "Dia parcialmente ensolarado"
        }
        else if clima.contains("drizzle") || clima.contains("thunderstorm") {
            chave = "chuvoso"
            climaLabel = "Dia chuvoso"
        }
        else if vento.contains("vento") || vento.contains("moderado") || vento.contains("alerta") {
            chave = "ventando"
            climaLabel = "Dia ventando"
        }
        else if temperatura < 16 {
            chave = "frio"
            climaLabel = "Dia frio"
        }
        else if clima.contains("nublado") || clima.contains("cloud") || clima.contains("nuvens") {
            chave = "nublado"
            climaLabel = "Dia nublado"
        }

        // Atualiza labels
        climaAtualLabel = climaLabel
        climaChave = chave
        temperaturaAtual = weatherManager.temperature
        ventoAtual = "\(weatherManager.windStatus) (\(weatherManager.windSpeed))"

        print("🔍 Condição detectada: \(climaLabel) | Clima: \(clima) | Temp: \(temperatura) | Vento: \(vento) | Data: \(dataSelecionada)")

        // Filtra conteúdo com base no clima
        self.dadosFiltrados = self.dadosOriginais.map { item in
            var novoItem = item
            if let conteudoDoClima = item.climas[chave] {
                novoItem.climas = [chave: conteudoDoClima]
            } else {
                novoItem.climas = [chave: ["Sem informações específicas para este clima."]]
            }
            return novoItem
        }
    }

}

// MARK: - Card que aparece na Home
struct CardSheet: View {
    var item: ConteudoItem
    var onTap: () -> Void
    
    var imageName: String {
        switch item.tipo {
        case "penteados": return "garfo"
        case "cronograma": return "cronograma"
        case "dicas": return "dicas"
        default: return "garfo"
        }
    }
    
    var body: some View {
        Button { onTap() } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 323, height: 105)
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.25), radius: 1.8, x: 0, y: 3.6)
                
                HStack(spacing: 20) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                    Text(item.tipo.capitalized)
                        .font(.system(size: 18)).bold()
                        .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                        .frame(width: 150)
                }
                .padding(10)
            }
        }
    }
}

// MARK: - Sheet (abre ao clicar no card)
struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var weatherManager: WeatherManager
    
    var item: ConteudoItem
    var climaAtual: String
    var climaChave: String
    var temperatura: String
    var vento: String
    var dataSelecionada: Date
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button("Fechar") {
                        dismiss()
                    }
                    .padding(.top, 10)
                }
                
                Text(item.titulo)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                    .padding(.bottom, 5)
                
                // 🔍 Informações de debug
                VStack(alignment: .leading, spacing: 6) {
                    Text("🌦️ \(climaAtual) (\(climaChave))")
                    Text("🌡️ Temperatura: \(temperatura)")
                    Text("💨 Vento: \(vento)")
                    Text("📅 Data: \(formatarData(weatherManager.selectedDate))")
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
                
                if let conteudo = item.climas.values.first {
                    ForEach(conteudo, id: \.self) { linha in
                        Text("• \(linha)")
                            .font(.body)
                            .foregroundColor(.black)
                            .padding(.bottom, 4)
                    }
                } else {
                    Text("Sem informações disponíveis para este clima.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    func formatarData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

#Preview {
    CardListView()
        .environmentObject(WeatherManager())
        .padding()
}
