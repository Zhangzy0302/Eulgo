import SwiftUI
import UIKit

struct FairwaySocialCommentBottomSheet: View {
    @State private var fairwaySocialCommentInput = ""
    @State private var fairwaySocialKeyboardHeight: CGFloat = 0
    @State private var fairwaySocialShowsReportSheet = false
    @State private var fairwaySocialReportTargetUserID: String?
    @State private var fairwaySocialRefreshToken = UUID()

    let fairwaySocialVideoPostID: String
    let fairwaySocialGuestRestrictionAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                
                VStack(alignment: .leading, spacing: 18) {
                    Text("Comments")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.top, 30)

                    ScrollView(showsIndicators: false) {
                        if fairwaySocialComments.isEmpty {
                            Text("No comments yet.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black.opacity(0.55))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 12)
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(fairwaySocialComments) { fairwaySocialComment in
                                    FairwaySocialCommentRowView(
                                        fairwaySocialComment: fairwaySocialComment,
                                        fairwaySocialReportAction: {
                                            fairwaySocialShowReportSheet(targetUserID: fairwaySocialComment.fairwaySocialPublisherID)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)

                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 430, alignment: .top)
            .background(
                Image("EULGO_comment_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            ).ignoresSafeArea()

            FairwaySocialCommentInputBarView(
                fairwaySocialVideoPostID: fairwaySocialVideoPostID,
                fairwaySocialCommentInput: $fairwaySocialCommentInput,
                fairwaySocialKeyboardHeight: fairwaySocialKeyboardHeight,
                fairwaySocialGuestRestrictionAction: {
                    fairwaySocialGuestRestrictionAction()
                }
            ).ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { fairwaySocialNotification in
            guard let fairwaySocialKeyboardFrame = fairwaySocialNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

            withAnimation(.easeInOut(duration: 0.22)) {
                fairwaySocialKeyboardHeight = fairwaySocialKeyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.22)) {
                fairwaySocialKeyboardHeight = 0
            }
        }
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $fairwaySocialShowsReportSheet,
            caddieGuardTargetUserID: fairwaySocialReportTargetUserID,
            caddieGuardBlockSuccessAction: {
                fairwaySocialRefreshToken = UUID()
            }
        )
    }

    private func fairwaySocialShowReportSheet(targetUserID: String?) {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySocialGuestRestrictionAction()
            return
        }

        fairwaySocialReportTargetUserID = targetUserID
        fairwaySocialShowsReportSheet = true
    }

    private var fairwaySocialComments: [FairwaySocialCommentModel] {
        _ = fairwaySocialRefreshToken

        let fairwaySocialBlockedUserIDs = Set(PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxBlockedUserIDs ?? [])
        let fairwaySocialUsersByID = Dictionary(
            uniqueKeysWithValues: TeeBoxUserStore.teeBoxReadAllUsers().map { ($0.teeBoxUserID, $0) }
        )

        return GreenNoteCommentStore.greenNoteReadComments(greenNoteVideoID: fairwaySocialVideoPostID)
            .filter { fairwaySocialBlockedUserIDs.contains($0.greenNotePublisherID) == false }
            .enumerated()
            .map { fairwaySocialIndex, fairwaySocialStoredComment in
                let fairwaySocialUser = fairwaySocialUsersByID[fairwaySocialStoredComment.greenNotePublisherID]

                return FairwaySocialCommentModel(
                    fairwaySocialCommentID: fairwaySocialStoredComment.greenNoteCommentID,
                    fairwaySocialPublisherID: fairwaySocialStoredComment.greenNotePublisherID,
                    fairwaySocialShowsReportButton: fairwaySocialStoredComment.greenNotePublisherID != PlayerBadgeSessionStore.playerBadgeCurrentUserID,
                    fairwaySocialName: fairwaySocialUser.map(fairwaySocialDisplayName(for:)) ?? "Eulgo Player",
                    fairwaySocialText: fairwaySocialStoredComment.greenNoteContentText,
                    fairwaySocialAvatarAddress: fairwaySocialUser?.teeBoxAvatarAddress ?? "",
                    fairwaySocialAvatarStyle: fairwaySocialAvatarStyle(for: fairwaySocialIndex)
                )
            }
    }

    private func fairwaySocialDisplayName(for fairwaySocialUser: TeeBoxUserModel) -> String {
        let fairwaySocialTrimmedName = fairwaySocialUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return fairwaySocialTrimmedName.isEmpty ? fairwaySocialUser.teeBoxEmail : fairwaySocialTrimmedName
    }

    private func fairwaySocialAvatarStyle(for fairwaySocialIndex: Int) -> FairwaySocialAvatarStyle {
        let fairwaySocialStyles: [FairwaySocialAvatarStyle] = [.ocean, .twilight, .rose, .mint, .sunny]
        return fairwaySocialStyles[fairwaySocialIndex % fairwaySocialStyles.count]
    }
}

private struct FairwaySocialCommentModel: Identifiable {
    let fairwaySocialCommentID: String
    let fairwaySocialPublisherID: String
    let fairwaySocialShowsReportButton: Bool
    let fairwaySocialName: String
    let fairwaySocialText: String
    let fairwaySocialAvatarAddress: String
    let fairwaySocialAvatarStyle: FairwaySocialAvatarStyle

    var id: String { fairwaySocialCommentID }
}

private struct FairwaySocialCommentRowView: View {
    let fairwaySocialComment: FairwaySocialCommentModel
    let fairwaySocialReportAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack{
                FairwaySocialUserAvatarBadge(
                    fairwaySocialAvatarAddress: fairwaySocialComment.fairwaySocialAvatarAddress,
                    fairwaySocialStyle: fairwaySocialComment.fairwaySocialAvatarStyle,
                    fairwaySocialSize: 34,
                    fairwaySocialShowsRing: false
                )
                Text(fairwaySocialComment.fairwaySocialName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                
                if fairwaySocialComment.fairwaySocialShowsReportButton {
                    Button(action: fairwaySocialReportAction) {
                        Image("EULGO_report_icon")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.black)
                            .frame(width: 16, height: 16)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                }
            }
            

            Text(fairwaySocialComment.fairwaySocialText)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.black.opacity(0.64))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 43)

            
        }
    }

}


