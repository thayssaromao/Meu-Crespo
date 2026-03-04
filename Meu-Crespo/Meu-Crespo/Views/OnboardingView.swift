import SwiftUI

struct OnboardingView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var tempName: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Boas-vindas ao\nMeu Crespo!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Como podemos te chamar?")
                .font(.headline)
                .foregroundColor(.secondary)
            
            TextField("Digite seu nome...", text: $tempName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .submitLabel(.done)
            
            Button(action: {
                if !tempName.isEmpty {
                    userName = tempName
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }
            }) {
                Text("Começar Jornada")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tempName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(tempName.isEmpty)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
    
}

#Preview {
    OnboardingView()
}
