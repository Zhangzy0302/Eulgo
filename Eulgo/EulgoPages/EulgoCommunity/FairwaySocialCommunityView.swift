import SwiftUI

struct FairwaySocialCommunityView: View {
    let fairwaySocialBackAction: () -> Void

    @State private var fairwaySocialSelectedPostID: String?
    @State private var fairwaySocialSelectedUserID: String?
    @State private var fairwaySocialShowsPostComposer = false
    @State private var fairwaySocialShowsReportSheet = false
    @State private var fairwaySocialShowsGuestRestriction = false
    @State private var fairwaySocialReportTargetUserID: String?
    @State private var fairwaySocialRefreshToken = UUID()

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(alignment: .leading, spacing: 18) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 16,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: fairwaySocialBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        FairwaySocialCameraButton(fairwaySocialCameraAction: fairwaySocialCameraAction)
                    }
                )


                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(fairwaySocialStoryMembers) { fairwaySocialMember in
                            FairwaySocialStoryBubbleView(
                                fairwaySocialMember: fairwaySocialMember,
                                fairwaySocialAvatarAction: {
                                    fairwaySocialSelectedUserID = fairwaySocialMember.fairwaySocialUserID
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ForEach(fairwaySocialPosts) { fairwaySocialPost in
                            FairwaySocialPostCardView(
                                fairwaySocialPost: fairwaySocialPost,
                                fairwaySocialOpenAction: {
                                    fairwaySocialSelectedPostID = fairwaySocialPost.fairwaySocialPostID
                                },
                                fairwaySocialAvatarAction: {
                                    fairwaySocialSelectedUserID = fairwaySocialPost.fairwaySocialPublisherID
                                },
                                fairwaySocialLikeAction: {
                                    fairwaySocialTogglePostLike(fairwaySocialPostID: fairwaySocialPost.fairwaySocialPostID)
                                },
                                fairwaySocialShowsReportButton: fairwaySocialPost.fairwaySocialPublisherID != PlayerBadgeSessionStore.playerBadgeCurrentUserID,
                                fairwaySocialReportAction: {
                                    fairwaySocialShowReportSheet(targetUserID: fairwaySocialPost.fairwaySocialPublisherID)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }

                
            }

            if let fairwaySocialSelectedPostID {
                FairwaySocialPostDetailView(fairwaySocialPostID: fairwaySocialSelectedPostID) {
                    self.fairwaySocialSelectedPostID = nil
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
            }

            if fairwaySocialShowsPostComposer {
                PinFlagPostComposerView(
                    pinFlagBackAction: {
                        fairwaySocialShowsPostComposer = false
                    },
                    pinFlagPostSuccessAction: {
                        fairwaySocialShowsPostComposer = false
                        fairwaySocialRefreshToken = UUID()
                    }
                )
                .fairwayGreenDismissKeyboardOnTap()
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(2)
            }

            if let fairwaySocialSelectedUserID {
                FairwayProfileUserHomeView(fairwayProfileUserID: fairwaySocialSelectedUserID) {
                    self.fairwaySocialSelectedUserID = nil
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(3)
            }

            if fairwaySocialShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    fairwaySocialShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(4)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: fairwaySocialSelectedPostID)
        .animation(.easeInOut(duration: 0.24), value: fairwaySocialSelectedUserID)
        .animation(.easeInOut(duration: 0.24), value: fairwaySocialShowsPostComposer)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwaySocialShowsGuestRestriction)
        .id(fairwaySocialRefreshToken)
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $fairwaySocialShowsReportSheet,
            caddieGuardTargetUserID: fairwaySocialReportTargetUserID,
            caddieGuardBlockSuccessAction: {
                fairwaySocialRefreshToken = UUID()
            }
        )
        .greenPathSwipeBack(greenPathBackAction: fairwaySocialBackAction)
    }

    private func fairwaySocialCameraAction() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySocialShowsGuestRestriction = true
            return
        }

        fairwaySocialShowsPostComposer = true
    }

    private func fairwaySocialShowReportSheet(targetUserID: String?) {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySocialShowsGuestRestriction = true
            return
        }

        fairwaySocialReportTargetUserID = targetUserID
        fairwaySocialShowsReportSheet = true
    }

    private var fairwaySocialStoryMembers: [FairwaySocialStoryMember] {
        let fairwaySocialCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser()
        let fairwaySocialBlockedUserIDs = Set(fairwaySocialCurrentUser?.teeBoxBlockedUserIDs ?? [])
        let fairwaySocialCurrentUserID = fairwaySocialCurrentUser?.teeBoxUserID

        return TeeBoxUserStore.teeBoxReadAllUsers()
            .filter { fairwaySocialUser in
                fairwaySocialUser.teeBoxIsGuest == false
                && fairwaySocialUser.teeBoxUserID != fairwaySocialCurrentUserID
                && fairwaySocialBlockedUserIDs.contains(fairwaySocialUser.teeBoxUserID) == false
            }
            .sorted {
                $0.teeBoxUsername.localizedCaseInsensitiveCompare($1.teeBoxUsername) == .orderedAscending
            }
            .enumerated()
            .map { fairwaySocialIndex, fairwaySocialUser in
                FairwaySocialStoryMember(
                    fairwaySocialUserID: fairwaySocialUser.teeBoxUserID,
                    fairwaySocialName: fairwaySocialDisplayName(for: fairwaySocialUser),
                    fairwaySocialAvatarAddress: fairwaySocialUser.teeBoxAvatarAddress,
                    fairwaySocialStyle: fairwaySocialAvatarStyle(for: fairwaySocialIndex)
                )
            }
    }

    private func fairwaySocialDisplayName(for fairwaySocialUser: TeeBoxUserModel) -> String {
        let fairwaySocialTrimmedName = fairwaySocialUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)

        if fairwaySocialTrimmedName.isEmpty == false {
            return fairwaySocialTrimmedName
        }

        return fairwaySocialUser.teeBoxEmail
    }

    private func fairwaySocialAvatarStyle(for fairwaySocialIndex: Int) -> FairwaySocialAvatarStyle {
        let fairwaySocialStyles: [FairwaySocialAvatarStyle] = [.rose, .ocean, .sunny, .mint, .twilight]
        return fairwaySocialStyles[fairwaySocialIndex % fairwaySocialStyles.count]
    }

    private var fairwaySocialPosts: [FairwaySocialPost] {
        let fairwaySocialUsers = TeeBoxUserStore.teeBoxReadAllUsers()
        let fairwaySocialUsersByID = Dictionary(uniqueKeysWithValues: fairwaySocialUsers.map { ($0.teeBoxUserID, $0) })
        let fairwaySocialBlockedUserIDs = Set(PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxBlockedUserIDs ?? [])
        let fairwaySocialLikedPostIDs = Set(PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxLikedPostIDs ?? [])

        return BirdieClipVideoPostStore.birdieClipReadAllPosts()
            .reversed()
            .filter { fairwaySocialPost in
                fairwaySocialBlockedUserIDs.contains(fairwaySocialPost.birdieClipPublisherID) == false
            }
            .enumerated()
            .map { fairwaySocialIndex, fairwaySocialPost in
                let fairwaySocialUser = fairwaySocialUsersByID[fairwaySocialPost.birdieClipPublisherID]
                let fairwaySocialCommentCount = GreenNoteCommentStore.greenNoteReadComments(
                    greenNoteVideoID: fairwaySocialPost.birdieClipPostID
                ).count

                return FairwaySocialPost(
                    fairwaySocialPostID: fairwaySocialPost.birdieClipPostID,
                    fairwaySocialPublisherID: fairwaySocialPost.birdieClipPublisherID,
                    fairwaySocialName: fairwaySocialUser.map(fairwaySocialDisplayName(for:)) ?? "Eulgo Player",
                    fairwaySocialAvatarAddress: fairwaySocialUser?.teeBoxAvatarAddress ?? "",
                    fairwaySocialCoverAddress: fairwaySocialPost.birdieClipCoverAddress,
                    fairwaySocialVideoAddress: fairwaySocialPost.birdieClipVideoAddress,
                    fairwaySocialTime: "2 mins ago",
                    fairwaySocialCaption: fairwaySocialPost.birdieClipCaptionText,
                    fairwaySocialLikes: "\(fairwaySocialPost.birdieClipLikeCount) Like",
                    fairwaySocialComments: "\(fairwaySocialCommentCount)",
                    fairwaySocialStyle: fairwaySocialPostStyle(for: fairwaySocialIndex),
                    fairwaySocialIsLiked: fairwaySocialLikedPostIDs.contains(fairwaySocialPost.birdieClipPostID)
                )
            }
    }

    private func fairwaySocialPostStyle(for fairwaySocialIndex: Int) -> FairwaySocialPostStyle {
        fairwaySocialIndex.isMultiple(of: 2) ? .greenPlayer : .clubhouseWall
    }

    private func fairwaySocialTogglePostLike(fairwaySocialPostID: String) {
        guard var fairwaySocialCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser(),
              var fairwaySocialStoredPost = BirdieClipVideoPostStore.birdieClipReadPost(birdieClipPostID: fairwaySocialPostID) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard fairwaySocialCurrentUser.teeBoxIsGuest == false else {
            fairwaySocialShowsGuestRestriction = true
            return
        }

        if fairwaySocialCurrentUser.teeBoxLikedPostIDs.contains(fairwaySocialPostID) {
            fairwaySocialCurrentUser.teeBoxLikedPostIDs.removeAll { $0 == fairwaySocialPostID }
            fairwaySocialStoredPost.birdieClipLikeCount = max(0, fairwaySocialStoredPost.birdieClipLikeCount - 1)
        } else {
            fairwaySocialCurrentUser.teeBoxLikedPostIDs.append(fairwaySocialPostID)
            fairwaySocialStoredPost.birdieClipLikeCount += 1
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwaySocialCurrentUser)
        _ = BirdieClipVideoPostStore.birdieClipUpdatePost(fairwaySocialStoredPost)
        fairwaySocialRefreshToken = UUID()
    }
}

