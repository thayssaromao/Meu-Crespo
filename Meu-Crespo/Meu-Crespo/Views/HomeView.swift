import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .light ? Color.white : Color.brownBg)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        VStack(spacing: 40) {
                            WeekSlider(selectedDate: $selectedDate)
                                .frame(maxWidth: 600)
                                .frame(maxWidth: .infinity)
                            CardHead()
                        }

                        Spacer()

                        VStack(alignment: .leading) {
                            Text(L("home.recommendations"))
                                .bold()
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 38 : 28))
                                .foregroundColor(colorScheme == .light ? Color.redBrown : .primary)
                                .padding(.leading, 25)

                            ZStack {
                                Image("bgRecomendacao")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: UIDevice.current.userInterfaceIdiom == .pad ? 600 : 370,
                                        height: UIDevice.current.userInterfaceIdiom == .pad ? 560 : 450
                                    )
                                    .clipped()
                                    .cornerRadius(30)

                                CardListView()
                            }
                        }
                    }
                    Spacer()

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
        }
    }
}
