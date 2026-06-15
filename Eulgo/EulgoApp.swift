

import SwiftUI

@main
struct EulgoApp: App {
    init() {
        StarterSeedInitialData.starterSeedInitializeIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            SessionGateRootView()
                .fairwayGreenDismissKeyboardOnTap()
                .golfPulseGlobalOverlay()
        }
    }
}

private struct SessionGateRootView: View {
    @State private var sessionGateIsLoggedIn = PlayerBadgeSessionStore.playerBadgeReadLoginUser() != nil

    var body: some View {
        Group {
            if sessionGateIsLoggedIn {
                ClubHouseHomeView()
            } else {
                FairwayCircleGuideView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: PlayerBadgeSessionStore.playerBadgeSessionDidChangeNotification)) { _ in
            sessionGateIsLoggedIn = PlayerBadgeSessionStore.playerBadgeReadLoginUser() != nil
        }
    }
}
