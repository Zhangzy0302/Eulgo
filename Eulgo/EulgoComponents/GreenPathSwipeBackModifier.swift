import SwiftUI

struct GreenPathSwipeBackModifier: ViewModifier {
    let greenPathBackAction: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { greenPathValue in
                        let greenPathStartsAtEdge = greenPathValue.startLocation.x <= 28
                        let greenPathMovesRight = greenPathValue.translation.width >= 86
                        let greenPathMostlyHorizontal = abs(greenPathValue.translation.height) <= 64

                        if greenPathStartsAtEdge && greenPathMovesRight && greenPathMostlyHorizontal {
                            greenPathBackAction()
                        }
                    }
            )
    }
}

extension View {
    func greenPathSwipeBack(greenPathBackAction: @escaping () -> Void) -> some View {
        modifier(GreenPathSwipeBackModifier(greenPathBackAction: greenPathBackAction))
    }
}
