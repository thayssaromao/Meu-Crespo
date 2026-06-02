import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("userName") private var userName: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showSettings = false

    private var displayName: String {
        userName.isEmpty ? L("learn.defaultUser") : userName
    }

    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        HStack(alignment: .center) {
                            Text(String(format: L("home.greeting"), displayName))
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 38 : 28, weight: .bold))
                                .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)

                            Spacer()

                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 54, height: 54)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .shadow(color: .black.opacity(0.12), radius: 30, x: 0, y: 12)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 8)

                        WeekSlider(selectedDate: $selectedDate)
                            .frame(maxWidth: 600)
                            .frame(maxWidth: .infinity)

                        ParaHojeSection()
                            .environmentObject(weatherManager)

                        GeometryReader { geo in
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                            }
                            .stroke(
                                Color.redBrown.opacity(0.22),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [6, 5])
                            )
                        }
                        .frame(maxWidth: .infinity, minHeight: 1.5, maxHeight: 1.5)

                        VStack(alignment: .leading, spacing: 25) {
                            Text(L("home.hairSuggestions"))
                                .bold()
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 38 : 28, weight: .bold))
                                .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)
                                .padding(.leading, 25)

                            HairSuggestionsSection()
                                .environmentObject(weatherManager)
                        }
                    }

                    VStack(alignment: .center, spacing: 4) {
                        Text(L("home.weatherAttribution"))
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Link(
                            L("home.legalAttribution"),
                            destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
                        )
                        .font(.footnote)
                    }
                    .tint(.pinky)
                    .padding(16)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(languageManager)
            }
        }
    }
}
