import Combine
import SwiftUI

enum GolfPulseToastStyle {
    case normal
    case error
    case success
}

struct GolfPulseToastItem: Identifiable {
    let id = UUID()
    let golfPulseMessage: String
    let golfPulseStyle: GolfPulseToastStyle
}

final class GolfPulseOverlayCenter: ObservableObject {
    static let shared = GolfPulseOverlayCenter()

    @Published private(set) var golfPulseToastItem: GolfPulseToastItem?
    @Published private(set) var golfPulseIsLoading = false
    @Published private(set) var golfPulseShowsLoadingMask = true

    private var golfPulseToastDismissWorkItem: DispatchWorkItem?

    private init() {
    }

    @MainActor
    func golfPulseShowToast(
        _ golfPulseMessage: String,
        style golfPulseStyle: GolfPulseToastStyle = .normal
    ) {
        golfPulseToastDismissWorkItem?.cancel()

        let golfPulseToastItem = GolfPulseToastItem(
            golfPulseMessage: golfPulseMessage,
            golfPulseStyle: golfPulseStyle
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            self.golfPulseToastItem = golfPulseToastItem
        }

        let golfPulseDismissWorkItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                guard self?.golfPulseToastItem?.id == golfPulseToastItem.id else {
                    return
                }
                self?.golfPulseDismissToast()
            }
        }
        golfPulseToastDismissWorkItem = golfPulseDismissWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: golfPulseDismissWorkItem)
    }

    @MainActor
    func golfPulseDismissToast() {
        golfPulseToastDismissWorkItem?.cancel()
        golfPulseToastDismissWorkItem = nil

        withAnimation(.easeInOut(duration: 0.18)) {
            golfPulseToastItem = nil
        }
    }

    @MainActor
    func golfPulseShowLoading(showsMask golfPulseShowsMask: Bool = true) {
        withAnimation(.easeInOut(duration: 0.18)) {
            golfPulseShowsLoadingMask = golfPulseShowsMask
            golfPulseIsLoading = true
        }
    }

    @MainActor
    func golfPulseHideLoading() {
        withAnimation(.easeInOut(duration: 0.18)) {
            golfPulseIsLoading = false
        }
    }
}

struct GolfPulseOverlayModifier: ViewModifier {
    @ObservedObject private var golfPulseOverlayCenter: GolfPulseOverlayCenter

    init(golfPulseOverlayCenter: GolfPulseOverlayCenter = .shared) {
        self.golfPulseOverlayCenter = golfPulseOverlayCenter
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            if golfPulseOverlayCenter.golfPulseToastItem != nil {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        golfPulseOverlayCenter.golfPulseDismissToast()
                    }
                    .zIndex(10)
            }

            if golfPulseOverlayCenter.golfPulseIsLoading {
                (golfPulseOverlayCenter.golfPulseShowsLoadingMask ? Color.black.opacity(0.36) : Color.clear)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .zIndex(20)

                GolfPulseLoadingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(21)
            }

            if let golfPulseToastItem = golfPulseOverlayCenter.golfPulseToastItem {
                VStack {
                    GolfPulseToastView(golfPulseToastItem: golfPulseToastItem)
                        .padding(.horizontal, 24)
                        .padding(.top, 62)

                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(30)
            }
        }
    }
}

extension View {
    func golfPulseGlobalOverlay(
        golfPulseOverlayCenter: GolfPulseOverlayCenter = .shared
    ) -> some View {
        modifier(GolfPulseOverlayModifier(golfPulseOverlayCenter: golfPulseOverlayCenter))
    }
}

private struct GolfPulseToastView: View {
    let golfPulseToastItem: GolfPulseToastItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: golfPulseToastIconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(golfPulseToastTintColor)

            Text(golfPulseToastItem.golfPulseMessage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FairwayStylePalette.fairwayCardBlack)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(golfPulseToastTintColor.opacity(0.50), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
    }

    private var golfPulseToastIconName: String {
        switch golfPulseToastItem.golfPulseStyle {
        case .normal:
            return "flag.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    private var golfPulseToastTintColor: Color {
        switch golfPulseToastItem.golfPulseStyle {
        case .normal:
            return Color(red: 0.38, green: 0.88, blue: 0.77)
        case .error:
            return Color(red: 1.0, green: 0.31, blue: 0.24)
        case .success:
            return Color(red: 0.62, green: 0.95, blue: 0.22)
        }
    }
}

private struct GolfPulseLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(red: 0.62, green: 0.95, blue: 0.22))
                .scaleEffect(1.2)

            Text("Loading")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 112, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 10)
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()

        VStack(spacing: 16) {
            Button("Normal Toast") {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Welcome back to the fairway")
            }

            Button("Success Toast") {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Score submitted", style: .success)
            }

            Button("Error Toast") {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Network error", style: .error)
            }

            Button("Loading") {
                GolfPulseOverlayCenter.shared.golfPulseShowLoading()
            }
        }
        .foregroundStyle(.white)
    }
    .golfPulseGlobalOverlay()
}
