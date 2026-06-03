import SwiftUI

// MARK: - Treatment color palette

extension HairTreatment {
    var calendarColor: Color {
        switch self {
        case .hydration:     return Color(red: 0.38, green: 0.74, blue: 0.96) // sky blue
        case .nutrition:     return Color(red: 0.38, green: 0.78, blue: 0.52) // sage green
        case .reconstruction: return Color(red: 0.45, green: 0.47, blue: 0.92) // indigo blue
        case .umectation:    return Color(red: 0.99, green: 0.80, blue: 0.22) // golden yellow
        }
    }
}

// MARK: - Calendar component

struct HairCalendar: View {
    @Binding var selectedDate: Date
    let treatmentForDay: (Date) -> HairTreatment
    let isWashDay: (Date) -> Bool

    @Environment(\.colorScheme) var colorScheme

    @State private var displayedMonth: Date

    private let cal = Calendar.current

    init(
        selectedDate: Binding<Date>,
        treatmentForDay: @escaping (Date) -> HairTreatment,
        isWashDay: @escaping (Date) -> Bool
    ) {
        self._selectedDate = selectedDate
        self.treatmentForDay = treatmentForDay
        self.isWashDay = isWashDay
        let monthStart = Calendar.current.startOfMonth(for: selectedDate.wrappedValue)
        _displayedMonth = State(initialValue: monthStart)
    }

