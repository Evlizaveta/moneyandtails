import SwiftUICore
struct AnimatedScreenView: View {
    @State private var animationCompleted = false

    var body: some View {
        if animationCompleted {
            ContentView()
        } else {
            ZStack {
                Color.white.ignoresSafeArea()
                LottieView(name: "Animations") {
                    animationCompleted = true
                }
                .frame(width: 200, height: 200)
            }
            .transition(.opacity)
        }
    }
}
