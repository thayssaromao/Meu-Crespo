import SwiftUI
import PostHog

private let obActiveColor = Color(red: 0.318, green: 0.129, blue: 0.024)
private let obInactiveColor = Color(red: 0.682, green: 0.537, blue: 0.455)

struct OnboardingView: View {
    @AppStorage("userName", store: SharedDefaults.store) var userName: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("hairPorosity", store: SharedDefaults.store) private var storedPorosity: String = HairPorosity.medium.rawValue
    @AppStorage("washFrequency", store: SharedDefaults.store) private var storedWashFrequency: WashFrequency = .three
    @AppStorage("hasChemical", store: SharedDefaults.store) private var storedChemical: Bool = false
    @AppStorage("chemicalTreatment") private var storedChemicalTreatment: String = ChemicalTreatment.none.rawValue
    @AppStorage("hairDryness", store: SharedDefaults.store) private var storedDryness: String = HairDryness.medium.rawValue

    @State private var tempName: String = ""
    @State private var step = 0
    @State private var porosity: HairPorosity = .medium
    @State private var washFrequency: WashFrequency = .three
    @State private var chemicalTreatment: ChemicalTreatment? = nil
    @State private var dryness: HairDryness = .medium

    private let stepNames = ["welcome", "name", "apple_intelligence", "chemical", "porosity", "wash_frequency", "dryness", "final"]

    private func nextStep() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            step += 1
        }
    }

    var body: some View {
        ZStack {
            if step == 6 {
                Image("bgRecomendacao")
                    .resizable()
                    .ignoresSafeArea()
            } else {
                OnboardingBackground()
            }

            Group {
                switch step {
                case 0:
                    WelcomeStep {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: ["step": "welcome"])
                        nextStep()
                    }
                case 1:
                    NameStep(tempName: $tempName) {
                        userName = tempName
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: ["step": "name"])
                        nextStep()
                    }
                case 2:
                    AppleIntelligenceStep {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: ["step": "apple_intelligence"])
                        nextStep()
                    }
                case 3:
                    ChemicalStep(chemicalTreatment: $chemicalTreatment) {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                            "step": "chemical",
                            "chemical_treatment": chemicalTreatment?.rawValue ?? "none",
                        ])
                        nextStep()
                    }
                case 4:
                    PorosityStep(porosity: $porosity) {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                            "step": "porosity",
                            "porosity": porosity.rawValue,
                        ])
                        nextStep()
                    }
                case 5:
                    WashFrequencyStep(washFrequency: $washFrequency) {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                            "step": "wash_frequency",
                            "wash_frequency": washFrequency.rawValue,
                        ])
                        nextStep()
                    }
                case 6:
                    DrynessStep(dryness: $dryness) {
                        PostHogSDK.shared.capture("onboarding_step_completed", properties: [
                            "step": "dryness",
                            "dryness": dryness.rawValue,
                        ])
                        nextStep()
                    }
                case 7:
                    FinalStep {
                        storedPorosity = porosity.rawValue
                        storedWashFrequency = washFrequency
                        storedChemicalTreatment = chemicalTreatment?.rawValue ?? ChemicalTreatment.none.rawValue
                        storedChemical = chemicalTreatment?.hasTreatment ?? false
                        storedDryness = dryness.rawValue
                        hasCompletedOnboarding = true
                        PostHogSDK.shared.capture("onboarding_completed", properties: [
                            "porosity": porosity.rawValue,
                            "wash_frequency": washFrequency.rawValue,
                            "chemical_treatment": chemicalTreatment?.rawValue ?? "none",
                            "dryness": dryness.rawValue,
                        ])
                        let distinctId = PostHogSDK.shared.getDistinctId()
                        PostHogSDK.shared.identify(distinctId, userProperties: [
                            "name": userName,
                            "hair_porosity": porosity.rawValue,
                            "hair_dryness": dryness.rawValue,
                            "wash_frequency": washFrequency.rawValue,
                            "chemical_treatment": chemicalTreatment?.rawValue ?? "none",
                            "has_chemical_treatment": chemicalTreatment?.hasTreatment ?? false,
                        ])
                    }
                default:
                    EmptyView()
                }
            }
            .id(step)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .clipped()
        }
        .onAppear {
            PostHogSDK.shared.capture("onboarding_started")
            PostHogSDK.shared.capture("onboarding_step_viewed", properties: ["step": "welcome"])
        }
        .onChange(of: step) { _, newStep in
            guard newStep > 0, newStep < stepNames.count else { return }
            PostHogSDK.shared.capture("onboarding_step_viewed", properties: ["step": stepNames[newStep]])
        }
    }
}

