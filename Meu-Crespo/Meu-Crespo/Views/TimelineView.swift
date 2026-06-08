import SwiftUI
import PostHog

struct TimelineView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel = TimelineViewModel()
    @State private var showFullCalendar = true

    @State private var treatmentInsight: TreatmentInsightResult? = nil
    @State private var isAIInsight = false
    @State private var isLoadingInsight = false

    @AppStorage("hairPorosity", store: SharedDefaults.store)      private var storedPorosity:  String = HairPorosity.medium.rawValue
    @AppStorage("hairDryness", store: SharedDefaults.store)       private var storedDryness:   String = HairDryness.medium.rawValue
    @AppStorage("chemicalTreatment") private var storedChemical:  String = ChemicalTreatment.none.rawValue
    @AppStorage("washFrequency", store: SharedDefaults.store)     private var storedWashFreq:  Int    = WashFrequency.three.rawValue

    // Invalidates the .task when treatment, date, humidity or language changes.
    // Short-circuits for rest days so no insight is loaded when it won't be shown.
    private var insightTaskKey: String {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: viewModel.selectedDate) ?? 0
        guard viewModel.shouldShowTreatment(viewModel.selectedDate) else {
            return "rest|\(day)"
        }
        let treatment = viewModel.treatmentForSelectedDay()
        return "\(treatment.rawValue)|\(day)|\(weatherManager.humidity)|\(languageManager.currentLanguage.rawValue)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        VStack(alignment: .leading, spacing: 26) {

                            Text(L("timeline.title"))
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(colorScheme == .light ? .redBrown : .white)

                            Text("\(L("timeline.editPrefix")) \(Image(systemName: "pencil.circle.fill")) \(L("timeline.editSuffix"))")
                                .font(Font.custom("SF Pro", size: 18))
                                .foregroundColor(colorScheme == .light ? .redBrown : .white)

                            HStack {
                                Text(showFullCalendar ? L("timeline.fullCalendar") : L("timeline.weekCalendar"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: {
                                    withAnimation { showFullCalendar.toggle() }
                                    PostHogSDK.shared.capture("calendar_view_toggled", properties: [
                                        "view": showFullCalendar ? "full" : "week",
                                    ])
                                }) {
                                    Image(systemName: showFullCalendar ? "calendar" : "calendar.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.pinky)
                                }
                            }
                            .padding(.bottom, 2)

                            if showFullCalendar {
                                HairCalendar(
                                    selectedDate: $viewModel.selectedDate,
                                    treatmentForDay: viewModel.treatmentForDateIncludingCustom,
                                    isWashDay: viewModel.shouldShowTreatment
                                )
                                .onChange(of: viewModel.selectedDate) { _, newDate in
                                    weatherManager.updateWeather(for: newDate)
                                }
                            } else {
                                WeekSlider(selectedDate: $viewModel.selectedDate)
                            }

                            cardRecomendation
                        }
                        .padding()
                    }
                }
            }
        }
        .task(id: insightTaskKey) {
            await loadInsight()
        }
    }

    func formatarData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: languageManager.currentLanguage.rawValue)
        return formatter.string(from: date)
    }

    // MARK: - Insight loading

    private func loadInsight() async {
        // Nothing to load on rest days
        guard viewModel.shouldShowTreatment(viewModel.selectedDate) else {
            treatmentInsight = nil
            isAIInsight = false
            isLoadingInsight = false
            return
        }

        let treatment = viewModel.treatmentForSelectedDay()

        // Show curl-specific fallback immediately — no loading spinner needed
        treatmentInsight = TreatmentInsightService.shared.localFallback(for: treatment)
        isAIInsight = false

        guard TreatmentInsightService.shared.isAvailable else { return }

        isLoadingInsight = true

        let context = HairContext(
            porosity:         HairPorosity(rawValue: storedPorosity)     ?? .medium,
            dryness:          HairDryness(rawValue: storedDryness)        ?? .medium,
            chemical:         ChemicalTreatment(rawValue: storedChemical) ?? .none,
            washFrequency:    WashFrequency(rawValue: storedWashFreq)     ?? .twice,
            weatherCondition: weatherManager.condition,
            temperature:      weatherManager.temperature,
            humidity:         weatherManager.humidity,
            selectedDate:     viewModel.selectedDate
        )

        if let aiResult = await TreatmentInsightService.shared.aiInsight(for: treatment, context: context) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                treatmentInsight = aiResult
                isAIInsight = true
                isLoadingInsight = false
            }
        } else {
            isLoadingInsight = false
        }
    }
}

// MARK: - Card

