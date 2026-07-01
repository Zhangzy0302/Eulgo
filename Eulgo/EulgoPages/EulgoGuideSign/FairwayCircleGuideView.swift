import SwiftUI
import UIKit

struct FairwayCircleGuideView: View {
    @AppStorage(FairwayCircleGlobalAgreementStore.fairwayCircleUserAgreementAcceptedKey)
    private var fairwayCircleHasAcceptedUserAgreement = false
    @AppStorage(FairwayCircleGlobalAgreementStore.fairwayCircleEULAAgreementAcceptedKey)
    private var fairwayCircleHasAcceptedEULAAgreement = false
    @StateObject private var fairwayCircleFairwayFizzInitViewModel = FairwayFizzInitViewModel()
    @ObservedObject private var fairwayCircleLocationManager = PutterPebbleLocationManager.shared
    @State private var fairwayCircleShowsEULABottomSheet = false
    @State private var fairwayCirclePendingGuideAction: FairwayCircleGuideAction?
    @State private var fairwayCircleAuthMode: CourseAccessAuthMode?
    @State private var fairwayCircleWebAddress: String?
    @State private var fairwayCircleIsGuestLoggingIn = false
    @State private var fairwayCircleDidStartFairwayFizzInit = false
    @State private var fairwayCircleDidOpenInitialBWebRoute = false
    @State private var fairwayCircleIsPreparingQuickLogin = false