struct OnboardingBackground: View {
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width
            let cy = geo.size.height * 1.491
            let endRadius = sqrt(cx * cx + cy * cy) / 0.96154
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.949, green: 0.416, blue: 0.373), location: 0.0096),
                    .init(color: Color(red: 0.949, green: 0.612, blue: 0.424), location: 0.418),
                    .init(color: Color(red: 0.949, green: 0.706, blue: 0.420), location: 0.668),
                    .init(color: Color(red: 0.949, green: 0.784, blue: 0.592), location: 0.815),
                    .init(color: Color(red: 0.949, green: 0.863, blue: 0.761), location: 0.962),
                ],
                center: UnitPoint(x: 1.0, y: 1.491),
                startRadius: 0,
                endRadius: endRadius
            )
        }
        .ignoresSafeArea()
    }
}

struct OnboardingProgressDots: View {
    let currentStep: Int
    private let totalSteps = 8

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? obActiveColor : obInactiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 5)
            }
        }
    }
}

struct WelcomeStep: View {
    var next: () -> Void

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 0)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleView
                .padding(.horizontal, 28)
                .padding(.top, 40)

            Spacer()

            ZStack {
                Image(systemName: "cloud.rain")
                    .font(.system(size: isPad ? 220 : 150))
                    .foregroundStyle(obActiveColor.opacity(0.84))
                    .shadow(color: Color(red: 0.949, green: 0.416, blue: 0.373).opacity(0.4), radius: 4, x: 1, y: 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 32, y: isPad ? -150 : -100)

                Image(systemName: "sun.max")
                    .font(.system(size: isPad ? 290 : 190))
                    .foregroundStyle(obActiveColor.opacity(0.84))
                    .shadow(color: Color(red: 0.949, green: 0.416, blue: 0.373).opacity(0.4), radius: 4, x: 1, y: 5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -32, y: isPad ? 120 : 80)
            }
            .frame(maxWidth: .infinity)
            .frame(height: isPad ? 440 : 280)

            Spacer()

            HStack {
                Spacer()
                Button(action: next) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(obActiveColor)
                        .padding(18)
                        .background(.white.opacity(0.4), in: Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.welcome.title")) {
            Text(attributed)
                .font(.system(size: isPad ? 52 : 36))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.welcome.title"))
                .font(.system(size: isPad ? 52 : 36))
                .foregroundColor(obActiveColor)
        }
    }
}

struct DrynessStep: View {
    @Binding var dryness: HairDryness
    var next: () -> Void

    @State private var selected: HairDryness? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleView
                .padding(.horizontal, 28)
                .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(HairDryness.allCases, id: \.self) { option in
                    Button {
                        selected = option
                        dryness = option
                    } label: {
                        Text(option.onboardingLabel)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(obActiveColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected == option ? .white.opacity(0.65) : .white.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(obActiveColor.opacity(selected == option ? 0.35 : 0), lineWidth: 1.5)
                            )
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)

            Spacer()

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
            .opacity(selected == nil ? 0 : 1)
            .scaleEffect(selected == nil ? 0.92 : 1, anchor: .bottom)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selected == nil)
            .disabled(selected == nil)
            .allowsHitTesting(selected != nil)
        }
    }

    @ViewBuilder private var titleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.dryness.question")) {
            Text(attributed)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.dryness.question"))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        }
    }
}

struct ChemicalStep: View {
    @Binding var chemicalTreatment: ChemicalTreatment?
    var next: () -> Void

