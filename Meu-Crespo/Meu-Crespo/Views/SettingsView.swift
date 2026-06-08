import SwiftUI
import PostHog

struct SettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager

    @AppStorage("userName", store: SharedDefaults.store) private var userName: String = ""
    @AppStorage("hairPorosity", store: SharedDefaults.store) private var storedPorosity: String = HairPorosity.medium.rawValue
    @AppStorage("hairDryness", store: SharedDefaults.store) private var storedDryness: String = HairDryness.medium.rawValue
    @AppStorage("washFrequency", store: SharedDefaults.store) private var storedWashFrequency: WashFrequency = .three
    @AppStorage("hasChemical", store: SharedDefaults.store) private var hasChemical: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true

    private var selectedPorosity: Binding<HairPorosity> {
        Binding(
            get: { HairPorosity(rawValue: storedPorosity) ?? .medium },
            set: {
                storedPorosity = $0.rawValue
                PostHogSDK.shared.capture("hair_profile_updated", properties: ["field": "porosity", "value": $0.rawValue])
                PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: ["hair_porosity": $0.rawValue])
            }
        )
    }

    private var selectedDryness: Binding<HairDryness> {
        Binding(
            get: { HairDryness(rawValue: storedDryness) ?? .medium },
            set: {
                storedDryness = $0.rawValue
                PostHogSDK.shared.capture("hair_profile_updated", properties: ["field": "dryness", "value": $0.rawValue])
                PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: ["hair_dryness": $0.rawValue])
            }
        )
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Language
                Section(L("settings.section.language")) {
                    Picker(L("settings.language.label"), selection: Binding(
                        get: { languageManager.currentLanguage },
                        set: { languageManager.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: Hair Profile
                Section(L("settings.section.hairProfile")) {
                    HStack {
                        Text(L("settings.profile.name"))
                        Spacer()
                        TextField(L("settings.profile.name"), text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }

                    Picker(L("settings.profile.porosity"), selection: selectedPorosity) {
                        ForEach(HairPorosity.allCases, id: \.self) { option in
                            Text(option.localizedLabel).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker(L("settings.profile.dryness"), selection: selectedDryness) {
                        ForEach(HairDryness.allCases, id: \.self) { option in
                            Text(option.localizedLabel).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker(L("settings.profile.washFrequency"), selection: Binding(
                        get: { storedWashFrequency },
                        set: {
                            storedWashFrequency = $0
                            PostHogSDK.shared.capture("hair_profile_updated", properties: ["field": "wash_frequency", "value": $0.rawValue])
                            PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: ["wash_frequency": $0.rawValue])
                        }
                    )) {
                        ForEach(WashFrequency.allCases, id: \.self) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle(L("settings.profile.chemical"), isOn: Binding(
                        get: { hasChemical },
                        set: {
                            hasChemical = $0
                            PostHogSDK.shared.capture("hair_profile_updated", properties: ["field": "has_chemical", "value": $0])
                            PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: ["has_chemical_treatment": $0])
                        }
                    ))
                        .tint(Color(red: 0.95, green: 0.42, blue: 0.37))
                }

                // MARK: App Info
                Section(L("settings.section.appInfo")) {
                    HStack {
                        Text(L("settings.appVersion"))
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    Link(
                        L("home.legalAttribution"),
                        destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
                    )
                    .tint(Color(red: 0.95, green: 0.42, blue: 0.37))

                    Button(role: .destructive) {
                        PostHogSDK.shared.capture("onboarding_reset")
                        PostHogSDK.shared.reset()
                        hasCompletedOnboarding = false
                    } label: {
                        Text(L("settings.resetOnboarding"))
                    }
                }
            }
            .navigationTitle(L("settings.title"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager.shared)
}
