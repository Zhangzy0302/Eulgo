import SwiftUI

enum CourseAccessAuthMode {
    case signIn
    case signUp
    case forgotPassword
}

struct CourseAccessAuthView: View {
    @State private var courseAccessAuthMode: CourseAccessAuthMode
    @State private var courseAccessEmailAddress = ""
    @State private var courseAccessPassword = ""
    @State private var courseAccessConfirmPassword = ""
    @State private var courseAccessShowsProfileSetup = false
    @State private var courseAccessShowsHome = false
    @State private var courseAccessIsSubmitting = false
    let courseAccessBackAction: () -> Void

    init(
        courseAccessInitialMode: CourseAccessAuthMode,
        courseAccessBackAction: @escaping () -> Void
    ) {
        _courseAccessAuthMode = State(initialValue: courseAccessInitialMode)
        self.courseAccessBackAction = courseAccessBackAction
    }

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 22,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(
                            action: courseAccessBackAction,
                            venueFairwaySize: 42
                        )
                    },
                    venueFairwayCenterContent: {
                        VenueFairwayHeaderView.venueFairwayTitleText(courseAccessTitle, venueFairwayFontSize: 18)
                    },
                    venueFairwayTrailingContent: {
                        EmptyView()
                    }
                )
                .padding(.top, 14)

                VStack(spacing: 22) {
                    CourseAccessInputField(
                        courseAccessTitle: "Email",
                        courseAccessPlaceholder: "Enter email address",
                        courseAccessText: $courseAccessEmailAddress,
                        courseAccessIsSecure: false
                    )

                    CourseAccessInputField(
                        courseAccessTitle: "Password",
                        courseAccessPlaceholder: "Enter password",
                        courseAccessText: $courseAccessPassword,
                        courseAccessIsSecure: true,
                        courseAccessTrailingContent: {
                            if courseAccessAuthMode == .signIn {
                                Button {
                                    courseAccessAuthMode = .forgotPassword
                                } label: {
                                    Text("Forgot password?")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(FairwayStylePalette.fairwayLinkGreen)
                                        .overlay(alignment: .bottom) {
                                            Rectangle()
                                                .fill(FairwayStylePalette.fairwayLinkGreen)
                                                .frame(height: 0.6)
                                                .offset(y: 1.5)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    )

                    if courseAccessAuthMode != .signIn {
                        CourseAccessInputField(
                            courseAccessTitle: "Password",
                            courseAccessPlaceholder: "Enter password",
                            courseAccessText: $courseAccessConfirmPassword,
                            courseAccessIsSecure: true
                        )
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 76)

                if courseAccessAuthMode == .signIn {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .foregroundStyle(.white)

                        Button {
                            courseAccessAuthMode = .signUp
                        } label: {
                            Text("Sign up")
                                .foregroundStyle(FairwayStylePalette.fairwayLinkGreen)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(FairwayStylePalette.fairwayLinkGreen)
                                        .frame(height: 0.6)
                                        .offset(y: 1.5)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.system(size: 12, weight: .regular))
                    .padding(.top, 26)
                }

                Spacer(minLength: 24)

                Button(action: courseAccessPrimaryAction) {
                    Text(courseAccessPrimaryButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [
                                    FairwayStylePalette.fairwayLime,
                                    FairwayStylePalette.fairwayMint
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .disabled(courseAccessIsSubmitting)
                .opacity(courseAccessIsSubmitting ? 0.72 : 1)
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }

            if courseAccessShowsProfileSetup {
                CourseAccessProfileSetupView(
                    courseAccessEmailAddress: courseAccessNormalizedEmail,
                    courseAccessPassword: courseAccessPassword,
                    courseAccessBackAction: {
                        courseAccessShowsProfileSetup = false
                    },
                    courseAccessRegisterSuccessAction: { courseAccessUserID in
                        PlayerBadgeSessionStore.playerBadgeSaveLoginUserID(courseAccessUserID)
                        GolfPulseOverlayCenter.shared.golfPulseShowToast("Account created", style: .success)
                        courseAccessShowsHome = true
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
            }

            if courseAccessShowsHome {
                ClubHouseHomeView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: courseAccessShowsProfileSetup)
        .animation(.easeInOut(duration: 0.24), value: courseAccessShowsHome)
        .greenPathSwipeBack(greenPathBackAction: courseAccessBackAction)
    }

    private var courseAccessTitle: String {
        switch courseAccessAuthMode {
        case .signIn:
            return "sign in"
        case .signUp:
            return "sign up"
        case .forgotPassword:
            return "Forgot password"
        }
    }

    private var courseAccessPrimaryButtonTitle: String {
        switch courseAccessAuthMode {
        case .signIn:
            return "Login"
        case .signUp:
            return "Sign up"
        case .forgotPassword:
            return "Save"
        }
    }

    private func courseAccessPrimaryAction() {
        guard courseAccessIsSubmitting == false else {
            return
        }

        switch courseAccessAuthMode {
        case .signIn:
            courseAccessLoginByEmail()
        case .signUp:
            courseAccessPrepareRegistration()
        case .forgotPassword:
            courseAccessResetPassword()
        }
    }

    private func courseAccessRunSimulatedNetworkDelay(_ courseAccessCompletion: @escaping () -> Void) {
        courseAccessIsSubmitting = true
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            courseAccessIsSubmitting = false
            courseAccessCompletion()
        }
    }

    private var courseAccessNormalizedEmail: String {
        courseAccessEmailAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var courseAccessTrimmedPassword: String {
        courseAccessPassword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var courseAccessTrimmedConfirmPassword: String {
        courseAccessConfirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func courseAccessLoginByEmail() {
        guard courseAccessValidateEmailAndPassword() else {
            return
        }

        guard let courseAccessUser = TeeBoxUserStore.teeBoxReadUser(teeBoxEmail: courseAccessNormalizedEmail),
              courseAccessUser.teeBoxPassword == courseAccessTrimmedPassword else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Email or password is incorrect", style: .error)
            return
        }

        courseAccessRunSimulatedNetworkDelay {
            PlayerBadgeSessionStore.playerBadgeSaveLoginUserID(courseAccessUser.teeBoxUserID)
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Welcome back", style: .success)
            courseAccessShowsHome = true
        }
    }

    private func courseAccessPrepareRegistration() {
        guard courseAccessValidateRegistrationInput() else {
            return
        }

        guard TeeBoxUserStore.teeBoxReadUser(teeBoxEmail: courseAccessNormalizedEmail) == nil else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("This email is already registered", style: .error)
            return
        }

        courseAccessRunSimulatedNetworkDelay {
            courseAccessShowsProfileSetup = true
        }
    }

    private func courseAccessResetPassword() {
        guard courseAccessValidateEmailAndPassword(),
              courseAccessValidateConfirmPassword() else {
            return
        }

        guard var courseAccessUser = TeeBoxUserStore.teeBoxReadUser(teeBoxEmail: courseAccessNormalizedEmail) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Account not found", style: .error)
            return
        }

        courseAccessUser.teeBoxPassword = courseAccessTrimmedPassword

        if TeeBoxUserStore.teeBoxUpdateUser(courseAccessUser) {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Password updated", style: .success)
            courseAccessAuthMode = .signIn
            courseAccessPassword = ""
            courseAccessConfirmPassword = ""
        } else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Unable to update password", style: .error)
        }
    }

    private func courseAccessValidateEmailAndPassword() -> Bool {
        guard courseAccessNormalizedEmail.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter email", style: .error)
            return false
        }

        guard courseAccessNormalizedEmail.contains("@") else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter a valid email", style: .error)
            return false
        }

        guard courseAccessTrimmedPassword.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please enter password", style: .error)
            return false
        }

        return true
    }

    private func courseAccessValidateRegistrationInput() -> Bool {
        guard courseAccessNormalizedEmail.isEmpty == false,
              courseAccessTrimmedPassword.isEmpty == false,
              courseAccessTrimmedConfirmPassword.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please complete registration info", style: .error)
            return false
        }

        guard courseAccessTrimmedPassword == courseAccessTrimmedConfirmPassword else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Passwords do not match", style: .error)
            return false
        }

        return true
    }

    private func courseAccessValidateConfirmPassword() -> Bool {
        guard courseAccessTrimmedConfirmPassword.isEmpty == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please confirm password", style: .error)
            return false
        }

        guard courseAccessTrimmedPassword == courseAccessTrimmedConfirmPassword else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Passwords do not match", style: .error)
            return false
        }

        return true
    }
}