extension TimelineView {
    private var cardRecomendation: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L("timeline.recommendation"))
                .bold()
                .font(.system(size: 28))
                .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)

            let showTreatment = viewModel.shouldShowTreatment(viewModel.selectedDate)

            if showTreatment {
                treatmentCard
            } else {
                restDayCard
            }
        }
    }

    private static let cardGradient = RadialGradient(
        stops: [
            .init(color: Color(red: 0.949, green: 0.533, blue: 0.392), location: 0.0),
            .init(color: Color(red: 0.949, green: 0.706, blue: 0.420), location: 0.45),
            .init(color: Color(red: 0.949, green: 0.784, blue: 0.592), location: 0.72),
            .init(color: Color(red: 0.949, green: 0.863, blue: 0.761), location: 1.0),
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 420
    )

    private var treatmentCard: some View {
        let treatment = viewModel.treatmentForSelectedDay()
        return VStack(alignment: .leading, spacing: 12) {
            // Styled treatment card
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text(treatment.localizedLabel)
                        .font(.title2.bold())
                        .foregroundColor(.redBrown)

                    Spacer()

                    // Badge lives here — never overlaps the pencil
                    if isLoadingInsight {
                        aiBadge
                            .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    }

                    Menu {
                        ForEach(HairTreatment.allCases, id: \.self) { option in
                            Button(option.localizedLabel) {
                                let selectedDate = viewModel.selectedDate
                                let isToday = Calendar.current.isDateInToday(selectedDate)
                                let isPast = selectedDate < Calendar.current.startOfDay(for: Date())
                                viewModel.setCustomTreatment(option, for: selectedDate)
                                PostHogSDK.shared.capture("hair_treatment_changed", properties: [
                                    "treatment": option.rawValue,
                                    "previous_treatment": treatment.rawValue,
                                    "date_type": isToday ? "today" : (isPast ? "past" : "future"),
                                ])
                            }
                        }
                        Divider()
                        Button(L("timeline.restDay")) {
                            viewModel.setRestDay(for: viewModel.selectedDate)
                            PostHogSDK.shared.capture("hair_treatment_changed", properties: [
                                "treatment": "rest_day",
                                "previous_treatment": treatment.rawValue,
                                "date_type": Calendar.current.isDateInToday(viewModel.selectedDate) ? "today" : "other",
                            ])
                        }
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.redBrown)
                    }
                }

                if let insight = treatmentInsight {
                    insightView(insight)
                } else {
                    Text(L("timeline.treatmentDescription"))
                        .font(.subheadline)
                }
            }
            .foregroundColor(.redBrown)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 140)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Self.cardGradient)
                    .shadow(
                        color: Color(red: 0.32, green: 0.13, blue: 0.02).opacity(0.35),
                        radius: 10, x: 0, y: 4
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.25), value: isLoadingInsight)

            // Climate warning banner (sibling of card)
            if let warning = viewModel.climateWarning(
                for: treatment,
                humidity: weatherManager.humidity,
                date: viewModel.selectedDate
            ) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "humidity.fill")
                        .font(.subheadline)
                    Text(warning)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var restDayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(L("timeline.restDay"))
                    .font(.title2.bold())
                    .foregroundColor(.redBrown)
                Spacer()
                Menu {
                    ForEach(HairTreatment.allCases, id: \.self) { option in
                        Button(option.localizedLabel) {
                            viewModel.setCustomTreatment(option, for: viewModel.selectedDate)
                            PostHogSDK.shared.capture("hair_treatment_changed", properties: [
                                "treatment": option.rawValue,
                                "previous_treatment": "rest_day",
                                "date_type": Calendar.current.isDateInToday(viewModel.selectedDate) ? "today" : "other",
                            ])
                        }
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.redBrown)
                }
            }

            let today = Calendar.current.startOfDay(for: Date())
            let selectedStart = Calendar.current.startOfDay(for: viewModel.selectedDate)
            if selectedStart >= today, let next = viewModel.nextWashDay(after: viewModel.selectedDate) {
                let days = Calendar.current.dateComponents(
                    [.day],
                    from: selectedStart,
                    to: next
                ).day ?? 1
                Text(days == 1
                    ? L("timeline.nextWashTomorrow")
                    : String(format: L("timeline.nextWashDays"), days)
                )
                .font(.subheadline)
                .foregroundColor(.redBrown)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(Self.cardGradient)
                .shadow(
                    color: Color(red: 0.32, green: 0.13, blue: 0.02).opacity(0.35),
                    radius: 10, x: 0, y: 4
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
    }

    private var aiBadge: some View {
        HStack(spacing: 5) {
            ProgressView()
                .scaleEffect(0.65)
                .tint(.redBrown)
            Text(L("ai.badge.loading"))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.redBrown)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.4), in: Capsule())
    }

    @ViewBuilder
    private func insightView(_ insight: TreatmentInsightResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(insight.reason)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                tipRow(insight.tip1)
                tipRow(insight.tip2)
            }

            if isAIInsight {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("Apple Intelligence")
                        .font(.caption2.weight(.medium))
                }
                .foregroundColor(Color.redBrown.opacity(0.55))
                .padding(.top, 2)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.subheadline)
                .padding(.top, 1)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    TimelineView()
        .environmentObject(WeatherManager())
        .environmentObject(LanguageManager.shared)
}
