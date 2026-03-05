import SwiftUI

struct OnboardingView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var tempName: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bgRecomendacao")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                Image("frameOnboarding")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 293)
                
                Text("Como podemos te chamar?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.redBrown)
                    .padding(.bottom, 40)
                
                TextField("Digite seu nome...", text: $tempName)
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
                    Button(action: {
                        userName = tempName
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Começar")
                            .font(.system(size: 20, weight: .semibold))
                            .fontWeight(.bold)
                            .foregroundColor(.redBrown)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                                    
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.6), .white.opacity(0.1), .redBrown.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            }
                            .scaleEffect(tempName.isEmpty ? 0.95 : 1.0)
                    }
                    .padding(.horizontal, 40)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
}

#Preview {
    OnboardingView()
}
