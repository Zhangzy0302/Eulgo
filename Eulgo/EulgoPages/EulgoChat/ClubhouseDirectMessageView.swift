import SwiftUI

struct ClubhouseDirectMessageView: View {
    @State private var clubhouseDirectSelectedTab: ClubhouseDirectMessageTab = .all
    @State private var clubhouseDirectSelectedMessage: ClubhouseDirectMessageModel?
    @State private var clubhouseDirectRefreshToken = UUID()

    let clubhouseDirectBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 14,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: clubhouseDirectBackAction)
                    },
                    venueFairwayCenterContent: {
                        VenueFairwayHeaderView.venueFairwayTitleText("Message")
                    },
                    venueFairwayTrailingContent: {
                        EmptyView()
                    }
                )
                    .padding(.top, 14)

                ClubhouseDirectMessageSegmentedView(clubhouseDirectSelectedTab: $clubhouseDirectSelectedTab)
                    .padding(.horizontal, 14)
                    .padding(.top, 18)

                LazyVStack(spacing: 23) {
                    ForEach(clubhouseDirectMessages) { clubhouseDirectMessage in
                        ClubhouseDirectMessageRowView(clubhouseDirectMessage: clubhouseDirectMessage)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                clubhouseDirectOpenMessageRoom(clubhouseDirectMessage)
                            }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 24)

                Spacer()
            }

            if let clubhouseDirectRoomMessage = clubhouseDirectSelectedMessage {
                ClubhouseDirectRoomView(
                    clubhouseDirectRoomID: clubhouseDirectRoomMessage.clubhouseDirectRoomID,
                    clubhouseDirectBackAction: {
                        clubhouseDirectSelectedMessage = nil
                        clubhouseDirectRefreshToken = UUID()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: clubhouseDirectSelectedMessage?.id)
        .greenPathSwipeBack(greenPathBackAction: clubhouseDirectBackAction)
    }
}

private extension ClubhouseDirectMessageView {
    var clubhouseDirectMessages: [ClubhouseDirectMessageModel] {
        _ = clubhouseDirectRefreshToken

        guard let clubhouseDirectCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            return []
        }

        let clubhouseDirectCurrentUserID = clubhouseDirectCurrentUser.teeBoxUserID
        let clubhouseDirectBlockedUserIDs = Set(clubhouseDirectCurrentUser.teeBoxBlockedUserIDs)
        let clubhouseDirectUsersByID = Dictionary(
            uniqueKeysWithValues: TeeBoxUserStore.teeBoxReadAllUsers().map { ($0.teeBoxUserID, $0) }
        )