private struct FairwaySocialStoryMember: Identifiable {
    let fairwaySocialUserID: String
    let fairwaySocialName: String
    let fairwaySocialAvatarAddress: String
    let fairwaySocialStyle: FairwaySocialAvatarStyle

    var id: String { fairwaySocialUserID }
}

struct FairwaySocialPost: Identifiable {
    let fairwaySocialPostID: String
    let fairwaySocialPublisherID: String
    let fairwaySocialName: String
    let fairwaySocialAvatarAddress: String
    let fairwaySocialCoverAddress: String
    let fairwaySocialVideoAddress: String
    let fairwaySocialTime: String
    let fairwaySocialCaption: String
    let fairwaySocialLikes: String
    let fairwaySocialComments: String
    let fairwaySocialStyle: FairwaySocialPostStyle
    let fairwaySocialIsLiked: Bool

    var id: String { fairwaySocialPostID }
}

enum FairwaySocialAvatarStyle {
    case rose
    case ocean
    case sunny
    case mint
    case twilight
}

enum FairwaySocialPostStyle {
    case greenPlayer
    case clubhouseWall
}

private struct FairwaySocialCameraButton: View {
    let fairwaySocialCameraAction: () -> Void

    var body: some View {
        Button(action: fairwaySocialCameraAction) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                FairwayStylePalette.fairwayCameraLime,
                                FairwayStylePalette.fairwayCameraMint
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Image("EULGO_camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }
}

private struct FairwaySocialStoryBubbleView: View {
    let fairwaySocialMember: FairwaySocialStoryMember
    let fairwaySocialAvatarAction: () -> Void

    var body: some View {
        Button(action: fairwaySocialAvatarAction) {
            VStack(spacing: 7) {
                if fairwaySocialMember.fairwaySocialAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    FairwaySocialAvatarView(
                        fairwaySocialStyle: fairwaySocialMember.fairwaySocialStyle,
                        fairwaySocialSize: 56,
                        fairwaySocialShowsRing: true
                    )
                } else {
                    FairwayGalleryImageView(
                        fairwayGalleryImageAddress: fairwaySocialMember.fairwaySocialAvatarAddress,
                        fairwayGalleryContentMode: .fill,
                        fairwayGalleryPlaceholderColor: Color.white.opacity(0.18),
                        fairwayGalleryFailureIconName: "person.fill"
                    )
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.73, green: 0.96, blue: 0.20), lineWidth: 1.6)
                    )
                }

                Text(fairwaySocialMember.fairwaySocialName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(width: 58)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct FairwaySocialPostCardView: View {
    let fairwaySocialPost: FairwaySocialPost
    let fairwaySocialOpenAction: () -> Void
    let fairwaySocialAvatarAction: () -> Void
    let fairwaySocialLikeAction: () -> Void
    let fairwaySocialShowsReportButton: Bool
    let fairwaySocialReportAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Button(action: fairwaySocialAvatarAction) {
                    FairwaySocialUserAvatarBadge(
                        fairwaySocialAvatarAddress: fairwaySocialPost.fairwaySocialAvatarAddress,
                        fairwaySocialStyle: fairwaySocialPost.fairwaySocialStyle == .greenPlayer ? .rose : .twilight,
                        fairwaySocialSize: 28,
                        fairwaySocialShowsRing: false
                    )
                }
                .buttonStyle(.plain)

                Text(fairwaySocialPost.fairwaySocialName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text(fairwaySocialPost.fairwaySocialTime)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.white.opacity(0.58))
            }

            ZStack(alignment: .bottomLeading) {
                FairwaySocialPostImageView(
                    fairwaySocialCoverAddress: fairwaySocialPost.fairwaySocialCoverAddress,
                    fairwaySocialStyle: fairwaySocialPost.fairwaySocialStyle
                )
                    .frame(height: 268)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        FairwayStylePalette.fairwaySheetMask
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(fairwaySocialPost.fairwaySocialCaption)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)

                FairwaySocialActionPillView(
                    fairwaySocialPost: fairwaySocialPost,
                    fairwaySocialLikeAction: fairwaySocialLikeAction,
                    fairwaySocialShowsReportButton: fairwaySocialShowsReportButton,
                    fairwaySocialReportAction: fairwaySocialReportAction
                )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(y: 30)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onTapGesture(perform: fairwaySocialOpenAction)
            .padding(.bottom, 30)
        }
    }
}