    @State private var selected: ChemicalTreatment? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 3)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleView
                .padding(.horizontal, 28)
                .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(ChemicalTreatment.allCases, id: \.self) { option in
                    Button {
                        selected = option
                        chemicalTreatment = option
                    } label: {
                        Text(option.localizedLabel)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(obActiveColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected == option ? .white.opacity(0.65) : .white.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(obActiveColor.opacity(selected == option ? 0.35 : 0), lineWidth: 1.5)
                            )
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)

            Spacer()

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
            .opacity(selected == nil ? 0 : 1)
            .scaleEffect(selected == nil ? 0.92 : 1, anchor: .bottom)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selected == nil)
            .disabled(selected == nil)
            .allowsHitTesting(selected != nil)
        }
    }

    @ViewBuilder private var titleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.chemical.question")) {
            Text(attributed)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.chemical.question"))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        }
    }
}

struct PorosityStep: View {
    @Binding var porosity: HairPorosity
    var next: () -> Void

    @State private var selected: HairPorosity? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 4)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleView
                .padding(.horizontal, 28)
                .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(HairPorosity.allCases, id: \.self) { option in
                    Button {
                        selected = option
                        porosity = option
                    } label: {
                        Text(option.onboardingLabel)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(obActiveColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected == option ? .white.opacity(0.65) : .white.opacity(0.4))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(obActiveColor.opacity(selected == option ? 0.35 : 0), lineWidth: 1.5)
                            )
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)

            Spacer()

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
            .opacity(selected == nil ? 0 : 1)
            .scaleEffect(selected == nil ? 0.92 : 1, anchor: .bottom)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selected == nil)
            .disabled(selected == nil)
            .allowsHitTesting(selected != nil)
        }
    }

    @ViewBuilder private var titleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.porosity.question")) {
            Text(attributed)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.porosity.question"))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        }
    }
}

struct WashFrequencyStep: View {
    @Binding var washFrequency: WashFrequency
    var next: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 5)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            titleView
                .padding(.horizontal, 28)
                .padding(.top, 40)

            Spacer()

            WashFrequencyDrumPicker(selection: $washFrequency)
                .frame(maxWidth: .infinity)

            Spacer()

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder private var titleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.washFrequency.question")) {
            Text(attributed)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.washFrequency.question"))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(obActiveColor)
        }
    }
}

private struct WashFrequencyDrumPicker: View {
    @Binding var selection: WashFrequency
    private let cases = WashFrequency.allCases
    private let itemHeight: CGFloat = 110

    @State private var dragOffset: CGFloat = 0
    private var idx: Int { cases.firstIndex(of: selection) ?? 0 }

    var body: some View {
        ZStack {
            ForEach(Array(cases.enumerated()), id: \.offset) { i, freq in
                Text(String(freq.rawValue))
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundColor(obActiveColor.opacity(i == idx ? 1.0 : 0.35))
                    .scaleEffect(i == idx ? 1.0 : 0.78)
                    .frame(height: itemHeight)
                    .offset(y: CGFloat(i - idx) * itemHeight + dragOffset)
            }
        }
        .frame(height: itemHeight * 3)
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        if value.translation.height < -20, idx < cases.count - 1 {
                            selection = cases[idx + 1]
                        } else if value.translation.height > 20, idx > 0 {
                            selection = cases[idx - 1]
                        }
                        dragOffset = 0
                    }
                }
        )
    }
}

// MARK: - Apple Intelligence Step

struct AppleIntelligenceStep: View {
    var next: () -> Void

    @State private var showButton = false

