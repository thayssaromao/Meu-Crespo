import SwiftUI
internal import Combine
import WidgetKit

enum HairTreatment: String, CaseIterable {
    case hydration = "hydration"
    case nutrition = "nutrition"
    case reconstruction = "reconstruction"
    case umectation = "umectation"

    var localizedLabel: String { L("treatment.\(rawValue)") }
}

class TimelineViewModel: ObservableObject {

    @AppStorage("userName", store: SharedDefaults.store) var userName: String = ""
    @AppStorage("hairPorosity", store: SharedDefaults.store) var porosity: String = ""
    @AppStorage("washFrequency", store: SharedDefaults.store) var washFrequencyRaw: Int = 3
    @AppStorage("hasChemical", store: SharedDefaults.store) var hasChemical: Bool = false
    @AppStorage("hairDryness", store: SharedDefaults.store) var dryness: String = ""

    @Published var selectedDate: Date = Date()
    @Published var customTreatments: [Date: HairTreatment] = [:]
    @Published var customRestDays: Set<Date> = []

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")   // prevents misparse in non-Gregorian locales
        f.timeZone = TimeZone.current
        return f
    }()

    private static let customTreatmentsKey = "customTreatments_v2"
    private static let customRestDaysKey   = "customRestDays_v1"
    private static let anchorDateKey       = "scheduleAnchorDate"

    // In-memory caches (never change within an app session)
    private var _anchorDate: Date?
    private var _cachedCycle: [HairTreatment]?
    private var _cachedCycleKey: String?

    init() {
        loadCustomTreatments()
        loadCustomRestDays()
    }

    // MARK: - Persistence

    private func loadCustomTreatments() {
        guard let dict = SharedDefaults.store.dictionary(forKey: Self.customTreatmentsKey) as? [String: String] else { return }
        var result: [Date: HairTreatment] = [:]
        for (key, value) in dict {
            if let date = Self.dateFormatter.date(from: key),
               let treatment = HairTreatment(rawValue: value) {
                result[date] = treatment
            }
        }
        customTreatments = result
    }

    private func saveCustomTreatments() {
        var dict: [String: String] = [:]
        for (date, treatment) in customTreatments {
            dict[Self.dateFormatter.string(from: date)] = treatment.rawValue
        }
        SharedDefaults.store.set(dict, forKey: Self.customTreatmentsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadCustomRestDays() {
        guard let strings = SharedDefaults.store.array(forKey: Self.customRestDaysKey) as? [String] else { return }
        customRestDays = Set(strings.compactMap { Self.dateFormatter.date(from: $0) })
    }

    private func saveCustomRestDays() {
        SharedDefaults.store.set(
            customRestDays.map { Self.dateFormatter.string(from: $0) },
            forKey: Self.customRestDaysKey
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Anchor date (cached — never changes within a session)

    private var anchorDate: Date {
        if let cached = _anchorDate { return cached }
        let stored = SharedDefaults.store.double(forKey: Self.anchorDateKey)
        let date: Date
        if stored == 0 {
            date = Calendar.current.startOfDay(for: Date())
            SharedDefaults.store.set(date.timeIntervalSince1970, forKey: Self.anchorDateKey)
        } else {
            date = Date(timeIntervalSince1970: stored)
        }
        _anchorDate = date
        return date
    }

    // MARK: - Custom day actions

    func setCustomTreatment(_ treatment: HairTreatment, for date: Date) {
        let normalized = Calendar.current.startOfDay(for: date)
        customTreatments[normalized] = treatment
        customRestDays.remove(normalized)
        saveCustomTreatments()
        saveCustomRestDays()
    }

    // Removes the custom treatment; if the day is a natural wash day, forces it to rest.
    func setRestDay(for date: Date) {
        let normalized = Calendar.current.startOfDay(for: date)
        customTreatments.removeValue(forKey: normalized)
        if isWashDay(date) {
            customRestDays.insert(normalized)
        }
        saveCustomTreatments()
        saveCustomRestDays()
    }

    // MARK: - Schedule

    func treatmentForSelectedDay() -> HairTreatment {
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        if let custom = customTreatments[normalizedDate] {
            return custom
        }
        return treatmentForDay(selectedDate)
    }

    // For calendar coloring — respects custom overrides on any date
    func treatmentForDateIncludingCustom(_ date: Date) -> HairTreatment {
        let normalized = Calendar.current.startOfDay(for: date)
        return customTreatments[normalized] ?? treatmentForDay(date)
    }

    // Whether a given date should display a treatment (wash day OR custom override, NOT forced rest)
    func shouldShowTreatment(_ date: Date) -> Bool {
        let normalized = Calendar.current.startOfDay(for: date)
        if customRestDays.contains(normalized) { return false }
        if customTreatments[normalized] != nil { return true }
        return isWashDay(date)
    }

    func treatmentForDay(_ date: Date) -> HairTreatment {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let daysSince = calendar.dateComponents([.day], from: anchorDate, to: normalizedDate).day ?? 0

        let cycle = cachedCycle
        let freq = max(1, min(7, washFrequencyRaw))
        let intervalDays = 7.0 / Double(freq)
        let sessionIndex = Int(floor(Double(daysSince) / intervalDays))
        let cycleIndex = ((sessionIndex % cycle.count) + cycle.count) % cycle.count
        return cycle[cycleIndex]
    }

    // Cycle cached by profile key — rebuilt only when porosity/dryness/chemical changes
    private var cachedCycle: [HairTreatment] {
        let key = "\(hasChemical)|\(porosity)|\(dryness)"
        if let cached = _cachedCycle, _cachedCycleKey == key { return cached }
        let cycle = buildTreatmentCycle()
        _cachedCycle = cycle
        _cachedCycleKey = key
        return cycle
    }

    // Returns true only on dates that begin a new wash session
    func isWashDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let daysSince = calendar.dateComponents([.day], from: anchorDate, to: normalizedDate).day ?? 0
        let freq = max(1, min(7, washFrequencyRaw))
        let intervalDays = 7.0 / Double(freq)
        let sessionToday     = Int(floor(Double(daysSince) / intervalDays))
        let sessionYesterday = Int(floor(Double(daysSince - 1) / intervalDays))
        return sessionToday != sessionYesterday
    }

    // Next treatment day strictly after the given date (respects custom rest days)
    func nextWashDay(after date: Date) -> Date? {
        let calendar = Calendar.current
        var check = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)
        for _ in 0..<14 {
            if shouldShowTreatment(check) { return check }
            check = calendar.date(byAdding: .day, value: 1, to: check)!
        }
        return nil
    }

    // MARK: - Cycle builder (weighted by profile)

    private func buildTreatmentCycle() -> [HairTreatment] {
        let isHighPorosity = porosity == HairPorosity.high.rawValue
        let isHighDryness  = dryness  == HairDryness.high.rawValue

        switch (hasChemical, isHighPorosity) {
        case (true, true):
            // Max reconstruction + good nutrition support
            return [.reconstruction, .hydration, .reconstruction,
                    .nutrition, .umectation, .reconstruction, .nutrition, .umectation]
        case (true, false):
            // Chemical only: extra reconstruction, balanced otherwise
            if isHighDryness {
                return [.hydration, .reconstruction, .umectation,
                        .hydration, .nutrition, .reconstruction, .umectation]
            }
            return [.hydration, .reconstruction, .umectation,
                    .nutrition, .reconstruction, .umectation]
        case (false, true):
            // High porosity: extra nutrition + reconstruction
            if isHighDryness {
                return [.nutrition, .umectation, .hydration,
                        .reconstruction, .nutrition, .hydration, .umectation]
            }
            return [.nutrition, .umectation, .hydration,
                    .reconstruction, .nutrition, .umectation]
        case (false, false):
            // Baseline; boost hydration/umectation when very dry
            if isHighDryness {
                return [.hydration, .umectation, .nutrition,
                        .hydration, .umectation, .reconstruction]
            }
            return [.hydration, .nutrition, .reconstruction, .umectation]
        }
    }

    // MARK: - Climate contextual warning (does not change treatment)

    func climateWarning(for treatment: HairTreatment, humidity: String, date: Date) -> String? {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        guard normalizedDate == today || normalizedDate == tomorrow else { return nil }

        guard let humidityValue = Int(
            humidity.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        ) else { return nil }

        switch treatment {
        case .nutrition where humidityValue > 75:
            return L("timeline.climate.highHumidity.nutrition")
        case .hydration where humidityValue > 75:
            return L("timeline.climate.highHumidity.hydration")
        case .umectation where humidityValue > 75:
            return L("timeline.climate.highHumidity.umectation")
        case .hydration where humidityValue < 30:
            return L("timeline.climate.lowHumidity")
        default:
            return nil
        }
    }
}