private struct FairwaySocialPostImageView: View {
    let fairwaySocialCoverAddress: String
    let fairwaySocialStyle: FairwaySocialPostStyle

    var body: some View {
        ZStack {
            if fairwaySocialCoverAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                FairwaySocialPostPlaceholderView(fairwaySocialStyle: fairwaySocialStyle)
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: fairwaySocialCoverAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                    fairwayGalleryFailureIconName: "photo"
                )
            }
        }
    }
}

private struct FairwaySocialPostPlaceholderView: View {
    let fairwaySocialStyle: FairwaySocialPostStyle

    private var fairwaySocialBackgroundColors: [Color] {
        switch fairwaySocialStyle {
        case .greenPlayer:
            return [
                Color(red: 0.70, green: 0.86, blue: 0.70),
                Color(red: 0.16, green: 0.36, blue: 0.19),
                Color(red: 0.74, green: 0.82, blue: 0.47)
            ]
        case .clubhouseWall:
            return [
                Color(red: 0.76, green: 0.62, blue: 0.50),
                Color(red: 0.38, green: 0.30, blue: 0.25),
                Color(red: 0.62, green: 0.72, blue: 0.46)
            ]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: fairwaySocialBackgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 160, height: 160)
                .offset(x: 94, y: -82)

            Image(systemName: fairwaySocialStyle == .greenPlayer ? "figure.golf" : "person.crop.square.fill")
                .font(.system(size: fairwaySocialStyle == .greenPlayer ? 92 : 104, weight: .semibold))
                .foregroundStyle(.white.opacity(0.74))

            Image(systemName: "flag.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(red: 0.78, green: 0.96, blue: 0.28).opacity(0.86))
                .offset(x: -104, y: -100)
        }
    }
}

