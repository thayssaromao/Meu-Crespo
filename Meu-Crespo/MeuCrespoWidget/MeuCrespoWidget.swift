import WidgetKit
import SwiftUI

// MARK: - Entry

struct TreatmentEntry: TimelineEntry {
    let date: Date
    let state: EntryState

    enum EntryState {
        case treatment(WidgetTreatment)
        case restDay
        case notConfigured
    }
}

// MARK: - Treatment

enum WidgetTreatment: String {
    case hydration, nutrition, reconstruction, umectation

    var localizedName: String {
        NSLocalizedString("treatment.\(rawValue)", comment: "")
    }
}

// MARK: - Provider

struct TreatmentProvider: TimelineProvider {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    func placeholder(in context: Context) -> TreatmentEntry {
        TreatmentEntry(date: Date(), state: .treatment(.hydration))
    }

    func getSnapshot(in context: Context, completion: @escaping (TreatmentEntry) -> Void) {
        completion(makeEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TreatmentEntry>) -> Void) {
        let now = Date()
        let entry = makeEntry(for: now)
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: now)!
        )
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    // MARK: - Schedule logic

    private func makeEntry(for date: Date) -> TreatmentEntry {
        let defaults = UserDefaults(suiteName: "group.apple.thayssaromao.MeuCrespo") ?? .standard
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let fmt = Self.dateFormatter

        let porosity = defaults.string(forKey: "hairPorosity") ?? ""
        guard !porosity.isEmpty else {
            return TreatmentEntry(date: date, state: .notConfigured)
        }

        // Custom rest day override
        let restStrings = defaults.array(forKey: "customRestDays_v1") as? [String] ?? []
        let restDays = Set(restStrings.compactMap { fmt.date(from: $0) })
        if restDays.contains(today) {
            return TreatmentEntry(date: date, state: .restDay)
        }

        // Custom treatment override
        if let customDict = defaults.dictionary(forKey: "customTreatments_v2") as? [String: String],
           let raw = customDict[fmt.string(from: today)],
           let treatment = WidgetTreatment(rawValue: raw) {
            return TreatmentEntry(date: date, state: .treatment(treatment))
        }

        // Computed schedule
        let dryness = defaults.string(forKey: "hairDryness") ?? ""
        let hasChemical = defaults.bool(forKey: "hasChemical")
        let storedFreq = defaults.integer(forKey: "washFrequency")
        let washFreq = max(1, min(7, storedFreq == 0 ? 3 : storedFreq))

        let anchorTimestamp = defaults.double(forKey: "scheduleAnchorDate")
        let anchor: Date = anchorTimestamp == 0
            ? today
            : calendar.startOfDay(for: Date(timeIntervalSince1970: anchorTimestamp))

        let daysSince = calendar.dateComponents([.day], from: anchor, to: today).day ?? 0
        let interval = 7.0 / Double(washFreq)
        let sessionToday     = Int(floor(Double(daysSince) / interval))
        let sessionYesterday = Int(floor(Double(daysSince - 1) / interval))

        guard sessionToday != sessionYesterday else {
            return TreatmentEntry(date: date, state: .restDay)
        }

        let cycle = buildCycle(hasChemical: hasChemical,
                               highPorosity: porosity == "high",
                               highDryness: dryness == "high")
        let idx = ((sessionToday % cycle.count) + cycle.count) % cycle.count
        return TreatmentEntry(date: date, state: .treatment(cycle[idx]))
    }

    private func buildCycle(hasChemical: Bool, highPorosity: Bool, highDryness: Bool) -> [WidgetTreatment] {
        switch (hasChemical, highPorosity) {
        case (true, true):
            return [.reconstruction, .hydration, .reconstruction,
                    .nutrition, .umectation, .reconstruction, .nutrition, .umectation]
        case (true, false):
            return highDryness
                ? [.hydration, .reconstruction, .umectation, .hydration, .nutrition, .reconstruction, .umectation]
                : [.hydration, .reconstruction, .umectation, .nutrition, .reconstruction, .umectation]
        case (false, true):
            return highDryness
                ? [.nutrition, .umectation, .hydration, .reconstruction, .nutrition, .hydration, .umectation]
                : [.nutrition, .umectation, .hydration, .reconstruction, .nutrition, .umectation]
        case (false, false):
            return highDryness
                ? [.hydration, .umectation, .nutrition, .hydration, .umectation, .reconstruction]
                : [.hydration, .nutrition, .reconstruction, .umectation]
        }
    }
}

// MARK: - Widget

struct MeuCrespoWidget: Widget {
    let kind = "MeuCrespoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TreatmentProvider()) { entry in
            MeuCrespoWidgetView(entry: entry)
                .containerBackground(MeuCrespoWidgetView.background(for: entry), for: .widget)
        }
        .configurationDisplayName("Meu Crespo")
        .description(NSLocalizedString("widget.today.label", comment: ""))
        .supportedFamilies([.systemSmall])
    }
}
