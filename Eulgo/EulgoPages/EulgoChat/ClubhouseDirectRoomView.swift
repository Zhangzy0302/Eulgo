import SwiftUI
import UIKit

struct ClubhouseDirectRoomView: View {
    @State private var clubhouseDirectInputText = ""
    @State private var clubhouseDirectShowsVideoCall = false
    @State private var clubhouseDirectShowsReportSheet = false
    @State private var clubhouseDirectKeyboardHeight: CGFloat = 0
    @State private var clubhouseDirectRefreshToken = UUID()

    let clubhouseDirectRoomID: String
    let clubhouseDirectBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 14,
                    venueFairwayLeadingContent: {
                        HStack(spacing: 8) {
                            VenueFairwayHeaderView.venueFairwayBackButton(action: clubhouseDirectBackAction)

                            ClubhouseDirectRoomAvatarView(
                                clubhouseDirectAvatarAddress: clubhouseDirectOpponent?.teeBoxAvatarAddress ?? "",
                                clubhouseDirectAvatarSymbol: "person.fill",
                                clubhouseDirectAvatarSize: 26,
                                clubhouseDirectAvatarColors: [
                                    Color(red: 0.94, green: 0.68, blue: 0.64),
                                    Color(red: 0.38, green: 0.49, blue: 0.39)
                                ]
                            )

                            Text(clubhouseDirectRoomTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        HStack(spacing: 8) {
                            ClubhouseDirectVideoCallButton(clubhouseDirectVideoCallAction: clubhouseDirectVideoCallAction)

                            if clubhouseDirectCanReportOpponent {
                                VenueFairwayHeaderView.venueFairwayReportButton(
                                    action: clubhouseDirectReportAction,
                                    venueFairwaySize: 40
                                )
                            }
                        }
                    }
                )
                .padding(.top, 14)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 18) {
                        ForEach(clubhouseDirectRoomMessages) { clubhouseDirectMessage in
                            ClubhouseDirectBubbleRowView(
                                clubhouseDirectMessageText: clubhouseDirectMessage.clubhouseDirectDisplayText,
                                clubhouseDirectIsCurrentUser: clubhouseDirectMessage.clubhouseDirectIsCurrentUser,
                                clubhouseDirectAvatarAddress: clubhouseDirectMessage.clubhouseDirectAvatarAddress,
                                clubhouseDirectAvatarSymbol: clubhouseDirectMessage.clubhouseDirectAvatarSymbol,
                                clubhouseDirectAvatarColors: clubhouseDirectMessage.clubhouseDirectAvatarColors
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                }

                Spacer()

                ClubhouseDirectInputBarView(
                    clubhouseDirectInputText: $clubhouseDirectInputText,
                    clubhouseDirectKeyboardHeight: clubhouseDirectKeyboardHeight,
                    clubhouseDirectSendAction: clubhouseDirectSendMessage
                )
                    
            }.ignoresSafeArea(edges: .bottom)

            if clubhouseDirectShowsVideoCall {
                GreenRoomVideoCallView(clubhouseVideoRoomID: clubhouseDirectRoomID) {
                    clubhouseDirectShowsVideoCall = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: clubhouseDirectShowsVideoCall)
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $clubhouseDirectShowsReportSheet,
            caddieGuardTargetUserID: clubhouseDirectOpponent?.teeBoxUserID,
            caddieGuardBlockSuccessAction: clubhouseDirectBackAction
        )
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { clubhouseDirectNotification in
            guard let clubhouseDirectKeyboardFrame = clubhouseDirectNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

            withAnimation(.easeInOut(duration: 0.22)) {
                clubhouseDirectKeyboardHeight = clubhouseDirectKeyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.22)) {
                clubhouseDirectKeyboardHeight = 0
            }
        }
        .greenPathSwipeBack(greenPathBackAction: clubhouseDirectBackAction)
    }

    private func clubhouseDirectVideoCallAction() {
        clubhouseDirectShowsVideoCall = true
    }

    private func clubhouseDirectReportAction() {
        clubhouseDirectShowsReportSheet = true
    }

    private func clubhouseDirectSendMessage() {
        let clubhouseDirectTrimmedText = clubhouseDirectInputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard clubhouseDirectTrimmedText.isEmpty == false else {
            return
        }

        guard let clubhouseDirectCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID,
              var clubhouseDirectStoredRoom = ClubPairChatRoomStore.clubPairReadRoom(clubPairRoomID: clubhouseDirectRoomID) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Message failed", style: .error)
            return
        }

        let clubhouseDirectSentAt = Date()
        let clubhouseDirectMessage = WhisperLineChatMessageModel(
            whisperLineRoomID: clubhouseDirectRoomID,
            whisperLineSenderID: clubhouseDirectCurrentUserID,
            whisperLineTextMessage: clubhouseDirectTrimmedText,
            whisperLineSentAt: clubhouseDirectSentAt
        )

        guard WhisperLineChatMessageStore.whisperLineCreateMessage(clubhouseDirectMessage) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Message failed", style: .error)
            return
        }

        clubhouseDirectStoredRoom.clubPairLastMessageSentAt = clubhouseDirectSentAt
        clubhouseDirectStoredRoom.clubPairLastSenderID = clubhouseDirectCurrentUserID
        clubhouseDirectStoredRoom.clubPairLastMessageText = clubhouseDirectTrimmedText
        clubhouseDirectStoredRoom.clubPairUnreadMessageCount = 0
        _ = ClubPairChatRoomStore.clubPairUpdateRoom(clubhouseDirectStoredRoom)

        clubhouseDirectInputText = ""
        clubhouseDirectRefreshToken = UUID()
    }
}

