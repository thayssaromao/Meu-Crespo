import SwiftUI

struct SplashScreen: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            Image("SplashBg")
                .resizable()
                .ignoresSafeArea()
            
            Image("garfo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    .timingCurve(0.2, 0.7, 0.2, 1, duration: 1.4)
                    .repeatForever(autoreverses: false),
                    value: isRotating
                )
                .onAppear {
                    isRotating = true
                }
        }
    }
}
