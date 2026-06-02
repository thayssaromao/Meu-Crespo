import SwiftUI

// MARK: - Seção inline de Sugestões de Penteados
struct HairSuggestionsSection: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var jsonSuggestions: [String] = []
    @State private var dadosOriginais: [ConteudoItem] = []
    @State private var climaChave: String = "nublado"
    @State private var climaLabel: String = ""
    @State private var isLoadingAI = false
    @State private var aiSuggestions: [String]? = nil
    @State private var isAI = false
    @State private var aiFailed = false

    @AppStorage("hairPorosity") private var storedPorosity: String = HairPorosity.medium.rawValue
    @AppStorage("hairDryness") private var storedDryness: String = HairDryness.medium.rawValue
    @AppStorage("chemicalTreatment") private var storedChemical: String = ChemicalTreatment.none.rawValue
    @AppStorage("washFrequency") private var storedWashFrequency: Int = WashFrequency.twice.rawValue

    private var displaySuggestions: [String] {
        aiSuggestions ?? jsonSuggestions
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                aiStatusBadge
            }

            if isLoadingAI {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                    Text(L("ai.generating"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(displaySuggestions, id: \.self) { suggestion in
                    HairstyleCard(text: suggestion)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 242/255, green: 106/255, blue: 95/255), location: 0),
                    .init(color: Color(red: 242/255, green: 156/255, blue: 108/255), location: 0.25),
                    .init(color: Color(red: 242/255, green: 180/255, blue: 107/255), location: 0.5),
                    .init(color: Color(red: 242/255, green: 200/255, blue: 151/255), location: 0.75),
                    .init(color: Color(red: 242/255, green: 220/255, blue: 194/255), location: 1),
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .cornerRadius(30)
        )
        .onAppear { carregarJSON() }
        .onChange(of: weatherManager.condition) { atualizarSugestoes() }
        .onChange(of: weatherManager.temperature) { atualizarSugestoes() }
        .onChange(of: languageManager.currentLanguage) { carregarJSON() }
        .task(id: weatherManager.selectedDate) { await carregarAI() }
    }

    @ViewBuilder
    private var aiStatusBadge: some View {
        if isLoadingAI {
            HStack(spacing: 5) {
                ProgressView().scaleEffect(0.7).tint(.white)
                Text(L("ai.badge.loading"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.25), in: Capsule())
        } else if isAI {
            Text("✦ Apple Intelligence")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.18), in: Capsule())
        } else if aiFailed {
            Text(L("ai.badge.default"))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.15), in: Capsule())
        }
    }

    func carregarJSON() {
        let bundle = LanguageManager.shared.bundle
        let url = bundle.url(forResource: "dados", withExtension: "json")
            ?? Bundle.main.url(forResource: "dados", withExtension: "json")
        guard let resolvedUrl = url,
              let data = try? Data(contentsOf: resolvedUrl),
              let decoded = try? JSONDecoder().decode([ConteudoItem].self, from: data) else { return }
        dadosOriginais = decoded
        atualizarSugestoes()
    }

    func atualizarSugestoes() {
        let clima = weatherManager.condition.lowercased()
        let temperatura = Int(weatherManager.temperature.filter("0123456789".contains)) ?? 0
        let ventoKey = weatherManager.windStatusKey

        var chave = "nublado"
        var label = L("weather.condition.cloudy")

        if clima.contains("chuva") || clima.contains("rain") || clima.contains("drizzle") || clima.contains("thunderstorm") {
            chave = "chuvoso"; label = L("weather.condition.rainy")
        } else if clima.contains("sol") || clima.contains("ensolarado") || clima.contains("clear") {
            chave = "ensolarado"; label = L("weather.condition.sunny")
        } else if clima.contains("mostly clear") || clima.contains("partly cloudy") || clima.contains("parcialmente") {
            chave = "nublado"; label = L("weather.condition.partlyCloudy")
        } else if ventoKey == "alert" || ventoKey == "moderate" {
            chave = "ventando"; label = L("weather.condition.windy")
        } else if temperatura < 16 {
            chave = "frio"; label = L("weather.condition.cold")
        } else if clima.contains("nublado") || clima.contains("cloud") || clima.contains("nuvens") {
            chave = "nublado"; label = L("weather.condition.cloudy")
        }

        climaChave = chave
        climaLabel = label
        jsonSuggestions = dadosOriginais
            .filter { $0.tipo == "penteados" }
            .flatMap { $0.climas[chave] ?? [L("weather.noInfo")] }
    }

    func carregarAI() async {
        aiSuggestions = nil
        isAI = false
        aiFailed = false

        guard HairstyleAIService.shared.isAvailable else { return }
        if dadosOriginais.isEmpty { carregarJSON() }
        isLoadingAI = true
        defer { isLoadingAI = false }
        let context = HairContext(
            porosity: HairPorosity(rawValue: storedPorosity) ?? .medium,
            dryness: HairDryness(rawValue: storedDryness) ?? .medium,
            chemical: ChemicalTreatment(rawValue: storedChemical) ?? .none,
            washFrequency: WashFrequency(rawValue: storedWashFrequency) ?? .twice,
            weatherCondition: climaLabel.isEmpty ? L("weather.condition.cloudy") : climaLabel,
            temperature: weatherManager.temperature,
            humidity: weatherManager.humidity,
            selectedDate: weatherManager.selectedDate
        )
        do {
            aiSuggestions = try await HairstyleAIService.shared.suggestions(for: context)
            isAI = true
        } catch {
            aiFailed = true
        }
    }
}

// MARK: - Card individual de penteado (novo design inline)
struct HairstyleCard: View {
    var text: String

    private var parts: [String] {
        let components = text.components(separatedBy: ": ")
        guard components.count > 1 else { return [text, ""] }
        return [components[0], components.dropFirst().joined(separator: ": ")]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(parts[0])
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
            if !parts[1].isEmpty {
                Text(parts[1])
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.32, green: 0.13, blue: 0.02))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}
