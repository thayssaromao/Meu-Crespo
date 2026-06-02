import Foundation
import FoundationModels

// MARK: - Generable types (iOS 26+)

@available(iOS 26.0, *)
@Generable
struct AISuggestion {
    var name: String
    var reason: String
}

@available(iOS 26.0, *)
@Generable
struct AISuggestionsOutput {
    var suggestions: [AISuggestion]
}

// MARK: - Input context

struct HairContext {
    let porosity: HairPorosity
    let dryness: HairDryness
    let chemical: ChemicalTreatment
    let washFrequency: WashFrequency
    let weatherCondition: String
    let temperature: String
    let humidity: String
    let selectedDate: Date
}

// MARK: - Service

final class HairstyleAIService {
    static let shared = HairstyleAIService()
    private init() {}

    // Cache keyed by "porosity|dryness|chemical|weatherCondition", valid for current day
    private var cache: [String: (suggestions: [String], date: Date)] = [:]

    var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        return false
    }

    func suggestions(for context: HairContext) async throws -> [String] {
        let dayKey = DateFormatter.localizedString(from: context.selectedDate, dateStyle: .short, timeStyle: .none)
        let key = "\(context.porosity.rawValue)|\(context.dryness.rawValue)|\(context.chemical.rawValue)|\(context.weatherCondition)|\(dayKey)"

        if let cached = cache[key] {
            return cached.suggestions
        }

        guard #available(iOS 26.0, *),
              SystemLanguageModel.default.isAvailable else {
            throw HairstyleAIError.notAvailable
        }

        let session = LanguageModelSession()
        let result = try await session.respond(
            to: buildPrompt(for: context),
            generating: AISuggestionsOutput.self
        )

        let formatted = result.content.suggestions.map { "\($0.name): \($0.reason)" }
        cache[key] = (formatted, Date())
        return formatted
    }

    private func buildPrompt(for ctx: HairContext) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .english:
            return """
            You are a specialist in curly and coily hair (types 3A to 4C).
            User's hair profile:
            - Porosity: \(ctx.porosity.localizedLabel)
            - Dryness: \(ctx.dryness.localizedLabel)
            - Chemical treatment: \(ctx.chemical.localizedLabel)
            - Wash frequency: \(ctx.washFrequency.rawValue)x per week
            Today's weather: \(ctx.weatherCondition), \(ctx.temperature), humidity \(ctx.humidity).

            Suggest exactly 4 distinct hairstyles exclusively for curly and coily hair (e.g., twist out, wash and go, puff, braid-out, cornrows, protective styles, Bantu knots, finger coils, etc.).

            Rules:
            - "name": the hairstyle name in English
            - "reason": 1–2 sentences explaining why this hairstyle suits this exact weather and hair profile — mention a concrete benefit (e.g., seals moisture in the cold, reduces frizz in humidity, protects from UV, reduces manipulation on wash day, etc.)
            - Do not suggest hairstyles designed for straight or wavy hair
            - Each of the 4 suggestions must be distinct — no repeats or variations of the same style
            - Respond entirely in English
            """
        case .french:
            return """
            Vous êtes spécialiste des cheveux crépus et bouclés (types 3A à 4C).
            Profil capillaire de l'utilisatrice:
            - Porosité: \(ctx.porosity.localizedLabel)
            - Sécheresse: \(ctx.dryness.localizedLabel)
            - Traitement chimique: \(ctx.chemical.localizedLabel)
            - Fréquence de lavage: \(ctx.washFrequency.rawValue)x par semaine
            Météo du jour: \(ctx.weatherCondition), \(ctx.temperature), humidité \(ctx.humidity).

            Suggérez exactement 4 coiffures distinctes, exclusivement pour cheveux crépus et bouclés (ex: twist out, wash and go, puff, braid-out, cornrows, protective styles, Bantu knots, finger coils, etc.).

            Règles:
            - "name": le nom de la coiffure en français
            - "reason": 1–2 phrases expliquant pourquoi cette coiffure convient à cette météo et à ce profil capillaire — mentionnez un bénéfice concret (ex: scelle l'hydratation par temps froid, réduit le frisottis avec l'humidité, protège des UV, etc.)
            - Ne suggérez pas de coiffures conçues pour les cheveux raides ou ondulés
            - Chacune des 4 suggestions doit être distincte — pas de répétitions ni de variantes du même style
            - Répondez entièrement en français
            """
        case .german:
            return """
            Sie sind Spezialistin für lockiges und krauses Haar (Typen 3A bis 4C).
            Haarprofil der Nutzerin:
            - Porosität: \(ctx.porosity.localizedLabel)
            - Trockenheit: \(ctx.dryness.localizedLabel)
            - Chemische Behandlung: \(ctx.chemical.localizedLabel)
            - Waschfrequenz: \(ctx.washFrequency.rawValue)x pro Woche
            Heutiges Wetter: \(ctx.weatherCondition), \(ctx.temperature), Luftfeuchtigkeit \(ctx.humidity).

            Schlagen Sie genau 4 unterschiedliche Frisuren vor, ausschließlich für lockiges und krauses Haar (z.B. Twist Out, Wash and Go, Puff, Braid-Out, Cornrows, Protective Styles, Bantu Knots, Finger Coils usw.).

            Regeln:
            - "name": der Name der Frisur auf Deutsch
            - "reason": 1–2 Sätze, die erklären, warum diese Frisur für dieses Wetter und dieses Haarprofil geeignet ist — konkreten Nutzen nennen (z.B. versiegelt Feuchtigkeit bei Kälte, reduziert Frizz bei Feuchtigkeit, schützt vor UV, usw.)
            - Schlagen Sie keine Frisuren vor, die für glattes oder welliges Haar konzipiert sind
            - Jeder der 4 Vorschläge muss einzigartig sein — keine Wiederholungen oder Variationen desselben Stils
            - Antworten Sie ausschließlich auf Deutsch
            """
        case .portuguese:
            return """
            Você é especialista em cabelos crespos e cacheados (tipos 3A a 4C).
            Perfil capilar da usuária:
            - Porosidade: \(ctx.porosity.localizedLabel)
            - Ressecamento: \(ctx.dryness.localizedLabel)
            - Tratamento químico: \(ctx.chemical.localizedLabel)
            - Frequência de lavagem: \(ctx.washFrequency.rawValue)x por semana
            Clima de hoje: \(ctx.weatherCondition), \(ctx.temperature), umidade \(ctx.humidity).

            Sugira exatamente 4 penteados distintos, exclusivamente para cabelos crespos e cacheados (ex: twist out, wash and go, puff, braid-out, cornrows, protective styles, Bantu knots, finger coils, etc.).

            Regras:
            - "name": o nome do penteado em português
            - "reason": 1–2 frases explicando por que este penteado é ideal para este clima e perfil capilar específicos — mencione um benefício concreto (ex: sela a hidratação no frio, reduz o frizz com umidade alta, protege dos raios UV, reduz manipulação no dia de lavagem, etc.)
            - Não sugira penteados criados para cabelos lisos ou ondulados
            - Cada uma das 4 sugestões deve ser distinta — sem repetições ou variações do mesmo estilo
            - Responda inteiramente em português
            """
        }
    }
}

enum HairstyleAIError: Error {
    case notAvailable
}
