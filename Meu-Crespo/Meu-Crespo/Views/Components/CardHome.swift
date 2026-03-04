import SwiftUI

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
                CardHome(item: item) {
                    selectedItem = item
                }
            }
        }
        .onAppear {
            carregarJSON()
            atualizarConteudoConformeClima()
        }
        .onChange(of: weatherManager.condition) {
            atualizarConteudoConformeClima()
        }
        .onChange(of: weatherManager.temperature) { 
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
struct CardHome: View {
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
                        .font(.system(size: 20)).bold()
                        .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                        .frame(width: 150)
                }
                .padding(10)
            }
        }
    }
}
