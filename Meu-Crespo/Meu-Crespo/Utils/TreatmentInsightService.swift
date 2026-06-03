import Foundation
import FoundationModels

// MARK: - Generable output (iOS 26+)

@available(iOS 26.0, *)
@Generable
struct TreatmentInsightOutput {
    var reason: String
    var tip1: String
    var tip2: String
}

// MARK: - Result (all iOS versions)

struct TreatmentInsightResult {
    let reason: String
    let tip1: String
    let tip2: String
}

// MARK: - Service

final class TreatmentInsightService {
    static let shared = TreatmentInsightService()
    private init() {}

    private var cache: [String: TreatmentInsightResult] = [:]

    var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        return false
    }

    // Returns the hardcoded curl-specific fallback immediately (no async needed)
    func localFallback(for treatment: HairTreatment) -> TreatmentInsightResult {
        TreatmentInsightResult(
            reason: L("timeline.insight.\(treatment.rawValue).reason"),
            tip1:   L("timeline.insight.\(treatment.rawValue).tip1"),
            tip2:   L("timeline.insight.\(treatment.rawValue).tip2")
        )
    }

    // Attempts AI generation; returns nil if unavailable or if it fails
    func aiInsight(for treatment: HairTreatment, context: HairContext) async -> TreatmentInsightResult? {
        guard isAvailable else { return nil }

        let dayKey = Calendar.current.ordinality(of: .day, in: .era, for: context.selectedDate) ?? 0
        let cacheKey = "ai|\(treatment.rawValue)|\(context.porosity.rawValue)|\(context.dryness.rawValue)|\(context.chemical.rawValue)|\(context.humidity)|\(dayKey)|\(LanguageManager.shared.currentLanguage.rawValue)"

        if let cached = cache[cacheKey] { return cached }

        guard #available(iOS 26.0, *), SystemLanguageModel.default.isAvailable else { return nil }

        let session = LanguageModelSession()
        guard let output = try? await session.respond(
            to: buildPrompt(treatment: treatment, context: context),
            generating: TreatmentInsightOutput.self
        ) else { return nil }

        let result = TreatmentInsightResult(
            reason: output.content.reason,
            tip1:   output.content.tip1,
            tip2:   output.content.tip2
        )
        cache[cacheKey] = result
        return result
    }

    // MARK: - Prompt builder

    private func buildPrompt(treatment: HairTreatment, context: HairContext) -> String {
        switch LanguageManager.shared.currentLanguage {
        case .portuguese: return portuguesePrompt(treatment, context)
        case .english:    return englishPrompt(treatment, context)
        case .french:     return frenchPrompt(treatment, context)
        case .german:     return germanPrompt(treatment, context)
        }
    }

    // MARK: - Treatment technical context

    private func technicalContext_pt(_ t: HairTreatment) -> String {
        switch t {
        case .hydration:
            return """
            Cabelos crespos e cacheados perdem umidade com mais facilidade porque o sebo capilar não percorre \
            a espiral do fio como em cabelos lisos. Hidratação repõe água no córtex e é a base do triângulo \
            Hidratação–Nutrição–Reconstrução. Deve ser a etapa mais frequente do cronograma.
            """
        case .nutrition:
            return """
            Nutrição fornece óleos e ácidos graxos que preenchem as lacunas da cutícula levantada dos fios crespos, \
            selando a umidade. Alta porosidade se beneficia de óleos leves (coco, baobá); fios muito secos, de óleos \
            mais pesados (mamona, manteiga de karité). É o "O" do método LOC.
            """
        case .reconstruction:
            return """
            Reconstrução repõe proteínas (queratina, aminoácidos) que formam a estrutura do fio crespo. \
            Imprescindível para quem tem química (coloração, relaxamento), pois processos químicos quebram as \
            pontes dissulfeto. O equilíbrio proteína–umidade é crítico: excesso de proteína endurece e quebra o fio.
            """
        case .umectation:
            return """
            Umectação usa humectantes (glicerina, aloe vera, mel, ácido hialurônico) que atraem moléculas de água \
            do ar para o fio crespo. Acima de 70% de umidade, potencializa o tratamento. Abaixo de 40%, os \
            humectantes podem retirar umidade do próprio fio — o chamado ressecamento reverso.
            """
        }
    }

    private func technicalContext_en(_ t: HairTreatment) -> String {
        switch t {
        case .hydration:
            return """
            Curly and coily strands lose moisture faster because sebum cannot travel along the hair's spiral. \
            Hydration replenishes water in the cortex and is the foundation of the Hydration–Nutrition–Reconstruction \
            triangle. It should be the most frequent step in the schedule.
            """
        case .nutrition:
            return """
            Nutrition provides oils and fatty acids that fill gaps in the raised cuticle of curly/coily strands, \
            sealing in moisture. High porosity benefits from lightweight oils (coconut, baobab); very dry hair from \
            heavier ones (castor, shea butter). It is the "O" in the LOC method.
            """
        case .reconstruction:
            return """
            Reconstruction replenishes proteins (keratin, amino acids) that form the structure of curly strands. \
            Essential for chemically treated hair (color, curl relaxers) since chemical processes break disulfide bonds. \
            Protein–moisture balance is critical: excess protein makes strands stiff and prone to breakage.
            """
        case .umectation:
            return """
            Umectation uses humectants (glycerin, aloe vera, honey, hyaluronic acid) that draw water from the air \
            into curly strands. Above 70% humidity it amplifies the treatment. Below 40%, humectants may pull moisture \
            from the strand itself — known as reverse dryness.
            """
        }
    }

    private func technicalContext_fr(_ t: HairTreatment) -> String {
        switch t {
        case .hydration:
            return """
            Les cheveux crépus et bouclés perdent l'humidité plus vite car le sébum ne remonte pas la spirale du cheveu. \
            L'hydratation recharge le cortex en eau et est la base du triangle Hydratation–Nutrition–Reconstruction. \
            C'est l'étape la plus fréquente du programme.
            """
        case .nutrition:
            return """
            La nutrition apporte des huiles et acides gras qui comblent les écailles ouvertes des cheveux crépus, \
            scellant l'humidité. Haute porosité : huiles légères (noix de coco, baobab). Cheveux très secs : huiles \
            plus lourdes (ricin, beurre de karité). C'est le "O" de la méthode LOC.
            """
        case .reconstruction:
            return """
            La reconstruction remplace les protéines (kératine, acides aminés) qui forment la structure du cheveu crépu. \
            Indispensable pour les cheveux traités chimiquement car les processus chimiques brisent les liaisons disulfure. \
            L'équilibre protéine–humidité est crucial : trop de protéine rend le cheveu rigide et cassant.
            """
        case .umectation:
            return """
            L'umectation utilise des humectants (glycérine, aloe vera, miel, acide hyaluronique) qui attirent l'eau de \
            l'air vers le cheveu crépu. Au-dessus de 70 % d'humidité, le traitement est amplifié. En dessous de 40 %, \
            les humectants peuvent extraire l'humidité du cheveu lui-même.
            """
        }
    }

    private func technicalContext_de(_ t: HairTreatment) -> String {
        switch t {
        case .hydration:
            return """
            Lockiges und krauses Haar verliert Feuchtigkeit schneller, da Talg die Haarspiralen nicht entlangreisen kann. \
            Feuchtigkeitspflege lädt den Cortex mit Wasser auf und ist die Grundlage des Dreiecks \
            Feuchtigkeit–Ernährung–Rekonstruktion. Es sollte der häufigste Pflegeschritt sein.
            """
        case .nutrition:
            return """
            Ernährungspflege liefert Öle und Fettsäuren, die offene Schuppen lockigen Haares füllen und Feuchtigkeit \
            versiegeln. Hohe Porosität: leichte Öle (Kokos, Baobab). Sehr trockenes Haar: schwere Öle (Rizinus, Shea). \
            Dies ist das „O" der LOC-Methode.
            """
        case .reconstruction:
            return """
            Rekonstruktion ersetzt Proteine (Keratin, Aminosäuren), die die Struktur lockiger Haare formen. \
            Unverzichtbar für chemisch behandeltes Haar, da Chemikalien Disulfidbindungen brechen. \
            Protein-Feuchtigkeits-Balance ist kritisch: zu viel Protein macht das Haar spröde und bruchanfällig.
            """
        case .umectation:
            return """
            Umektationspflege verwendet Humektanzien (Glycerin, Aloe Vera, Honig, Hyaluronsäure), die Wasser aus der \
            Luft in lockiges Haar ziehen. Über 70 % Luftfeuchtigkeit verstärkt die Wirkung. Unter 40 % können \
            Humektanzien Feuchtigkeit aus dem Haar selbst entziehen.
            """
        }
    }

    // MARK: - Language-specific prompts

    private func portuguesePrompt(_ treatment: HairTreatment, _ ctx: HairContext) -> String {
        """
        Você é especialista exclusivamente em cabelos crespos e cacheados (tipos 3A a 4C). \
        Jamais dê conselhos para cabelos lisos, ondulados, com alisamento ou escova progressiva.

        O cronograma capilar selecionou **\(treatment.localizedLabel)** para hoje com base no perfil abaixo.

        Perfil capilar:
        - Porosidade: \(ctx.porosity.localizedLabel)
        - Ressecamento: \(ctx.dryness.localizedLabel)
        - Tratamento químico: \(ctx.chemical.localizedLabel)
        - Frequência de lavagem: \(ctx.washFrequency.rawValue)x por semana

        Clima atual: \(ctx.weatherCondition), \(ctx.temperature), umidade \(ctx.humidity).

        Contexto técnico do tratamento:
        \(technicalContext_pt(treatment))

        Gere exatamente três campos:
        - "reason": 1–2 frases explicando por que \(treatment.localizedLabel) é o passo certo para este \
        perfil crespo/cacheado hoje, relacionando porosidade e/ou clima ao mecanismo do tratamento.
        - "tip1": Dica prática específica para cabelos crespos/cacheados ao realizar \(treatment.localizedLabel) \
        hoje. Use termos concretos do universo curly: método LOC/LCO, plopping, difusor, squish-to-condish, \
        praying hands, escara-corte, geleia, wash and go, seção por seção, touca térmica etc. \
        Se o clima for relevante para a dica, mencione-o.
        - "tip2": Segunda dica distinta de tip1, com outra perspectiva prática exclusiva para crespos/cacheados.

        Regras absolutas:
        - Dicas e explicações EXCLUSIVAMENTE para cabelos crespos e cacheados (3A–4C)
        - Nunca mencione chapinha, ferro, prancha, escova progressiva, keratin straightening ou qualquer \
        técnica/produto para alisar
        - Responda inteiramente em português brasileiro
        """
    }

    private func englishPrompt(_ treatment: HairTreatment, _ ctx: HairContext) -> String {
        """
        You are a specialist exclusively in curly and coily hair (types 3A to 4C). \
        Never give advice for straight, wavy, or chemically relaxed/straightened hair.

        The hair schedule selected **\(treatment.localizedLabel)** for today based on the profile below.

        Hair profile:
        - Porosity: \(ctx.porosity.localizedLabel)
        - Dryness: \(ctx.dryness.localizedLabel)
        - Chemical treatment: \(ctx.chemical.localizedLabel)
        - Wash frequency: \(ctx.washFrequency.rawValue)x per week

        Current weather: \(ctx.weatherCondition), \(ctx.temperature), humidity \(ctx.humidity).

        Technical treatment context:
        \(technicalContext_en(treatment))

        Generate exactly three fields:
        - "reason": 1–2 sentences explaining why \(treatment.localizedLabel) is the right step for this \
        curly/coily profile today, relating porosity and/or weather to the treatment mechanism.
        - "tip1": A practical tip specific to curly/coily hair for performing \(treatment.localizedLabel) today. \
        Use concrete curly-hair terms: LOC/LCO method, plopping, diffuser, squish-to-condish, praying hands, \
        gel cast, wash and go, heat cap, section by section, etc. Mention weather if relevant to the tip.
        - "tip2": A second distinct tip from tip1, with another practical angle exclusively for curly/coily hair.

        Absolute rules:
        - Explanations and tips EXCLUSIVELY for curly and coily hair (3A–4C)
        - Never mention flat iron, relaxer, keratin straightening, or any straightening product/technique
        - Respond entirely in English
        """
    }

    private func frenchPrompt(_ treatment: HairTreatment, _ ctx: HairContext) -> String {
        """
        Vous êtes spécialiste exclusivement des cheveux crépus et bouclés (types 3A à 4C). \
        Ne donnez jamais de conseils pour les cheveux raides, ondulés, défrisés ou lissés.

        Le programme capillaire a sélectionné **\(treatment.localizedLabel)** pour aujourd'hui selon ce profil.

        Profil capillaire :
        - Porosité : \(ctx.porosity.localizedLabel)
        - Sécheresse : \(ctx.dryness.localizedLabel)
        - Traitement chimique : \(ctx.chemical.localizedLabel)
        - Fréquence de lavage : \(ctx.washFrequency.rawValue)x par semaine

        Météo actuelle : \(ctx.weatherCondition), \(ctx.temperature), humidité \(ctx.humidity).

        Contexte technique du soin :
        \(technicalContext_fr(treatment))

        Générez exactement trois champs :
        - "reason" : 1–2 phrases expliquant pourquoi \(treatment.localizedLabel) est le bon soin pour ce \
        profil crépu/bouclé aujourd'hui, en reliant la porosité et/ou la météo au mécanisme du soin.
        - "tip1" : Un conseil pratique spécifique aux cheveux crépus/bouclés pour réaliser \(treatment.localizedLabel) \
        aujourd'hui. Utilisez des termes concrets : méthode LOC/LCO, plopping, diffuseur, squish-to-condish, \
        praying hands, gelée coiffante, wash and go, bonnet chauffant, section par section, etc. \
        Mentionnez la météo si pertinent.
        - "tip2" : Un deuxième conseil distinct de tip1, sous un autre angle pratique exclusif aux crépus/bouclés.

        Règles absolues :
        - Conseils EXCLUSIVEMENT pour les cheveux crépus et bouclés (3A–4C)
        - Ne mentionnez jamais le fer lissant, le défrisage, le lissage brésilien ou tout produit/technique lissante
        - Répondez entièrement en français
        """
    }

    private func germanPrompt(_ treatment: HairTreatment, _ ctx: HairContext) -> String {
        """
        Sie sind ausschließlich Spezialistin für lockiges und krauses Haar (Typen 3A bis 4C). \
        Geben Sie niemals Ratschläge für glattes, welliges oder chemisch geglättetes Haar.

        Der Haarpflegeplan hat **\(treatment.localizedLabel)** für heute basierend auf diesem Profil ausgewählt.

        Haarprofil:
        - Porosität: \(ctx.porosity.localizedLabel)
        - Trockenheit: \(ctx.dryness.localizedLabel)
        - Chemische Behandlung: \(ctx.chemical.localizedLabel)
        - Waschfrequenz: \(ctx.washFrequency.rawValue)x pro Woche

        Aktuelles Wetter: \(ctx.weatherCondition), \(ctx.temperature), Luftfeuchtigkeit \(ctx.humidity).

        Technischer Pflegekontext:
        \(technicalContext_de(treatment))

        Generieren Sie genau drei Felder:
        - "reason": 1–2 Sätze, die erklären, warum \(treatment.localizedLabel) der richtige Schritt für dieses \
        lockige/krause Profil heute ist, mit Bezug auf Porosität und/oder Wetter zum Pflegemechanismus.
        - "tip1": Ein praktischer Tipp speziell für lockiges/krauses Haar für \(treatment.localizedLabel) heute. \
        Verwenden Sie konkrete Begriffe: LOC/LCO-Methode, Plopping, Diffuser, Squish-to-Condish, Praying Hands, \
        Gelguss, Wash and Go, Wärmehaube, Strähne für Strähne usw. Erwähnen Sie das Wetter, wenn relevant.
        - "tip2": Ein zweiter, von tip1 verschiedener Tipp aus einem anderen praktischen Blickwinkel, \
        ausschließlich für lockiges/krauses Haar.

        Absolute Regeln:
        - Erklärungen und Tipps AUSSCHLIESSLICH für lockiges und krauses Haar (3A–4C)
        - Niemals Glätteisen, Relaxer, Keratin-Glättung oder irgendein Glättungsprodukt/-technik erwähnen
        - Antworten Sie ausschließlich auf Deutsch
        """
    }
}
