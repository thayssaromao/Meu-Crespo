import SwiftUI
import PostHog

struct CardListView: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var selectedItem: ConteudoItem? = nil
    @State private var dadosOriginais: [ConteudoItem] = []
    @State private var dadosFiltrados: [ConteudoItem] = []
    @State private var climaAtualLabel: String = L("weather.loading")
    @State private var climaChave: String = "nublado"
    @State private var temperaturaAtual: String = "--"
    @State private var ventoAtual: String = "--"

    var body: some View {
        VStack(spacing: 20) {
            ForEach(dadosFiltrados) { item in
                CardHome(item: item) {
                    // PostHog: Track recommendation card tap
                    PostHogSDK.shared.capture("home_recommendation_opened", properties: [
                        "card_type": item.tipo,
                        "weather_condition": climaChave,
                        "temperature": temperaturaAtual,
                    ])
                    selectedItem = item
                }
            }
        }
        .onAppear {
            carregarJSON()
        }
        .onChange(of: weatherManager.condition) {
            atualizarConteudoConformeClima()
        }
        .onChange(of: weatherManager.temperature) {
            atualizarConteudoConformeClima()
        }
        .onChange(of: languageManager.currentLanguage) {
            carregarJSON()
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

    // MARK: - Carrega o JSON localizado
    func carregarJSON() {
        let bundle = LanguageManager.shared.bundle
        let url: URL?
        if let localizedUrl = bundle.url(forResource: "dados", withExtension: "json") {
            url = localizedUrl
        } else {
            url = Bundle.main.url(forResource: "dados", withExtension: "json")
        }
        guard let resolvedUrl = url else {
            print("⚠️ Arquivo dados.json não encontrado.")
            return
        }
        do {
            let data = try Data(contentsOf: resolvedUrl)
            let decoded = try JSONDecoder().decode([ConteudoItem].self, from: data)
            dadosOriginais = decoded
            atualizarConteudoConformeClima()
        } catch {
            print("❌ Erro ao carregar JSON: \(error)")
        }
    }

    // MARK: - Atualiza conteúdo conforme o clima atual
    func atualizarConteudoConformeClima() {
        let clima = weatherManager.condition.lowercased()
        let temperatura = Int(weatherManager.temperature.filter("0123456789".contains)) ?? 0
        let ventoKey = weatherManager.windStatusKey

        var chave: String = "nublado"
        var climaLabel: String = L("weather.condition.cloudy")

        if clima.contains("chuva") || clima.contains("rain") {
            chave = "chuvoso"
            climaLabel = L("weather.condition.rainy")
        } else if clima.contains("sol") || clima.contains("ensolarado") || clima.contains("clear") {
            chave = "ensolarado"
            climaLabel = L("weather.condition.sunny")
        } else if clima.contains("mostly clear") || clima.contains("partly cloudy") || clima.contains("parcialmente") {
            chave = "nublado"
            climaLabel = L("weather.condition.partlyCloudy")
        } else if clima.contains("drizzle") || clima.contains("thunderstorm") {
            chave = "chuvoso"
            climaLabel = L("weather.condition.rainy")
        } else if ventoKey == "alert" || ventoKey == "moderate" {
            chave = "ventando"
            climaLabel = L("weather.condition.windy")
        } else if temperatura < 16 {
            chave = "frio"
            climaLabel = L("weather.condition.cold")
        } else if clima.contains("nublado") || clima.contains("cloud") || clima.contains("nuvens") {
            chave = "nublado"
            climaLabel = L("weather.condition.cloudy")
        }

        climaAtualLabel = climaLabel
        climaChave = chave
        temperaturaAtual = weatherManager.temperature
        ventoAtual = "\(weatherManager.windStatus) (\(weatherManager.windSpeed))"

        print("🔍 Condição detectada: \(climaLabel) | Clima: \(clima) | Temp: \(temperatura) | Vento: \(ventoKey)")

        dadosFiltrados = dadosOriginais.map { item in
            var novoItem = item
            if let conteudoDoClima = item.climas[chave] {
                novoItem.climas = [chave: conteudoDoClima]
            } else {
                novoItem.climas = [chave: [L("weather.noInfo")]]
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
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 323 : 450, height: 105)
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.25), radius: 1.8, x: 0, y: 3.6)

                HStack(spacing: 20) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    Text(L("card.tipo.\(item.tipo)"))
                        .font(.system(size: 20)).bold()
                        .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                        .frame(width: 150)
                }
                .padding(10)
            }
        }
    }
}
