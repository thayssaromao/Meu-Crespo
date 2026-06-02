import SwiftUI

struct ParaHojeSection: View {
    @EnvironmentObject var weatherManager: WeatherManager
    @Environment(\.colorScheme) var colorScheme

    private var cardSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 220 : 170
    }

    // red → cream (card 1 e 3)
    private let stopsWarm: [Gradient.Stop] = [
        .init(color: Color(red: 0.945, green: 0.361, blue: 0.361), location: 0),
        .init(color: Color(red: 0.949, green: 0.533, blue: 0.392), location: 0.232),
        .init(color: Color(red: 0.949, green: 0.706, blue: 0.420), location: 0.465),
        .init(color: Color(red: 0.949, green: 0.784, blue: 0.592), location: 0.670),
        .init(color: Color(red: 0.949, green: 0.863, blue: 0.761), location: 0.875),
        .init(color: Color(red: 0.949, green: 0.863, blue: 0.761), location: 1.0),
    ]

    // cream → red (card 2 — invertido)
    private let stopsCool: [Gradient.Stop] = [
        .init(color: Color(red: 0.949, green: 0.863, blue: 0.761), location: 0),
        .init(color: Color(red: 0.949, green: 0.784, blue: 0.592), location: 0.219),
        .init(color: Color(red: 0.949, green: 0.706, blue: 0.420), location: 0.437),
        .init(color: Color(red: 0.949, green: 0.533, blue: 0.392), location: 0.719),
        .init(color: Color(red: 0.945, green: 0.361, blue: 0.361), location: 1.0),
    ]

    @State private var chevronPulse = false

    private func uvLabel(_ index: String) -> String {
        guard let n = Int(index) else { return "UV ..." }
        switch n {
        case 8...: return "UV \(L("weather.uv.extreme").capitalized)"
        case 6...7: return "UV \(L("weather.uv.high").capitalized)"
        case 3...5: return "UV \(L("weather.uv.moderate").capitalized)"
        default: return "UV \(L("weather.uv.low").capitalized)"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L("home.paraHoje"))
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 26, weight: .bold))
                    .foregroundColor(colorScheme == .light ? .redBrown : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(colorScheme == .light ? .redBrown : .secondary)
                    .opacity(chevronPulse ? 1.0 : 0.35)
                    .offset(x: chevronPulse ? 3 : 0)
                    .onAppear {
                        Task {
                            while true {
                                withAnimation(.easeInOut(duration: 0.55)) { chevronPulse = true }
                                try? await Task.sleep(for: .seconds(0.55))
                                withAnimation(.easeInOut(duration: 0.55)) { chevronPulse = false }
                                try? await Task.sleep(for: .seconds(1.6))
                            }
                        }
                    }
            }
            .padding(.horizontal, 25)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Card 1 — Cidade + Temperatura
                    // Diagonal: vermelho (top-left) → creme (bottom-right)
                    weatherCard(
                        gradient: LinearGradient(
                            stops: stopsWarm,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) {
                        VStack(spacing: 18) {
                            Text(weatherManager.cityName)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                            Text(weatherManager.temperature)
                                .font(.system(size: 45, weight: .semibold))
                        }
                        .foregroundColor(.redBrown)
                    }

                    // Card 2 — Precipitação
                    // Diagonal inversa: creme (top-left) → vermelho (bottom-right)
                    weatherCard(
                        gradient: LinearGradient(
                            stops: stopsCool,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) {
                        VStack(spacing: 18) {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "cloud.rain.fill")
                                    .font(.system(size: 42))
                                Text(weatherManager.precipitationChance)
                                    .font(.system(size: 24, weight: .bold))
                            }
                            Text(L("weather.precipitation"))
                                .font(.system(size: 18, weight: .medium))
                                .frame(maxWidth: 130, alignment: .center)
                        }
                        .foregroundColor(.redBrown)
                    }

                    // Card 3 — UV
                    // Radial: vermelho no topo-centro, creme nas bordas
                    weatherCard(
                        gradient: RadialGradient(
                            stops: stopsWarm,
                            center: UnitPoint(x: 0.5, y: 0.0),
                            startRadius: 0,
                            endRadius: 250
                        )
                    ) {
                        VStack(spacing: 18) {
                            Image(systemName: weatherManager.uvSymbol)
                                .font(.system(size: 46, weight: .bold))
                            Text(uvLabel(weatherManager.uvIndex))
                                .font(.system(size: 18, weight: .medium))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 130)
                        }
                        .foregroundColor(.redBrown)
                    }

                    // Card 4 — Vento
                    // Diagonal inversa: creme (bottom-left) → vermelho (top-right)
                    weatherCard(
                        gradient: LinearGradient(
                            stops: stopsCool,
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    ) {
                        VStack(spacing: 18) {
                            HStack(alignment: .center, spacing: 10){
                                Image(systemName: weatherManager.windSymbol)
                                    .font(.system(size: 46, weight: .bold))
                                Text(weatherManager.windSpeed)
                                    .font(.system(size: 17, weight: .bold))
                            }
                            Text("\(L("weather.wind")) \(weatherManager.windStatus)")
                                .font(.system(size: 18, weight: .medium))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 130)
                        }
                        .foregroundColor(.redBrown)
                    }
                }
                .padding(.horizontal, 20)
                // Padding vertical para a sombra não ser cortada
                .padding(.vertical, 8)
            }
            // Permite que a sombra apareça fora dos limites do ScrollView
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private func weatherCard<Style: ShapeStyle, Content: View>(
        gradient: Style,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(gradient)
            content()
        }
        .frame(width: cardSize, height: cardSize)
        // clipShape antes do shadow: sombra incide só na forma do card, não no texto
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(
            color: Color(red: 0.32, green: 0.13, blue: 0.02).opacity(0.49),
            radius: 4,
            x: 0,
            y: 4
        )
    }
}
