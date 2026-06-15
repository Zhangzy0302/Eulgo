import SwiftUI
import UIKit

struct FairwayGreenKeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(FairwayGreenKeyboardDismissTapView())
    }
}

extension View {
    func fairwayGreenDismissKeyboardOnTap() -> some View {
        modifier(FairwayGreenKeyboardDismissModifier())
    }
}

private struct FairwayGreenKeyboardDismissTapView: UIViewRepresentable {
    func makeCoordinator() -> FairwayGreenKeyboardDismissCoordinator {
        FairwayGreenKeyboardDismissCoordinator()
    }

    func makeUIView(context: Context) -> UIView {
        FairwayGreenKeyboardDismissHostingView(fairwayGreenCoordinator: context.coordinator)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: FairwayGreenKeyboardDismissCoordinator) {
        coordinator.fairwayGreenUninstallTapGesture()
    }
}

private final class FairwayGreenKeyboardDismissCoordinator: NSObject, UIGestureRecognizerDelegate {
    private weak var fairwayGreenWindow: UIWindow?
    private weak var fairwayGreenTapGesture: UITapGestureRecognizer?

    func fairwayGreenInstallTapGesture(on fairwayGreenWindow: UIWindow?) {
        guard let fairwayGreenWindow else {
            fairwayGreenUninstallTapGesture()
            return
        }

        if self.fairwayGreenWindow === fairwayGreenWindow {
            return
        }

        fairwayGreenUninstallTapGesture()

        let fairwayGreenTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(fairwayGreenHandleTap)
        )
        fairwayGreenTapGesture.cancelsTouchesInView = false
        fairwayGreenTapGesture.delegate = self
        fairwayGreenWindow.addGestureRecognizer(fairwayGreenTapGesture)

        self.fairwayGreenWindow = fairwayGreenWindow
        self.fairwayGreenTapGesture = fairwayGreenTapGesture
    }

    func fairwayGreenUninstallTapGesture() {
        if let fairwayGreenTapGesture {
            fairwayGreenWindow?.removeGestureRecognizer(fairwayGreenTapGesture)
        }

        fairwayGreenWindow = nil
        fairwayGreenTapGesture = nil
    }

    @objc func fairwayGreenHandleTap() {
        fairwayGreenWindow?.endEditing(true)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        fairwayGreenIsTextInput(touch.view) == false
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    private func fairwayGreenIsTextInput(_ fairwayGreenView: UIView?) -> Bool {
        guard let fairwayGreenView else {
            return false
        }

        if fairwayGreenView is UITextField || fairwayGreenView is UITextView {
            return true
        }

        return fairwayGreenIsTextInput(fairwayGreenView.superview)
    }
}

private final class FairwayGreenKeyboardDismissHostingView: UIView {
    private let fairwayGreenCoordinator: FairwayGreenKeyboardDismissCoordinator

    init(fairwayGreenCoordinator: FairwayGreenKeyboardDismissCoordinator) {
        self.fairwayGreenCoordinator = fairwayGreenCoordinator
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        fairwayGreenCoordinator.fairwayGreenInstallTapGesture(on: window)
    }
}
