import SwiftUI
import PostHog

struct OnboardingView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("hairPorosity") private var storedPorosity: String = HairPorosity.medium.rawValue
    @AppStorage("washFrequency") private var storedWashFrequency: WashFrequency = .three
    @AppStorage("hasChemical") private var storedChemical: Bool = false
    @AppStorage("hairDryness") private var storedDryness: String = HairDryness.medium.rawValue

    @State private var tempName: String = ""
    @State private var step = 0
    @State private var porosity: HairPorosity = .medium
    @State private var washFrequency: WashFrequency = .three
    @State private var hasChemical: Bool = false
    @State private var dryness: HairDryness = .medium

    private let stepNames = ["name", "porosity", "wash_frequency", "chemical", "dryness"]

    var body: some View {
        ZStack {
            Image("bgRecomendacao")
                .resizable()
                .ignoresSafeArea()

            switch step {
            case 0:
                NameStep(tempName: $tempName) {
                    userName = tempName
                    PostHogSDK.shared.capture("onboarding_step_completed", properties: ["step": "name"])
                    step += 1
                }
            case 1:
                PorosityStep(porosity: $porosity) {
                    // PostHog: Track onboarding step
                    PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                        "step": "porosity",
                        "porosity": porosity.rawValue,
                    ])
                    step += 1
                }
            case 2:
                WashFrequencyStep(washFrequency: $washFrequency) {
                    // PostHog: Track onboarding step
                    PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                        "step": "wash_frequency",
                        "wash_frequency": washFrequency.rawValue,
                    ])
                    step += 1
                }
            case 3:
                ChemicalStep(hasChemical: $hasChemical) {
                    // PostHog: Track onboarding step
                    PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                        "step": "chemical",
                        "has_chemical": hasChemical,
                    ])
                    step += 1
                }
            case 4:
                DrynessStep(dryness: $dryness) {
                    storedPorosity = porosity.rawValue
                    storedWashFrequency = washFrequency
                    storedChemical = hasChemical
                    storedDryness = dryness.rawValue
                    hasCompletedOnboarding = true
                    // PostHog: Track full onboarding completion with hair profile
                    PostHogSDK.shared.capture("onboarding_completed", properties: [
                        "porosity": porosity.rawValue,
                        "wash_frequency": washFrequency.rawValue,
                        "has_chemical": hasChemical,
                        "dryness": dryness.rawValue,
                    ])
                    let distinctId = PostHogSDK.shared.getDistinctId()
                    PostHogSDK.shared.identify(distinctId, userProperties: [
                        "name": userName,
                        "hair_porosity": porosity.rawValue,
                        "hair_dryness": dryness.rawValue,
                        "wash_frequency": washFrequency.rawValue,
                        "has_chemical_treatment": hasChemical,
                    ])
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            PostHogSDK.shared.capture("onboarding_started")
            PostHogSDK.shared.capture("onboarding_step_viewed", properties: ["step": "name"])
        }
        .onChange(of: step) { _, newStep in
            guard newStep > 0, newStep < stepNames.count else { return }
            PostHogSDK.shared.capture("onboarding_step_viewed", properties: ["step": stepNames[newStep]])
        }
    }
}

struct DrynessStep: View {
    @Binding var dryness: HairDryness
    var next: () -> Void

    var body: some View {
        VStack(spacing: 60) {
            Text(L("onboarding.dryness.question"))
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.redBrown)

            Picker(L("onboarding.dryness.pickerLabel"), selection: $dryness) {
                ForEach(HairDryness.allCases, id: \.self) { option in
                    Text(option.localizedLabel).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Button(action: { next() }) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .semibold))
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct ChemicalStep: View {
    @Binding var hasChemical: Bool
    var next: () -> Void

    var body: some View {
        VStack(spacing: 60) {
            Text(L("onboarding.chemical.question"))
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.redBrown)

            Picker(L("onboarding.chemical.pickerLabel"), selection: $hasChemical) {
                Text(L("common.no")).tag(false)
                Text(L("common.yes")).tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Button(action: { next() }) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .semibold))
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct PorosityStep: View {
    @Binding var porosity: HairPorosity
    var next: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text(L("onboarding.porosity.question"))
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.redBrown)

            Picker(L("onboarding.porosity.pickerLabel"), selection: $porosity) {
                ForEach(HairPorosity.allCases, id: \.self) { option in
                    Text(option.localizedLabel).tag(option)
                }
            }
            .pickerStyle(.wheel)

            Button(action: { next() }) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .semibold))
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct WashFrequencyStep: View {
    @Binding var washFrequency: WashFrequency
    var next: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text(L("onboarding.washFrequency.question"))
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.redBrown)

            Picker(L("onboarding.washFrequency.pickerLabel"), selection: $washFrequency) {
                ForEach(WashFrequency.allCases, id: \.self) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.wheel)

            Button(action: { next() }) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .semibold))
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct NameStep: View {
    @Binding var tempName: String
    var next: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            Image("frameOnboarding")
                .resizable()
                .scaledToFit()
                .frame(width: 293)

            Text(L("onboarding.name.question"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.redBrown)
                .padding(.bottom, 40)

            TextField(L("onboarding.name.placeholder"), text: $tempName)
                .submitLabel(.done)
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
                .frame(width: 280)
                .background(.white.opacity(0.8))
                .tint(.redBrown)
                .cornerRadius(20)
                .shadow(color: Color.redBrown.opacity(0.65), radius: 2, x: 0, y: 4)

            Spacer()

            if !tempName.isEmpty {
                Button(action: { next() }) {
                    Text(L("common.continue"))
                        .font(.system(size: 20, weight: .semibold))
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        }
                }
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