private extension ClubhouseDirectRoomView {
    var clubhouseDirectCurrentUserID: String? {
        PlayerBadgeSessionStore.playerBadgeCurrentUserID
    }

    var clubhouseDirectRoom: ClubPairChatRoomModel? {
        ClubPairChatRoomStore.clubPairReadRoom(clubPairRoomID: clubhouseDirectRoomID)
    }

    var clubhouseDirectOpponent: TeeBoxUserModel? {
        guard let clubhouseDirectCurrentUserID,
              let clubhouseDirectOpponentID = clubhouseDirectRoom?.clubPairUserIDs.first(where: { $0 != clubhouseDirectCurrentUserID }) else {
            return nil
        }

        return TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: clubhouseDirectOpponentID)
    }

    var clubhouseDirectCurrentUser: TeeBoxUserModel? {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()
    }

    var clubhouseDirectCanReportOpponent: Bool {
        guard let clubhouseDirectOpponent,
              let clubhouseDirectCurrentUserID else {
            return false
        }

        return clubhouseDirectOpponent.teeBoxUserID != clubhouseDirectCurrentUserID
    }

    var clubhouseDirectRoomTitle: String {
        guard let clubhouseDirectOpponent else {
            return "Message"
        }

        let clubhouseDirectTrimmedName = clubhouseDirectOpponent.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return clubhouseDirectTrimmedName.isEmpty ? clubhouseDirectOpponent.teeBoxEmail : clubhouseDirectTrimmedName
    }

    var clubhouseDirectRoomMessages: [ClubhouseDirectRoomMessageItem] {
        _ = clubhouseDirectRefreshToken

        let clubhouseDirectStoredMessages = WhisperLineChatMessageStore.whisperLineReadMessages(whisperLineRoomID: clubhouseDirectRoomID)

        guard clubhouseDirectStoredMessages.isEmpty == false else {
            return []
        }

        let clubhouseDirectUsersByID = Dictionary(
            uniqueKeysWithValues: TeeBoxUserStore.teeBoxReadAllUsers().map { ($0.teeBoxUserID, $0) }
        )

        return clubhouseDirectStoredMessages.map { clubhouseDirectMessage in
            let clubhouseDirectIsCurrentUser = clubhouseDirectMessage.whisperLineSenderID == clubhouseDirectCurrentUserID
            let clubhouseDirectSender = clubhouseDirectUsersByID[clubhouseDirectMessage.whisperLineSenderID]

            return ClubhouseDirectRoomMessageItem(
                clubhouseDirectMessageID: clubhouseDirectMessage.whisperLineMessageID,
                clubhouseDirectDisplayText: clubhouseDirectDisplayText(for: clubhouseDirectMessage),
                clubhouseDirectIsCurrentUser: clubhouseDirectIsCurrentUser,
                clubhouseDirectAvatarAddress: clubhouseDirectSender?.teeBoxAvatarAddress ?? "",
                clubhouseDirectAvatarSymbol: clubhouseDirectIsCurrentUser ? "person.crop.circle.fill" : "person.fill",
                clubhouseDirectAvatarColors: clubhouseDirectIsCurrentUser ? clubhouseDirectCurrentUserAvatarColors : clubhouseDirectOpponentAvatarColors
            )
        }
    }

    var clubhouseDirectOpponentAvatarColors: [Color] {
        [
            Color(red: 0.94, green: 0.68, blue: 0.64),
            Color(red: 0.38, green: 0.49, blue: 0.39)
        ]
    }

    var clubhouseDirectCurrentUserAvatarColors: [Color] {
        [
            Color(red: 0.95, green: 0.78, blue: 0.68),
            Color(red: 0.22, green: 0.41, blue: 0.45)
        ]
    }

    func clubhouseDirectDisplayText(for clubhouseDirectMessage: WhisperLineChatMessageModel) -> String {
        let clubhouseDirectText = clubhouseDirectMessage.whisperLineTextMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        if clubhouseDirectText.isEmpty == false {
            return clubhouseDirectText
        }

        if clubhouseDirectMessage.whisperLineVoiceMessageAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return "Voice message \(Int(clubhouseDirectMessage.whisperLineVoiceDuration))s"
        }

        return ""
    }
}

