import SwiftUI

enum GuestPassAccessGuard {
    static var guestPassIsGuest: Bool {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxIsGuest == true
    }
}

struct GuestPassBrowseOnlyView: View {
    let guestPassConfirmAction: () -> Void

    var body: some View {
        GeometryReader { guestPassProxy in
            let guestPassDialogWidth = min(343, max(0, guestPassProxy.size.width - 36))

            ZStack {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture(perform: guestPassConfirmAction)

                ZStack(alignment: .topLeading) {
                    Image("EULGO_chat_reminder_bg")
                        .resizable()
                        .frame(width: guestPassDialogWidth, height: 220)

                    VStack(spacing: 0) {
                        VStack(spacing: 14) {
                            Text("Reminder")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                                .padding(.top, 32)

                            Text("Guest mode is view-only. Please sign in or\ncreate an account to post, chat, like,\njoin events, or score courses.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.black.opacity(0.64))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .minimumScaleFactor(0.9)

                            Button(action: guestPassGoLoginAction) {
                                Text("Login")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(FairwayStylePalette.fairwayBrandGradient())
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            .padding(.top, 6)
                            .padding(.bottom, 18)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                    }
                }
                .frame(width: guestPassDialogWidth)
            }
            .frame(width: guestPassProxy.size.width, height: guestPassProxy.size.height)
        }
    }

    private func guestPassGoLoginAction() {
        guestPassConfirmAction()
        PlayerBadgeSessionStore.playerBadgeClearLoginUser()
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()
        GuestPassBrowseOnlyView {
        }
    }
}
