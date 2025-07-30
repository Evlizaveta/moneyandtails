import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var onAnimationCompleted: (() -> Void)? = nil

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = loopMode
        view.play { finished in
            if finished {
                onAnimationCompleted?()
            }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