private struct CourseAccessInputField<TrailingContent: View>: View {
    let courseAccessTitle: String
    let courseAccessPlaceholder: String
    @Binding var courseAccessText: String
    @FocusState private var courseAccessIsFocused: Bool
    let courseAccessIsSecure: Bool
    @ViewBuilder let courseAccessTrailingContent: () -> TrailingContent

    init(
        courseAccessTitle: String,
        courseAccessPlaceholder: String,
        courseAccessText: Binding<String>,
        courseAccessIsSecure: Bool,
        @ViewBuilder courseAccessTrailingContent: @escaping () -> TrailingContent
    ) {
        self.courseAccessTitle = courseAccessTitle
        self.courseAccessPlaceholder = courseAccessPlaceholder
        _courseAccessText = courseAccessText
        self.courseAccessIsSecure = courseAccessIsSecure
        self.courseAccessTrailingContent = courseAccessTrailingContent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(courseAccessTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                courseAccessTrailingContent()
            }

            Group {
                if courseAccessIsSecure {
                    SecureField("", text: $courseAccessText, prompt: Text(courseAccessPlaceholder).foregroundColor(.white.opacity(0.36)))
                        .focused($courseAccessIsFocused)
                        .tint(.white)
                } else {
                    TextField("", text: $courseAccessText, prompt: Text(courseAccessPlaceholder).foregroundColor(.white.opacity(0.36)))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .focused($courseAccessIsFocused)
                        .tint(.white)
                }
            }
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(courseAccessIsFocused ? FairwayStylePalette.fairwayFocusedPanelBackground : FairwayStylePalette.fairwayPanelBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(
                        courseAccessIsFocused ? FairwayStylePalette.fairwayLinkGreen : Color.white.opacity(0),
                        lineWidth: 1.2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .animation(.easeInOut(duration: 0.16), value: courseAccessIsFocused)
        }
    }
}

private extension CourseAccessInputField where TrailingContent == EmptyView {
    init(
        courseAccessTitle: String,
        courseAccessPlaceholder: String,
        courseAccessText: Binding<String>,
        courseAccessIsSecure: Bool
    ) {
        self.init(
            courseAccessTitle: courseAccessTitle,
            courseAccessPlaceholder: courseAccessPlaceholder,
            courseAccessText: courseAccessText,
            courseAccessIsSecure: courseAccessIsSecure
        ) {
            EmptyView()
        }
    }
}

struct CourseAccessAuthBackgroundView: View {
    var body: some View {
        GeometryReader{ _ in
            Image("EULGO_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview("Sign in") {
    CourseAccessAuthView(courseAccessInitialMode: .signIn) {
    }
}

#Preview("Sign up") {
    CourseAccessAuthView(courseAccessInitialMode: .signUp) {
    }
}

#Preview("Forgot password") {
    CourseAccessAuthView(courseAccessInitialMode: .forgotPassword) {
    }
}