private struct FairwaySocialCommentInputBarView: View {
    let fairwaySocialVideoPostID: String
    @Binding var fairwaySocialCommentInput: String
    let fairwaySocialKeyboardHeight: CGFloat
    let fairwaySocialGuestRestrictionAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("Say Something...", text: $fairwaySocialCommentInput)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.black)
                .tint(.black)
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button(action: fairwaySocialSendAction) {
                Image("EULGO_send")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 72, height: 52)
                    .background(
                        LinearGradient(
                            colors: [
                                FairwayStylePalette.fairwaySoftLime,
                                FairwayStylePalette.fairwaySoftMint
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 34)
        .background(FairwayStylePalette.fairwayInputBarBackground)
        .clipShape(FairwaySocialTopRoundedShape(fairwaySocialRadius: 12))
        .ignoresSafeArea()
        .offset(y: -(fairwaySocialKeyboardOffset))
    }

    private var fairwaySocialKeyboardOffset: CGFloat {
        max(0, fairwaySocialKeyboardHeight - fairwaySocialBottomSafeAreaInset)
    }

    private var fairwaySocialBottomSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }

    private func fairwaySocialSendAction() {
        let fairwaySocialTrimmedInput = fairwaySocialCommentInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard fairwaySocialTrimmedInput.isEmpty == false else {
            return
        }

        guard let fairwaySocialCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySocialGuestRestrictionAction()
            return
        }

        let fairwaySocialComment = GreenNoteCommentModel(
            greenNoteVideoID: fairwaySocialVideoPostID,
            greenNotePublisherID: fairwaySocialCurrentUserID,
            greenNoteContentText: fairwaySocialTrimmedInput
        )

        _ = GreenNoteCommentStore.greenNoteCreateComment(fairwaySocialComment)
        fairwaySocialCommentInput = ""
    }
}

private struct FairwaySocialTopRoundedShape: Shape {
    let fairwaySocialRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let fairwaySocialPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: fairwaySocialRadius, height: fairwaySocialRadius)
        )
        return Path(fairwaySocialPath.cgPath)
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()
        VStack {
            Spacer()
            FairwaySocialCommentBottomSheet(
                fairwaySocialVideoPostID: "preview-post",
                fairwaySocialGuestRestrictionAction: {}
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
