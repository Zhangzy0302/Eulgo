

import SwiftUI

@main
struct EulgoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var putterPebbleIsCheckingLocationSettings = false
    
    @StateObject private var putterPebbleLocationManager = PutterPebbleLocationManager.shared
    
    @UIApplicationDelegateAdaptor(EagleCaddieAppDelegate.self)
    var appDelegate
    
    init() {
        StarterSeedInitialData.starterSeedInitializeIfNeeded()
    }
    
    private func putterPebbleOpenLocationSettings() {
        putterPebbleIsCheckingLocationSettings = true

        guard let putterPebbleSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        Task { @MainActor in
            guard UIApplication.shared.canOpenURL(putterPebbleSettingsURL) else {
                return
            }

            await UIApplication.shared.open(putterPebbleSettingsURL)
        }
    }

    private func putterPebbleHandleScenePhaseChange(_ putterPebbleNewPhase: ScenePhase) {
        guard putterPebbleNewPhase == .active,
              putterPebbleIsCheckingLocationSettings else {
            return
        }

        putterPebbleLocationManager.putterPebbleShowLocationDialog = false
        putterPebbleIsCheckingLocationSettings = false
    }

    var body: some Scene {
        WindowGroup {
            SessionGateRootView()
                .fairwayGreenDismissKeyboardOnTap()
                .golfPulseGlobalOverlay()
                .onChange(of: scenePhase) { putterPebbleNewPhase in
                    putterPebbleHandleScenePhaseChange(putterPebbleNewPhase)
                }
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