private struct ClubhouseDirectRoomMessageItem: Identifiable {
    let clubhouseDirectMessageID: String
    let clubhouseDirectDisplayText: String
    let clubhouseDirectIsCurrentUser: Bool
    let clubhouseDirectAvatarAddress: String
    let clubhouseDirectAvatarSymbol: String
    let clubhouseDirectAvatarColors: [Color]

    var id: String { clubhouseDirectMessageID }
}

private struct ClubhouseDirectVideoCallButton: View {
    let clubhouseDirectVideoCallAction: () -> Void

    var body: some View {
        Button(action: clubhouseDirectVideoCallAction) {
            Image("EULGO_video_call")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .frame(width: 56, height: 36)
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
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ClubhouseDirectBubbleRowView: View {
    let clubhouseDirectMessageText: String
    let clubhouseDirectIsCurrentUser: Bool
    let clubhouseDirectAvatarAddress: String
    let clubhouseDirectAvatarSymbol: String
    let clubhouseDirectAvatarColors: [Color]

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if clubhouseDirectIsCurrentUser {
                Spacer(minLength: 42)
            } else {
                ClubhouseDirectRoomAvatarView(
                    clubhouseDirectAvatarAddress: clubhouseDirectAvatarAddress,
                    clubhouseDirectAvatarSymbol: clubhouseDirectAvatarSymbol,
                    clubhouseDirectAvatarSize: 42,
                    clubhouseDirectAvatarColors: clubhouseDirectAvatarColors
                )
            }

            Text(clubhouseDirectMessageText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .lineSpacing(2)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(clubhouseDirectIsCurrentUser ? Color(red: 0.42, green: 0.96, blue: 0.42) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(maxWidth: 218, alignment: clubhouseDirectIsCurrentUser ? .trailing : .leading)

            if clubhouseDirectIsCurrentUser {
                ClubhouseDirectRoomAvatarView(
                    clubhouseDirectAvatarAddress: clubhouseDirectAvatarAddress,
                    clubhouseDirectAvatarSymbol: clubhouseDirectAvatarSymbol,
                    clubhouseDirectAvatarSize: 42,
                    clubhouseDirectAvatarColors: clubhouseDirectAvatarColors
                )
            } else {
                Spacer(minLength: 42)
            }
        }
    }
}

private struct ClubhouseDirectInputBarView: View {
    @Binding var clubhouseDirectInputText: String
    let clubhouseDirectKeyboardHeight: CGFloat
    let clubhouseDirectSendAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("Say Something...", text: $clubhouseDirectInputText)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.black)
                .tint(.black)
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onSubmit(clubhouseDirectSendAction)

            Button(action: clubhouseDirectSendAction) {
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
        .background(Color.black.opacity(0.84))
        .clipShape(ClubhouseDirectTopRoundedBarShape(radius: 12))
        .offset(y: -(clubhouseDirectKeyboardOffset))
    }

    private var clubhouseDirectKeyboardOffset: CGFloat {
        max(0, clubhouseDirectKeyboardHeight - clubhouseDirectBottomSafeAreaInset)
    }

    private var clubhouseDirectBottomSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }
}

struct ClubhouseDirectRoomAvatarView: View {
    var clubhouseDirectAvatarAddress: String = ""
    let clubhouseDirectAvatarSymbol: String
    let clubhouseDirectAvatarSize: CGFloat
    let clubhouseDirectAvatarColors: [Color]

    var body: some View {
        Group {
            if clubhouseDirectAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: clubhouseDirectAvatarColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: clubhouseDirectAvatarSymbol)
                        .font(.system(size: clubhouseDirectAvatarSize * 0.46, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.88))
                }
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: clubhouseDirectAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: Color.white.opacity(0.18),
                    fairwayGalleryFailureIconName: "person.fill"
                )
                .clipShape(Circle())
            }
        }
        .overlay(
            Circle()
                .stroke(.white.opacity(0.14), lineWidth: 1)
        )
        .frame(width: clubhouseDirectAvatarSize, height: clubhouseDirectAvatarSize)
    }
}

private struct ClubhouseDirectTopRoundedBarShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let clubhouseDirectPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(clubhouseDirectPath.cgPath)
    }
}

#Preview {
    ClubhouseDirectRoomView(clubhouseDirectRoomID: "preview-room") {
    }
}