        return ClubPairChatRoomStore.clubPairReadRooms(clubPairUserID: clubhouseDirectCurrentUserID)
            .compactMap { clubhouseDirectRoom in
                guard let clubhouseDirectOpponentID = clubhouseDirectRoom.clubPairUserIDs.first(where: { $0 != clubhouseDirectCurrentUserID }),
                      clubhouseDirectBlockedUserIDs.contains(clubhouseDirectOpponentID) == false else {
                    return nil
                }

                let clubhouseDirectOpponent = clubhouseDirectUsersByID[clubhouseDirectOpponentID]
                let clubhouseDirectEffectiveUnreadCount = clubhouseDirectEffectiveUnreadCount(
                    for: clubhouseDirectRoom,
                    clubhouseDirectCurrentUserID: clubhouseDirectCurrentUserID
                )

                return ClubhouseDirectMessageModel(
                    clubhouseDirectRoomID: clubhouseDirectRoom.clubPairRoomID,
                    clubhouseDirectOpponentID: clubhouseDirectOpponentID,
                    clubhouseDirectName: clubhouseDirectOpponent.map(clubhouseDirectDisplayName(for:)) ?? "Eulgo Player",
                    clubhouseDirectAvatarAddress: clubhouseDirectOpponent?.teeBoxAvatarAddress ?? "",
                    clubhouseDirectPreview: clubhouseDirectPreviewText(for: clubhouseDirectRoom),
                    clubhouseDirectTime: clubhouseDirectTimeText(from: clubhouseDirectRoom.clubPairLastMessageSentAt),
                    clubhouseDirectUnreadCount: clubhouseDirectEffectiveUnreadCount,
                    clubhouseDirectAvatarStyle: clubhouseDirectAvatarStyle(for: clubhouseDirectOpponentID)
                )
            }
            .filter { clubhouseDirectMessage in
                switch clubhouseDirectSelectedTab {
                case .all:
                    return true
                case .news:
                    return clubhouseDirectMessage.clubhouseDirectUnreadCount > 0
                }
            }
    }

    func clubhouseDirectOpenMessageRoom(_ clubhouseDirectMessage: ClubhouseDirectMessageModel) {
        guard var clubhouseDirectRoom = ClubPairChatRoomStore.clubPairReadRoom(
            clubPairRoomID: clubhouseDirectMessage.clubhouseDirectRoomID
        ) else {
            clubhouseDirectSelectedMessage = clubhouseDirectMessage
            return
        }

        if let clubhouseDirectCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID,
           clubhouseDirectEffectiveUnreadCount(
                for: clubhouseDirectRoom,
                clubhouseDirectCurrentUserID: clubhouseDirectCurrentUserID
           ) > 0 {
            clubhouseDirectRoom.clubPairUnreadMessageCount = 0
            _ = ClubPairChatRoomStore.clubPairUpdateRoom(clubhouseDirectRoom)
            clubhouseDirectRefreshToken = UUID()
        }

        clubhouseDirectSelectedMessage = clubhouseDirectMessage
    }

    func clubhouseDirectEffectiveUnreadCount(
        for clubhouseDirectRoom: ClubPairChatRoomModel,
        clubhouseDirectCurrentUserID: String
    ) -> Int {
        guard clubhouseDirectRoom.clubPairUnreadMessageCount > 0,
              clubhouseDirectRoom.clubPairLastSenderID != clubhouseDirectCurrentUserID else {
            return 0
        }

        return clubhouseDirectRoom.clubPairUnreadMessageCount
    }

    func clubhouseDirectDisplayName(for clubhouseDirectUser: TeeBoxUserModel) -> String {
        let clubhouseDirectTrimmedName = clubhouseDirectUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)

        if clubhouseDirectTrimmedName.isEmpty == false {
            return clubhouseDirectTrimmedName
        }

        return clubhouseDirectUser.teeBoxEmail
    }

    func clubhouseDirectPreviewText(for clubhouseDirectRoom: ClubPairChatRoomModel) -> String {
        let clubhouseDirectTrimmedMessage = clubhouseDirectRoom.clubPairLastMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        return clubhouseDirectTrimmedMessage.isEmpty ? "Say hi on the fairway." : clubhouseDirectTrimmedMessage
    }

    func clubhouseDirectTimeText(from clubhouseDirectDate: Date) -> String {
        let clubhouseDirectFormatter = DateFormatter()
        clubhouseDirectFormatter.dateFormat = "HH:mm"
        return clubhouseDirectFormatter.string(from: clubhouseDirectDate)
    }

    func clubhouseDirectAvatarStyle(for clubhouseDirectUserID: String) -> ClubhouseDirectAvatarStyle {
        let clubhouseDirectStyles: [ClubhouseDirectAvatarStyle] = [.coursePlayer, .fairwayFriend, .greenMember]
        let clubhouseDirectIndex = abs(clubhouseDirectUserID.hashValue) % clubhouseDirectStyles.count
        return clubhouseDirectStyles[clubhouseDirectIndex]
    }
}

private enum ClubhouseDirectMessageTab: String, CaseIterable, Identifiable {
    case all = "All"
    case news = "News"

    var id: String { rawValue }
}