    var body: some View {
        ZStack {
            GeometryReader { _ in
                Image("EULGO_guide_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            

            LinearGradient(
                colors: [
                    .black.opacity(0.0),
                    .black.opacity(0.26),
                    .black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch fairwayCircleFairwayFizzInitViewModel.fairwayFizzStatus {
            case .fairwayFizzLoading:
                fairwayCircleLoadingContent
            case .fairwayFizzA:
                fairwayCircleAPackageContent
            case .fairwayFizzB:
                fairwayCircleBPackageContent
            }

            if fairwayCircleShowsEULABottomSheet {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture {
                        fairwayCircleDismissEULABottomSheet()
                    }
                    .transition(.opacity)

                VStack(spacing: 0) {
                    Spacer()

                    FairwayCircleEULABottomSheet(
                        fairwayCircleGotItAction: fairwayCircleAcceptEULAAndContinue
                    )
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if let fairwayCircleAuthMode {
                CourseAccessAuthView(
                    courseAccessInitialMode: fairwayCircleAuthMode,
                    courseAccessBackAction: fairwayCircleDismissAuthView
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(2)
            }

            if let fairwayCircleWebAddress {
                LinkBridgeWebDisplayView(linkBridgeWebAddress: fairwayCircleWebAddress) {
                    self.fairwayCircleWebAddress = nil
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(3)
            }

            if fairwayCircleLocationManager.putterPebbleShowLocationDialog {
                PutterPebbleLocationPermissionDialog(
                    putterPebbleOpenSettingsAction: fairwayCircleOpenLocationSettings,
                    putterPebbleCancelAction: {
                        fairwayCircleLocationManager.putterPebbleShowLocationDialog = false
                    }
                )
                .transition(.opacity)
                .zIndex(4)
            }
        }
        .onAppear {
            fairwayCircleStartFairwayFizzInitIfNeeded()
        }
        .animation(.easeInOut(duration: 0.24), value: fairwayCircleShowsEULABottomSheet)
        .animation(.easeInOut(duration: 0.24), value: fairwayCircleAuthMode != nil)
        .animation(.easeInOut(duration: 0.24), value: fairwayCircleWebAddress)
        .animation(.easeInOut(duration: 0.24), value: fairwayCircleLocationManager.putterPebbleShowLocationDialog)
    }

    private var fairwayCircleAPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()

            fairwayCircleLogoTitle
                .padding(.bottom, 34)

            VStack(spacing: 22) {
                Button(action: fairwayCircleLoginByEmail) {
                    Text("Login by Email")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(FairwayStylePalette.fairwayBrandGradient())
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }

                Button(action: fairwayCircleLoginAsGuest) {
                    Text("I'm New")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .disabled(fairwayCircleIsGuestLoggingIn)
                .opacity(fairwayCircleIsGuestLoggingIn ? 0.72 : 1)
            }
            .padding(.horizontal, 16)

            FairwayCircleTermsAgreementView(
                isAccepted: $fairwayCircleHasAcceptedUserAgreement,
                fairwayCircleUserAgreementAction: {
                    fairwayCircleWebAddress = "https://app.wnhliu2m.link/users"
                },
                fairwayCirclePrivacyPolicyAction: {
                    fairwayCircleWebAddress = "https://app.wnhliu2m.link/privacy"
                }
            )
            .padding(.top, 20)
            .padding(.horizontal, 28)
            .padding(.bottom, 18)
        }
    }

    private var fairwayCircleBPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()

            fairwayCircleLogoTitle
                .padding(.bottom, 120)
            
            

            Button(action: fairwayCircleHandleQuickLogin) {
                Text(fairwayCircleIsPreparingQuickLogin ? "Logging in..." : "Quick Login")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(FairwayStylePalette.fairwayBrandGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(fairwayCircleIsPreparingQuickLogin)
            .opacity(fairwayCircleIsPreparingQuickLogin ? 0.72 : 1)
            .padding(.horizontal, 18)
            .padding(.bottom, 66)
        }
    }

    private var fairwayCircleLoadingContent: some View {
        VStack(spacing: 18) {
            Spacer()

            fairwayCircleLogoTitle.padding(.bottom, 120)

            ProgressView()
                .progressViewStyle(.circular)
                .tint(FairwayStylePalette.fairwayLinkGreen)
                .scaleEffect(1.12)

            Text("Preparing Eulgo")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .padding(.bottom, 66)
                
        }
    }

    private var fairwayCircleLogoTitle: some View {
        VStack(spacing: 10) {
            Image("EULGO_App_Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.22), radius: 14, y: 8)

            Text("Eulgo")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func fairwayCircleLoginByEmail() {
        fairwayCircleContinueAfterAgreementCheck(.loginByEmail)
    }

    private func fairwayCircleLoginAsGuest() {
        fairwayCircleContinueAfterAgreementCheck(.guestLogin)
    }

    private func fairwayCircleStartFairwayFizzInitIfNeeded() {
        guard fairwayCircleDidStartFairwayFizzInit == false else {
            return
        }

        fairwayCircleDidStartFairwayFizzInit = true

        Task { @MainActor in
            await fairwayCircleFairwayFizzInitViewModel.fairwayFizzInitFlow()
            fairwayCircleOpenInitialBWebRouteIfNeeded()
        }
    }

    private func fairwayCircleOpenInitialBWebRouteIfNeeded() {
        guard fairwayCircleDidOpenInitialBWebRoute == false,
              let fairwayCircleRoute = fairwayCircleFairwayFizzInitViewModel.fairwayFizzNextRoute else {
            return
        }

        fairwayCircleDidOpenInitialBWebRoute = true
        fairwayCircleOpenBWebRoute(fairwayCircleRoute, showsFailureToast: false)
    }

    private func fairwayCircleHandleQuickLogin() {
        guard fairwayCircleIsPreparingQuickLogin == false else {
            return
        }

        fairwayCircleIsPreparingQuickLogin = true
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()

        let fairwayCircleInitViewModel = fairwayCircleFairwayFizzInitViewModel

        Task { @MainActor in
            let fairwayCircleRoute: FairwayFizzBRoute?

            if let fairwayCircleNextRoute = fairwayCircleInitViewModel.fairwayFizzNextRoute {
                fairwayCircleRoute = fairwayCircleNextRoute
            } else {
                fairwayCircleRoute = await FairwayFizzInitUtils.shared.fairwayFizzGoLogin()
            }

            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            fairwayCircleIsPreparingQuickLogin = false
            fairwayCircleOpenBWebRoute(fairwayCircleRoute, showsFailureToast: true)
        }
    }

    private func fairwayCircleOpenBWebRoute(
        _ fairwayCircleRoute: FairwayFizzBRoute?,
        showsFailureToast fairwayCircleShowsFailureToast: Bool
    ) {
        guard case let .some(.fairwayFizzAgreement(fairwayCircleURL)) = fairwayCircleRoute,
              fairwayCircleURL.isEmpty == false else {
            if fairwayCircleShowsFailureToast {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Login failed. Please try again.", style: .error)
            }
            return
        }

        fairwayCircleWebAddress = fairwayCircleURL
    }

    private func fairwayCircleOpenLocationSettings() {
        fairwayCircleLocationManager.putterPebbleShowLocationDialog = false

        guard let fairwayCircleSettingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(fairwayCircleSettingsURL) else {
            return
        }

        UIApplication.shared.open(fairwayCircleSettingsURL)
    }

    private func fairwayCircleContinueAfterAgreementCheck(_ fairwayCircleGuideAction: FairwayCircleGuideAction) {
        guard fairwayCircleHasAcceptedUserAgreement && fairwayCircleHasAcceptedEULAAgreement else {
            fairwayCirclePendingGuideAction = fairwayCircleGuideAction
            fairwayCircleShowsEULABottomSheet = true
            return
        }

        fairwayCircleRunGuideAction(fairwayCircleGuideAction)
    }

    private func fairwayCircleAcceptEULAAndContinue() {
        fairwayCircleHasAcceptedUserAgreement = true
        fairwayCircleHasAcceptedEULAAgreement = true
        fairwayCircleShowsEULABottomSheet = false

        if let fairwayCirclePendingGuideAction {
            self.fairwayCirclePendingGuideAction = nil
            fairwayCircleRunGuideAction(fairwayCirclePendingGuideAction)
        }
    }

    private func fairwayCircleDismissEULABottomSheet() {
        fairwayCirclePendingGuideAction = nil
        fairwayCircleShowsEULABottomSheet = false
    }

    private func fairwayCircleRunGuideAction(_ fairwayCircleGuideAction: FairwayCircleGuideAction) {
        switch fairwayCircleGuideAction {
        case .loginByEmail:
            fairwayCircleAuthMode = .signIn
        case .guestLogin:
            fairwayCirclePrepareGuestLogin()
        }
    }

    private func fairwayCircleDismissAuthView() {
        fairwayCircleAuthMode = nil
    }

    private func fairwayCirclePrepareGuestLogin() {
        guard fairwayCircleIsGuestLoggingIn == false else {
            return
        }

        let fairwayCircleGuestUser: TeeBoxUserModel
        if let fairwayCircleExistingGuest = TeeBoxUserStore.teeBoxReadAllUsers().first(where: { $0.teeBoxIsGuest }) {
            fairwayCircleGuestUser = fairwayCircleExistingGuest
        } else {
            fairwayCircleGuestUser = TeeBoxUserModel(
                teeBoxEmail: "guest@eulgo.local",
                teeBoxPassword: "",
                teeBoxAvatarAddress: "EULGO_default_avatar",
                teeBoxUsername: "Guest Player",
                teeBoxBirthdayDate: fairwayCircleDefaultGuestBirthdayDate,
                teeBoxLocation: "LA",
                teeBoxGender: "male",
                teeBoxIsGuest: true
            )

            guard TeeBoxUserStore.teeBoxCreateUser(fairwayCircleGuestUser) else {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Guest login failed", style: .error)
                return
            }
        }

        fairwayCircleRunGuestLoginDelay(fairwayCircleGuestUserID: fairwayCircleGuestUser.teeBoxUserID)
    }

    private func fairwayCircleRunGuestLoginDelay(fairwayCircleGuestUserID: String) {
        fairwayCircleIsGuestLoggingIn = true
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            fairwayCircleIsGuestLoggingIn = false
            PlayerBadgeSessionStore.playerBadgeSaveLoginUserID(fairwayCircleGuestUserID)
        }
    }

    private var fairwayCircleDefaultGuestBirthdayDate: Date {
        var fairwayCircleComponents = DateComponents()
        fairwayCircleComponents.calendar = Calendar(identifier: .gregorian)
        fairwayCircleComponents.year = 2000
        fairwayCircleComponents.month = 1
        fairwayCircleComponents.day = 1
        return fairwayCircleComponents.date ?? Date()
    }
}

private enum FairwayCircleGuideAction {
    case loginByEmail
    case guestLogin
}

private struct FairwayCircleTermsAgreementView: View {
    @Binding var isAccepted: Bool
    let fairwayCircleUserAgreementAction: () -> Void
    let fairwayCirclePrivacyPolicyAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                isAccepted.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(isAccepted ? Color(red: 0.43, green: 0.91, blue: 0.32) : .white.opacity(0.62))
                        .frame(width: 18, height: 18)

                    if isAccepted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isAccepted ? "Unaccept terms" : "Accept terms")

            HStack(spacing: 3) {
                Text("Agree with")
                    .foregroundStyle(.white)
                FairwayCircleGuideLinkText(
                    title: "User Agreement",
                    fairwayCircleAction: fairwayCircleUserAgreementAction
                )
                Text("and")
                    .foregroundStyle(.white)
                FairwayCircleGuideLinkText(
                    title: "Privacy Policy",
                    fairwayCircleAction: fairwayCirclePrivacyPolicyAction
                )
            }
            .font(.system(size: 12, weight: .regular))
            .lineLimit(1)
            .minimumScaleFactor(0.82)

            Spacer(minLength: 0)
        }
    }
}

private struct FairwayCircleGuideLinkText: View {
    let title: String
    let fairwayCircleAction: () -> Void

    var body: some View {
        Button(action: fairwayCircleAction) {
            Text(title)
                .foregroundStyle(FairwayStylePalette.fairwayLinkGreen)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(FairwayStylePalette.fairwayLinkGreen)
                        .frame(height: 0.7)
                        .offset(y: 1.5)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FairwayCircleGuideView()
}