    var body: some View {
        VStack(spacing: 14) {
            monthHeader
            weekdayRow
            dayGrid
            legend
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        .onChange(of: selectedDate) { _, newDate in
            // Keep displayed month in sync when selection changes externally
            let newMonth = cal.startOfMonth(for: newDate)
            if !cal.isDate(newMonth, equalTo: displayedMonth, toGranularity: .month) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayedMonth = newMonth
                }
            }
        }
    }

    // MARK: - Month header

    private var monthHeader: some View {
        HStack {
            Button { shiftMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(atMinMonth ? .secondary.opacity(0.3) : .pinky)
                    .frame(width: 36, height: 36)
            }
            .disabled(atMinMonth)

            Spacer()

            Text(monthTitle)
                .font(.system(size: 17, weight: .semibold))

            Spacer()

            Button { shiftMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(atMaxMonth ? .secondary.opacity(0.3) : .pinky)
                    .frame(width: 36, height: 36)
            }
            .disabled(atMaxMonth)
        }
    }

    private var atMinMonth: Bool { cal.isDate(displayedMonth, equalTo: minMonth, toGranularity: .month) }
    private var atMaxMonth: Bool { cal.isDate(displayedMonth, equalTo: maxMonth, toGranularity: .month) }

    // MARK: - Weekday labels

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(weekdayHeaders, id: \.self) { label in
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Day grid

    private var dayGrid: some View {
        let days = calendarDays
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    let inMonth = cal.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                    CalendarDayCell(
                        date: date,
                        treatment: treatmentForDay(date),
                        isSelected: cal.isDate(date, inSameDayAs: selectedDate),
                        isToday: cal.isDateInToday(date),
                        isCurrentMonth: inMonth,
                        isWashDay: isWashDay(date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDate = date
                            if !inMonth {
                                displayedMonth = cal.startOfMonth(for: date)
                            }
                        }
                    }
                } else {
                    Color.clear.frame(height: 38)
                }
            }
        }
    }

    // MARK: - Legend

    private var legend: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 8
        ) {
            ForEach(HairTreatment.allCases, id: \.self) { treatment in
                HStack(spacing: 6) {
                    Circle()
                        .fill(treatment.calendarColor)
                        .frame(width: 11, height: 11)
                    Text(treatment.localizedLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    // Static caches: formatters are expensive to create, language rarely changes
    private static var cachedMonthFormatter: DateFormatter?
    private static var cachedMonthFormatterLang: String?
    private static var cachedWeekdayHeadersLang: String?
    private static var cachedWeekdayHeadersResult: [String]?

    private var monthTitle: String {
        let lang = LanguageManager.shared.currentLanguage.rawValue
        if Self.cachedMonthFormatterLang != lang || Self.cachedMonthFormatter == nil {
            let f = DateFormatter()
            f.dateFormat = "MMMM yyyy"
            f.locale = Locale(identifier: lang)
            Self.cachedMonthFormatter = f
            Self.cachedMonthFormatterLang = lang
        }
        return Self.cachedMonthFormatter!.string(from: displayedMonth).capitalized
    }

    private var weekdayHeaders: [String] {
        let lang = LanguageManager.shared.currentLanguage.rawValue
        if Self.cachedWeekdayHeadersLang != lang || Self.cachedWeekdayHeadersResult == nil {
            let f = DateFormatter()
            f.locale = Locale(identifier: lang)
            let symbols = f.veryShortStandaloneWeekdaySymbols ?? ["S","M","T","W","T","F","S"]
            let offset = cal.firstWeekday - 1
            Self.cachedWeekdayHeadersResult = Array(symbols[offset...] + symbols[..<offset])
            Self.cachedWeekdayHeadersLang = lang
        }
        return Self.cachedWeekdayHeadersResult!
    }

    private var calendarDays: [Date?] {
        let monthStart = displayedMonth
        let daysInMonth = cal.range(of: .day, in: .month, for: monthStart)!.count

        // Offset: how many cells to leave empty before day 1
        let firstWeekday = cal.component(.weekday, from: monthStart)
        let leadingOffset = (firstWeekday - cal.firstWeekday + 7) % 7

        var days: [Date?] = []

        // Leading days from previous month
        for i in (0..<leadingOffset).reversed() {
            days.append(cal.date(byAdding: .day, value: -(i + 1), to: monthStart))
        }

        // Current month
        for i in 0..<daysInMonth {
            days.append(cal.date(byAdding: .day, value: i, to: monthStart))
        }

        // Trailing days to complete the last row
        let trailing = (7 - days.count % 7) % 7
        if trailing > 0 {
            let lastDay = cal.date(byAdding: .day, value: daysInMonth - 1, to: monthStart)!
            for i in 1...trailing {
                days.append(cal.date(byAdding: .day, value: i, to: lastDay))
            }
        }

        return days
    }

    private var minMonth: Date { cal.startOfMonth(for: cal.date(byAdding: .month, value: -1, to: Date())!) }
    private var maxMonth: Date { cal.startOfMonth(for: cal.date(byAdding: .month, value:  1, to: Date())!) }

    private func shiftMonth(by value: Int) {
        guard let next = cal.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        let clamped = min(max(next, minMonth), maxMonth)
        withAnimation(.easeInOut(duration: 0.25)) {
            displayedMonth = clamped
        }
    }
}

// MARK: - Day cell

private struct CalendarDayCell: View {
    let date: Date
    let treatment: HairTreatment
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isWashDay: Bool

    private var dayNumber: String {
        String(Calendar.current.component(.day, from: date))
    }

    var body: some View {
        ZStack {
            if isWashDay {
                // Treatment-colored circle only on wash days
                Circle()
                    .fill(treatment.calendarColor.opacity(
                        isSelected     ? 1.0  :
                        isToday        ? 0.65 :
                        isCurrentMonth ? 0.40 : 0.15
                    ))

                if isSelected {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.5)
                }
            } else if isSelected {
                // Selected rest day: subtle gray fill
                Circle()
                    .fill(Color.secondary.opacity(0.18))
            }

            // Pinky ring marks today when not selected
            if isToday && !isSelected {
                Circle()
                    .strokeBorder(isWashDay ? Color.pinky : Color.pinky.opacity(0.5), lineWidth: 2)
            }

            Text(dayNumber)
                .font(.system(
                    size: 14,
                    weight: (isSelected || isToday) ? .bold : .regular
                ))
                .foregroundColor(
                    isSelected && isWashDay ? .white        :
                    isCurrentMonth          ? .primary      :
                                              .secondary.opacity(0.45)
                )
        }
        .frame(width: 36, height: 36)
    }
}

// MARK: - Calendar extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