    private let aiSteps: [(String, String)] = [
        ("1", "onboarding.ai.step1"),
        ("2", "onboarding.ai.step2"),
        ("3", "onboarding.ai.step3"),
        ("4", "onboarding.ai.step4"),
        ("5", "onboarding.ai.step5"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 2)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Text(L("onboarding.ai.title"))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(obActiveColor)
                .padding(.horizontal, 28)
                .padding(.top, 40)

            subtitleView
                .padding(.horizontal, 28)
                .padding(.top, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(aiSteps, id: \.0) { number, key in
                        aiStepCard(number: number, text: L(key))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
            .opacity(showButton ? 1 : 0)
            .scaleEffect(showButton ? 1 : 0.92, anchor: .bottom)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showButton)
            .allowsHitTesting(showButton)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showButton = true
            }
        }
    }

    @ViewBuilder private var subtitleView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.ai.subtitle")) {
            Text(attributed)
                .font(.system(size: 18))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.ai.subtitle"))
                .font(.system(size: 18))
                .foregroundColor(obActiveColor)
        }
    }

    private func aiStepCard(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(number).")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0.945, green: 0.361, blue: 0.361))
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(obActiveColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 0.318, green: 0.129, blue: 0.024).opacity(0.3), radius: 7, x: 0, y: 7)
    }
}

// MARK: - Name Step

struct NameStep: View {
    @Binding var tempName: String
    var next: () -> Void

    @State private var animatedPlaceholder = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 1)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Text(L("onboarding.name.question").capitalized)
                .font(.system(size: 35, weight: .regular))
                .foregroundColor(obActiveColor)
                .padding(.horizontal, 28)
                .padding(.top, 40)

            Spacer()

            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    if tempName.isEmpty {
                        Text(animatedPlaceholder)
                            .font(.system(size: 26))
                            .foregroundColor(obActiveColor.opacity(0.44))
                            .allowsHitTesting(false)
                    }
                    TextField("", text: $tempName)
                        .font(.system(size: 26))
                        .foregroundColor(obActiveColor)
                        .tint(obActiveColor)
                        .submitLabel(.done)
                        .focused($isFieldFocused)
                }
                .padding(.bottom, 10)

                Rectangle()
                    .fill(obActiveColor.opacity(0.8))
                    .frame(height: 4)
            }
            .padding(.horizontal, 28)

            Spacer()

            Button(action: next) {
                Text(L("common.continue"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.4), in: Capsule())
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 40)
            .opacity(tempName.isEmpty ? 0 : 1)
            .scaleEffect(tempName.isEmpty ? 0.92 : 1, anchor: .bottom)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: tempName.isEmpty)
            .disabled(tempName.isEmpty)
            .allowsHitTesting(!tempName.isEmpty)
        }
        .task(id: tempName.isEmpty) {
            guard tempName.isEmpty else {
                animatedPlaceholder = ""
                return
            }
            animatedPlaceholder = ""
            let text = L("onboarding.name.placeholder")
            do {
                while true {
                    for char in text {
                        animatedPlaceholder.append(char)
                        try await Task.sleep(nanoseconds: 100_000_000)
                    }
                    try await Task.sleep(nanoseconds: 1_500_000_000)
                    while !animatedPlaceholder.isEmpty {
                        animatedPlaceholder.removeLast()
                        try await Task.sleep(nanoseconds: 60_000_000)
                    }
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            } catch {
                animatedPlaceholder = ""
            }
        }
    }
}

// MARK: - Final Step

struct FinalStep: View {
    var next: () -> Void

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingProgressDots(currentStep: 7)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Text(L("onboarding.final.title"))
                .font(.system(size: isPad ? 52 : 36, weight: .bold))
                .foregroundColor(obActiveColor)
                .padding(.horizontal, 28)
                .padding(.top, 40)

            descriptionView
                .padding(.horizontal, 28)
                .padding(.top, 20)

            Image("finalStep")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: isPad ? 560 : 340)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, isPad ? 32 : 16)
                .padding(.top, isPad ? 40 : 24)

            Spacer()

            Button(action: next) {
                Text(L("onboarding.final.button"))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(obActiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white.opacity(0.75), in: Capsule())
            }
            .frame(maxWidth: isPad ? 500 : .infinity)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isPad ? 0 : 48)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder private var descriptionView: some View {
        if let attributed = try? AttributedString(markdown: L("onboarding.final.description")) {
            Text(attributed)
                .font(.system(size: isPad ? 22 : 18))
                .foregroundColor(obActiveColor)
        } else {
            Text(L("onboarding.final.description"))
                .font(.system(size: isPad ? 22 : 18))
                .foregroundColor(obActiveColor)
        }
    }
}

#Preview {
    OnboardingView()
}
