import SwiftUI
import WidgetKit

struct MeuCrespoWidgetView: View {
    let entry: TreatmentProvider.Entry

    static func background(for entry: TreatmentEntry) -> Color {
        guard case .treatment = entry.state else {
            return Color(red: 0.95, green: 0.87, blue: 0.86)
        }
        return Color(red: 242/255, green: 106/255, blue: 95/255)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(NSLocalizedString("widget.today.label", comment: ""))
                .textCase(.uppercase)
                .font(.system(size: 7, weight: .regular))
                .tracking(0.8)
                .foregroundStyle(labelColor)
                .frame(maxWidth: .infinity, alignment: .center)

            mainContent
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch entry.state {
        case .treatment(let t):
            Text(t.localizedName)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(red: 1, green: 0.957, blue: 0.957))
                .minimumScaleFactor(0.5)
                .lineLimit(2)

        case .restDay:
            Text(NSLocalizedString("widget.rest", comment: ""))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.22))
                .minimumScaleFactor(0.5)
                .lineLimit(2)

        case .notConfigured:
            Text(NSLocalizedString("widget.setup", comment: ""))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.22))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
    }

    private var labelColor: Color {
        guard case .treatment = entry.state else {
            return Color(red: 0.55, green: 0.27, blue: 0.22).opacity(0.7)
        }
        return Color(red: 1, green: 0.929, blue: 0.925)
    }
}

#Preview(as: .systemSmall) {
    MeuCrespoWidget()
} timeline: {
    TreatmentEntry(date: .now, state: .treatment(.hydration))
    TreatmentEntry(date: .now, state: .treatment(.reconstruction))
    TreatmentEntry(date: .now, state: .restDay)
    TreatmentEntry(date: .now, state: .notConfigured)
}