private struct ClubhouseDirectMessageModel: Identifiable {
    let clubhouseDirectRoomID: String
    let clubhouseDirectOpponentID: String
    let clubhouseDirectName: String
    let clubhouseDirectAvatarAddress: String
    let clubhouseDirectPreview: String
    let clubhouseDirectTime: String
    let clubhouseDirectUnreadCount: Int
    let clubhouseDirectAvatarStyle: ClubhouseDirectAvatarStyle

    var id: String { clubhouseDirectRoomID }
}

private enum ClubhouseDirectAvatarStyle {
    case coursePlayer
    case fairwayFriend
    case greenMember
}

private struct ClubhouseDirectMessageSegmentedView: View {
    @Binding var clubhouseDirectSelectedTab: ClubhouseDirectMessageTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ClubhouseDirectMessageTab.allCases) { clubhouseDirectTab in
                Button {
                    clubhouseDirectSelectedTab = clubhouseDirectTab
                } label: {
                    Text(clubhouseDirectTab.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(clubhouseDirectSelectedTab == clubhouseDirectTab ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background {
                            if clubhouseDirectSelectedTab == clubhouseDirectTab {
                                LinearGradient(
                                    colors: [
                                        FairwayStylePalette.fairwaySoftLime,
                                FairwayStylePalette.fairwaySoftMint
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .clipShape(Capsule())
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .frame(height: 46)
        .background(FairwayStylePalette.fairwaySegmentBackground)
        .clipShape(Capsule())
        .contentShape(Capsule())
    }
}

private struct ClubhouseDirectMessageRowView: View {
    let clubhouseDirectMessage: ClubhouseDirectMessageModel

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ClubhouseDirectAvatarView(
                clubhouseDirectAvatarAddress: clubhouseDirectMessage.clubhouseDirectAvatarAddress,
                clubhouseDirectAvatarStyle: clubhouseDirectMessage.clubhouseDirectAvatarStyle
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(clubhouseDirectMessage.clubhouseDirectName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)

                Text(clubhouseDirectMessage.clubhouseDirectPreview)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 7) {
                Text(clubhouseDirectMessage.clubhouseDirectTime)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))

                if clubhouseDirectMessage.clubhouseDirectUnreadCount > 0 {
                    Text("\(clubhouseDirectMessage.clubhouseDirectUnreadCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(FairwayStylePalette.fairwayAlertRed)
                        .clipShape(Circle())
                }
            }
        }
    }
}

private struct ClubhouseDirectAvatarView: View {
    let clubhouseDirectAvatarAddress: String
    let clubhouseDirectAvatarStyle: ClubhouseDirectAvatarStyle

    var body: some View {
        Group {
            if clubhouseDirectAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ZStack {
                    Circle()
                        .fill(clubhouseDirectAvatarGradient)

                    Image(systemName: clubhouseDirectAvatarSymbol)
                        .font(.system(size: 24, weight: .semibold))
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
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .frame(width: 50, height: 50)
    }

    private var clubhouseDirectAvatarSymbol: String {
        switch clubhouseDirectAvatarStyle {
        case .coursePlayer:
            return "figure.golf"
        case .fairwayFriend:
            return "person.crop.circle.fill"
        case .greenMember:
            return "person.fill"
        }
    }

    private var clubhouseDirectAvatarGradient: LinearGradient {
        switch clubhouseDirectAvatarStyle {
        case .coursePlayer:
            return LinearGradient(
                colors: [Color(red: 0.80, green: 0.88, blue: 0.72), Color(red: 0.22, green: 0.52, blue: 0.46)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fairwayFriend:
            return LinearGradient(
                colors: [Color(red: 0.94, green: 0.77, blue: 0.65), Color(red: 0.24, green: 0.40, blue: 0.44)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .greenMember:
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.62, blue: 0.55), Color(red: 0.45, green: 0.35, blue: 0.32)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    ClubhouseDirectMessageView {
    }
}