private struct FairwaySocialActionPillView: View {
    let fairwaySocialPost: FairwaySocialPost
    let fairwaySocialLikeAction: () -> Void
    let fairwaySocialShowsReportButton: Bool
    let fairwaySocialReportAction: () -> Void

    var body: some View {
        HStack(spacing: 28) {
            Button(action: fairwaySocialLikeAction) {
                HStack(spacing: 8) {
                    if fairwaySocialPost.fairwaySocialIsLiked {
                        Image("EULGO_liked")
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Image("EULGO_like")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.black)
                            .frame(width: 24, height: 24)
                    }

                    Text(fairwaySocialPost.fairwaySocialLikes)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(fairwaySocialPost.fairwaySocialIsLiked ? FairwayStylePalette.fairwayLikePink : .black)
                }
            }
            .buttonStyle(.plain)

            Button(action: fairwaySocialCommentAction) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)

                    Text(fairwaySocialPost.fairwaySocialComments)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)

            if fairwaySocialShowsReportButton {
                Button(action: fairwaySocialReportAction) {
                    Image("EULGO_report_icon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func fairwaySocialCommentAction() {
    }

}

struct FairwaySocialAvatarView: View {
    let fairwaySocialStyle: FairwaySocialAvatarStyle
    let fairwaySocialSize: CGFloat
    let fairwaySocialShowsRing: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: fairwaySocialColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: fairwaySocialSymbolName)
                .font(.system(size: fairwaySocialSize * 0.42, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
        }
        .frame(width: fairwaySocialSize, height: fairwaySocialSize)
        .overlay(
            Circle()
                .stroke(
                    fairwaySocialShowsRing ? Color(red: 0.73, green: 0.96, blue: 0.20) : Color.white.opacity(0.18),
                    lineWidth: fairwaySocialShowsRing ? 1.6 : 1
                )
        )
    }

    private var fairwaySocialColors: [Color] {
        switch fairwaySocialStyle {
        case .rose:
            return [Color(red: 0.98, green: 0.66, blue: 0.72), Color(red: 0.66, green: 0.48, blue: 0.45)]
        case .ocean:
            return [Color(red: 0.70, green: 0.82, blue: 0.86), Color(red: 0.16, green: 0.40, blue: 0.45)]
        case .sunny:
            return [Color(red: 0.96, green: 0.78, blue: 0.36), Color(red: 0.56, green: 0.72, blue: 0.36)]
        case .mint:
            return [Color(red: 0.72, green: 0.92, blue: 0.62), Color(red: 0.22, green: 0.50, blue: 0.42)]
        case .twilight:
            return [Color(red: 0.54, green: 0.46, blue: 0.78), Color(red: 0.24, green: 0.28, blue: 0.36)]
        }
    }

    private var fairwaySocialSymbolName: String {
        switch fairwaySocialStyle {
        case .ocean, .mint:
            return "figure.golf"
        default:
            return "person.fill"
        }
    }
}

struct FairwaySocialUserAvatarBadge: View {
    let fairwaySocialAvatarAddress: String
    let fairwaySocialStyle: FairwaySocialAvatarStyle
    let fairwaySocialSize: CGFloat
    let fairwaySocialShowsRing: Bool

    var body: some View {
        if fairwaySocialAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            FairwaySocialAvatarView(
                fairwaySocialStyle: fairwaySocialStyle,
                fairwaySocialSize: fairwaySocialSize,
                fairwaySocialShowsRing: fairwaySocialShowsRing
            )
        } else {
            FairwayGalleryImageView(
                fairwayGalleryImageAddress: fairwaySocialAvatarAddress,
                fairwayGalleryContentMode: .fill,
                fairwayGalleryPlaceholderColor: Color.white.opacity(0.18),
                fairwayGalleryFailureIconName: "person.fill"
            )
            .frame(width: fairwaySocialSize, height: fairwaySocialSize)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        fairwaySocialShowsRing ? Color(red: 0.73, green: 0.96, blue: 0.20) : Color.white.opacity(0.18),
                        lineWidth: fairwaySocialShowsRing ? 1.6 : 1
                    )
            )
        }
    }
}

#Preview {
    FairwaySocialCommunityView {
    }
}
