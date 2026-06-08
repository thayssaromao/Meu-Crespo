import SwiftUI

struct SplashScreen: View {
    @State private var isSwaying = false

    var body: some View {
        ZStack {
            Image("SplashBg")
                .resizable()
                .ignoresSafeArea()

            // Cabelo crespo levemente abaixo do centro
            Image("crespo")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
                .offset(y: 30)

            // Garfo com as dentes na parte superior do afro
            Image("garfo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .rotationEffect(.degrees(180))
                .offset(x: 70, y: -90)
                .rotationEffect(
                    .degrees(isSwaying ? 10 : -10),
                    anchor: UnitPoint(x: 0.8, y: 0.28)
                )
                .animation(
                    .easeInOut(duration: 0.7)
                    .repeatForever(autoreverses: true),
                    value: isSwaying
                )
                .onAppear {
                    isSwaying = true
                }
        }
    }
}
