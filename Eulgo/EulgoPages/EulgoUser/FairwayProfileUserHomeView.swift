import SwiftUI

struct FairwayProfileUserHomeView: View {
    @State private var fairwayProfileShowsSettings = false
    @State private var fairwayProfileShowsRecharge = false
    @State private var fairwayProfileRelationMode: FairwayUserRelationMode?
    @State private var fairwayProfileSelectedRoomID: String?
    @State private var fairwayProfileSelectedPostID: String?
    @State private var fairwayProfileShowsChatReminder = false
    @State private var fairwayProfileShowsReportSheet = false
    @State private var fairwayProfileShowsGuestRestriction = false
    @State private var fairwayProfileReportTargetUserID: String?
    @State private var fairwayProfileRefreshToken = UUID()

    let fairwayProfileUserID: String?
    let fairwayProfileBackAction: () -> Void

    init(
        fairwayProfileUserID: String? = nil,
        fairwayProfileBackAction: @escaping () -> Void
    ) {
        self.fairwayProfileUserID = fairwayProfileUserID
        self.fairwayProfileBackAction = fairwayProfileBackAction
    }

    var body: some View {
        GeometryReader { fairwayProfileProxy in
            let fairwayProfilePanelTop = min(fairwayProfileProxy.size.height * 0.40, 322)

            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                FairwayProfileHeroCoverView(fairwayProfileAvatarAddress: fairwayProfileDisplayedUser?.teeBoxAvatarAddress ?? "")
                    .frame(height: fairwayProfilePanelTop + 44)
                    .ignoresSafeArea(edges: .top)

                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 14,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: fairwayProfileBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        if fairwayProfileIsMine {
                            EmptyView()
                        } else {
                            VenueFairwayHeaderView.venueFairwayReportButton(action: fairwayProfileReportAction)
                        }
                    }
                )
                .padding(.top, 12)

                FairwayProfileInfoPanelView(
                    fairwayProfileUser: fairwayProfileDisplayedUser,
                    fairwayProfileIsMine: fairwayProfileIsMine,
                    fairwayProfileIsFollowing: fairwayProfileIsFollowingDisplayedUser,
                    fairwayProfileIsBlocked: fairwayProfileIsBlockedDisplayedUser,
                    fairwayProfilePosts: fairwayProfileDisplayedPosts,
                    fairwayProfileSettingsAction: {
                        fairwayProfileShowsSettings = true
                    },
                    fairwayProfileRechargeAction: {
                        guard GuestPassAccessGuard.guestPassIsGuest == false else {
                            fairwayProfileShowsGuestRestriction = true
                            return
                        }

                        fairwayProfileShowsRecharge = true
                    },
                    fairwayProfileFollowingAction: {
                        if fairwayProfileIsMine {
                            fairwayProfileRelationMode = .following
                        }
                    },
                    fairwayProfileFollowersAction: {
                        if fairwayProfileIsMine {
                            fairwayProfileRelationMode = .followers
                        }
                    },
                    fairwayProfileFollowAction: {
                        fairwayProfileToggleFollow()
                    },
                    fairwayProfileMessageAction: {
                        fairwayProfileOpenChatRoom()
                    },
                    fairwayProfilePostAction: { fairwayProfilePostID in
                        if BirdieClipVideoPostStore.birdieClipReadPost(birdieClipPostID: fairwayProfilePostID) != nil {
                            fairwayProfileSelectedPostID = fairwayProfilePostID
                        }
                    },
                    fairwayProfilePostReportAction: {
                        fairwayProfileShowReportSheet(targetUserID: fairwayProfileDisplayedUser?.teeBoxUserID)
                    }
                )
                    .frame(maxWidth: .infinity)
                    .frame(height: fairwayProfileProxy.size.height - fairwayProfilePanelTop + fairwayProfileProxy.safeAreaInsets.bottom)
                    .offset(y: fairwayProfilePanelTop)

                if fairwayProfileShowsSettings {
                    FairwaySettingsHomeView {
                        fairwayProfileShowsSettings = false
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(2)
                }

                if fairwayProfileShowsRecharge {
                    FairwayRechargeStoreView {
                        fairwayProfileShowsRecharge = false
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(3)
                }

                if let fairwayProfileRelationMode {
                    FairwayUserRelationListView(fairwayRelationMode: fairwayProfileRelationMode) {
                        self.fairwayProfileRelationMode = nil
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(4)
                }

                if let fairwayProfileSelectedRoomID {
                    ClubhouseDirectRoomView(clubhouseDirectRoomID: fairwayProfileSelectedRoomID) {
                        self.fairwayProfileSelectedRoomID = nil
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(5)
                }

                if let fairwayProfileSelectedPostID {
                    FairwaySocialPostDetailView(fairwaySocialPostID: fairwayProfileSelectedPostID) {
                        self.fairwayProfileSelectedPostID = nil
                        fairwayProfileRefreshToken = UUID()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(6)
                }

                if fairwayProfileShowsChatReminder {
                    CaddieBridgeChatReminderView {
                        fairwayProfileShowsChatReminder = false
                    }
                    .transition(.opacity)
                    .zIndex(7)
                }

                if fairwayProfileShowsGuestRestriction {
                    GuestPassBrowseOnlyView {
                        fairwayProfileShowsGuestRestriction = false
                    }
                    .transition(.opacity)
                    .zIndex(8)
                }
            }
        }
        .background(Color.black)
        .animation(.easeInOut(duration: 0.24), value: fairwayProfileShowsSettings)
        .animation(.easeInOut(duration: 0.24), value: fairwayProfileShowsRecharge)
        .animation(.easeInOut(duration: 0.24), value: fairwayProfileRelationMode?.fairwayRelationTitle)
        .animation(.easeInOut(duration: 0.24), value: fairwayProfileSelectedRoomID)
        .animation(.easeInOut(duration: 0.24), value: fairwayProfileSelectedPostID)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwayProfileShowsChatReminder)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwayProfileShowsGuestRestriction)
        .id(fairwayProfileRefreshToken)
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $fairwayProfileShowsReportSheet,
            caddieGuardTargetUserID: fairwayProfileReportTargetUserID,
            caddieGuardBlockSuccessAction: fairwayProfileBackAction
        )
        .greenPathSwipeBack(greenPathBackAction: fairwayProfileBackAction)
    }

    private var fairwayProfileResolvedUserID: String? {
        fairwayProfileUserID ?? PlayerBadgeSessionStore.playerBadgeCurrentUserID
    }

    private var fairwayProfileDisplayedUser: TeeBoxUserModel? {
        guard let fairwayProfileResolvedUserID else {
            return nil
        }

        return TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: fairwayProfileResolvedUserID)
    }

    private var fairwayProfileCurrentUser: TeeBoxUserModel? {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()
    }

    private var fairwayProfileIsMine: Bool {
        guard let fairwayProfileResolvedUserID,
              let fairwayProfileCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID else {
            return true
        }

        return fairwayProfileResolvedUserID == fairwayProfileCurrentUserID
    }

    private var fairwayProfileIsFollowingDisplayedUser: Bool {
        guard let fairwayProfileDisplayedUser,
              let fairwayProfileCurrentUser else {
            return false
        }

        return fairwayProfileCurrentUser.teeBoxFollowingIDs.contains(fairwayProfileDisplayedUser.teeBoxUserID)
    }

    private var fairwayProfileIsBlockedDisplayedUser: Bool {
        guard let fairwayProfileDisplayedUser,
              let fairwayProfileCurrentUser,
              fairwayProfileIsMine == false else {
            return false
        }

        return fairwayProfileCurrentUser.teeBoxBlockedUserIDs.contains(fairwayProfileDisplayedUser.teeBoxUserID)
    }

    private var fairwayProfileDisplayedPosts: [FairwayProfilePostModel] {
        if fairwayProfileIsBlockedDisplayedUser {
            return []
        }

        guard let fairwayProfileDisplayedUser else {
            return []
        }

        let fairwayProfileUserPosts = BirdieClipVideoPostStore.birdieClipReadAllPosts()
            .filter { $0.birdieClipPublisherID == fairwayProfileDisplayedUser.teeBoxUserID }
            .enumerated()
            .map { fairwayProfileIndex, fairwayProfilePost in
                FairwayProfilePostModel(
                    fairwayProfilePostID: fairwayProfilePost.birdieClipPostID,
                    fairwayProfileImageAddress: fairwayProfilePost.birdieClipCoverAddress,
                    fairwayProfileSymbolName: fairwayProfileIndex.isMultiple(of: 2) ? "figure.golf" : "flag.fill",
                    fairwayProfileStyle: fairwayProfileIndex.isMultiple(of: 2) ? .course : .sky
                )
            }

        return fairwayProfileUserPosts
    }

    private func fairwayProfileToggleFollow() {
        guard var fairwayProfileCurrentUser,
              var fairwayProfileDisplayedUser,
              fairwayProfileIsMine == false else {
            return
        }

        guard fairwayProfileCurrentUser.teeBoxIsGuest == false else {
            fairwayProfileShowsGuestRestriction = true
            return
        }

        if fairwayProfileCurrentUser.teeBoxFollowingIDs.contains(fairwayProfileDisplayedUser.teeBoxUserID) {
            fairwayProfileCurrentUser.teeBoxFollowingIDs.removeAll { $0 == fairwayProfileDisplayedUser.teeBoxUserID }
            fairwayProfileDisplayedUser.teeBoxFollowerIDs.removeAll { $0 == fairwayProfileCurrentUser.teeBoxUserID }
        } else {
            fairwayProfileCurrentUser.teeBoxFollowingIDs.append(fairwayProfileDisplayedUser.teeBoxUserID)
            fairwayProfileDisplayedUser.teeBoxFollowerIDs.append(fairwayProfileCurrentUser.teeBoxUserID)
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayProfileCurrentUser)
        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayProfileDisplayedUser)
        fairwayProfileRefreshToken = UUID()
    }

    private func fairwayProfileOpenChatRoom() {
        guard let fairwayProfileCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID,
              let fairwayProfileCurrentUser,
              let fairwayProfileDisplayedUser,
              fairwayProfileDisplayedUser.teeBoxUserID != fairwayProfileCurrentUserID else {
            return
        }

        guard fairwayProfileCurrentUser.teeBoxIsGuest == false else {
            fairwayProfileShowsGuestRestriction = true
            return
        }

        let fairwayProfileMutualFollow =
            fairwayProfileCurrentUser.teeBoxFollowingIDs.contains(fairwayProfileDisplayedUser.teeBoxUserID)
            && fairwayProfileDisplayedUser.teeBoxFollowingIDs.contains(fairwayProfileCurrentUserID)

        guard fairwayProfileMutualFollow else {
            fairwayProfileShowsChatReminder = true
            return
        }

        if let fairwayProfileExistingRoom = ClubPairChatRoomStore.clubPairReadRooms(clubPairUserID: fairwayProfileCurrentUserID)
            .first(where: { $0.clubPairUserIDs.contains(fairwayProfileDisplayedUser.teeBoxUserID) }) {
            fairwayProfileSelectedRoomID = fairwayProfileExistingRoom.clubPairRoomID
            return
        }

        let fairwayProfileRoom = ClubPairChatRoomModel(
            clubPairUserIDs: [fairwayProfileCurrentUserID, fairwayProfileDisplayedUser.teeBoxUserID]
        )
        _ = ClubPairChatRoomStore.clubPairCreateRoom(fairwayProfileRoom)
        fairwayProfileSelectedRoomID = fairwayProfileRoom.clubPairRoomID
    }

    private func fairwayProfileReportAction() {
        fairwayProfileShowReportSheet(targetUserID: fairwayProfileDisplayedUser?.teeBoxUserID)
    }

    private func fairwayProfileShowReportSheet(targetUserID: String?) {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwayProfileShowsGuestRestriction = true
            return
        }

        fairwayProfileReportTargetUserID = targetUserID
        fairwayProfileShowsReportSheet = true
    }
}

private struct FairwayProfileHeroCoverView: View {
    let fairwayProfileAvatarAddress: String

    var body: some View {
        ZStack(alignment: .bottom) {
            if fairwayProfileAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                FairwayProfileFallbackCoverView()
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: fairwayProfileAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                    fairwayGalleryFailureIconName: "person.crop.circle.fill"
                )
            }

            LinearGradient(
                colors: [
                    .black.opacity(0.18),
                    .black.opacity(0.04),
                    .black.opacity(0.34)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipped()
    }
}

private struct FairwayProfileFallbackCoverView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.77, green: 0.79, blue: 0.73),
                    Color(red: 0.44, green: 0.58, blue: 0.39),
                    Color(red: 0.71, green: 0.75, blue: 0.62)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 132, weight: .medium))
                .foregroundStyle(.white.opacity(0.48))
        }
    }
}

private struct FairwayProfileInfoPanelView: View {
    let fairwayProfileUser: TeeBoxUserModel?
    let fairwayProfileIsMine: Bool
    let fairwayProfileIsFollowing: Bool
    let fairwayProfileIsBlocked: Bool
    let fairwayProfilePosts: [FairwayProfilePostModel]
    let fairwayProfileSettingsAction: () -> Void
    let fairwayProfileRechargeAction: () -> Void
    let fairwayProfileFollowingAction: () -> Void
    let fairwayProfileFollowersAction: () -> Void
    let fairwayProfileFollowAction: () -> Void
    let fairwayProfileMessageAction: () -> Void
    let fairwayProfilePostAction: (String) -> Void
    let fairwayProfilePostReportAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 17) {
                Text(fairwayProfileDisplayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)

                HStack(spacing: 76) {
                    FairwayProfileMetricView(
                        fairwayProfileValue: "\(fairwayProfileUser?.teeBoxFollowingIDs.count ?? 0)",
                        fairwayProfileLabel: "Following",
                        fairwayProfileAction: fairwayProfileFollowingAction
                    )
                    FairwayProfileMetricView(
                        fairwayProfileValue: "\(fairwayProfileUser?.teeBoxFollowerIDs.count ?? 0)",
                        fairwayProfileLabel: "Followers",
                        fairwayProfileAction: fairwayProfileFollowersAction
                    )
                }

                HStack(spacing: 10) {
                    if fairwayProfileIsMine {
                        FairwayProfileSettingsButton(fairwayProfileSettingsAction: fairwayProfileSettingsAction)
                        FairwayProfileCoinButton(
                            fairwayProfileCoinCount: fairwayProfileUser?.teeBoxCoinCount ?? 0,
                            fairwayProfileCoinAction: fairwayProfileRechargeAction
                        )
                    } else if fairwayProfileIsBlocked {
                        FairwayProfileBlockedStatusView()
                    } else {
                        FairwayProfileFollowButton(
                            fairwayProfileIsFollowing: fairwayProfileIsFollowing,
                            fairwayProfileFollowAction: fairwayProfileFollowAction
                        )
                        FairwayProfileMessageButton(fairwayProfileMessageAction: fairwayProfileMessageAction)
                    }
                }
                .padding(.top, 2)

                if fairwayProfileIsBlocked {
                    FairwayProfileBlockedReminderView()
                }

                if fairwayProfilePosts.isEmpty == false {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(fairwayProfilePosts) { fairwayProfilePost in
                            FairwayProfilePostCardView(
                                fairwayProfilePost: fairwayProfilePost,
                                fairwayProfileOpenAction: {
                                    fairwayProfilePostAction(fairwayProfilePost.fairwayProfilePostID)
                                },
                                fairwayProfileShowsReportButton: fairwayProfileIsMine == false,
                                fairwayProfileReportAction: {
                                    fairwayProfilePostReportAction()
                                }
                            )
                            .frame(height: 240)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 13)

            Spacer(minLength: 0)
        }
        .background(Color(red: 0.04, green: 0.05, blue: 0.06))
        .clipShape(FairwayProfileTopRoundedShape(fairwayProfileRadius: 22))
    }

    private var fairwayProfileDisplayName: String {
        guard let fairwayProfileUser else {
            return "Eulgo Player"
        }

        let fairwayProfileTrimmedName = fairwayProfileUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return fairwayProfileTrimmedName.isEmpty ? fairwayProfileUser.teeBoxEmail : fairwayProfileTrimmedName
    }
}

private struct FairwayProfileMetricView: View {
    let fairwayProfileValue: String
    let fairwayProfileLabel: String
    let fairwayProfileAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileAction) {
            VStack(spacing: 6) {
                Text(fairwayProfileValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text(fairwayProfileLabel)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.62))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileSettingsButton: View {
    let fairwayProfileSettingsAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileSettingsAction) {
            HStack(spacing: 7) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12, weight: .bold))

                Text("Settings")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileCoinButton: View {
    let fairwayProfileCoinCount: Int
    let fairwayProfileCoinAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileCoinAction) {
            HStack(spacing: 8) {
                Image("EULGO_coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)

                Text("\(fairwayProfileCoinCount)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)

                Spacer(minLength: 0)

                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color(red: 0.02, green: 0.18, blue: 0.16))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(FairwayStylePalette.fairwayBrandGradient())
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileFollowButton: View {
    let fairwayProfileIsFollowing: Bool
    let fairwayProfileFollowAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileFollowAction) {
            Text(fairwayProfileIsFollowing ? "Followed" : "+ Follow")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(fairwayProfileIsFollowing ? Color.white.opacity(0.82) : FairwayStylePalette.fairwaySuccessGreen)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileMessageButton: View {
    let fairwayProfileMessageAction: () -> Void

    var body: some View {
        Button(action: fairwayProfileMessageAction) {
            Text("Message")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FairwayProfileBlockedStatusView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "nosign")
                .font(.system(size: 14, weight: .bold))

            Text("Blocked")
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(Color.white.opacity(0.16))
        .clipShape(Capsule())
    }
}

private struct FairwayProfileBlockedReminderView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 1.0, green: 0.69, blue: 0.10))
                .padding(.top, 1)

            Text("You have blocked this user. Their posts and messages will be hidden from your feed.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

private struct FairwayProfilePostModel: Identifiable {
    enum FairwayProfilePostStyle {
        case course
        case sky
    }

    let fairwayProfilePostID: String
    let fairwayProfileImageAddress: String
    let fairwayProfileSymbolName: String
    let fairwayProfileStyle: FairwayProfilePostStyle

    var id: String { fairwayProfilePostID }

}

private struct FairwayProfilePostCardView: View {
    let fairwayProfilePost: FairwayProfilePostModel
    let fairwayProfileOpenAction: () -> Void
    let fairwayProfileShowsReportButton: Bool
    let fairwayProfileReportAction: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            FairwayProfilePostImageView(fairwayProfilePost: fairwayProfilePost)

            if fairwayProfileShowsReportButton {
                Button(action: fairwayProfileReportAction) {
                    Image("EULGO_report_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.46))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(7)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .onTapGesture(perform: fairwayProfileOpenAction)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

private struct FairwayProfilePostImageView: View {
    let fairwayProfilePost: FairwayProfilePostModel

    var body: some View {
        ZStack {
            if fairwayProfilePost.fairwayProfileImageAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: fairwayProfilePost.fairwayProfileImageAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                    fairwayGalleryFailureIconName: "photo"
                )
            } else {
                LinearGradient(
                    colors: fairwayProfilePost.fairwayProfileStyle == .course ? fairwayProfileCourseColors : fairwayProfileSkyColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if fairwayProfilePost.fairwayProfileStyle == .course {
                    Image("EULGO_golf_person")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 210)
                        .offset(x: -6, y: 25)
                } else {
                    Image(systemName: fairwayProfilePost.fairwayProfileSymbolName)
                        .font(.system(size: 76, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                        .rotationEffect(.degrees(-18))
                        .offset(y: -12)

                    Image(systemName: "figure.golf")
                        .font(.system(size: 74, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .offset(x: 20, y: 46)
                }
            }
        }
    }

    private var fairwayProfileCourseColors: [Color] {
        [
            Color(red: 0.18, green: 0.33, blue: 0.20),
            Color(red: 0.49, green: 0.58, blue: 0.40),
            Color(red: 0.10, green: 0.15, blue: 0.12)
        ]
    }

    private var fairwayProfileSkyColors: [Color] {
        [
            Color(red: 0.70, green: 0.84, blue: 0.97),
            Color(red: 0.96, green: 0.95, blue: 0.91),
            Color(red: 0.22, green: 0.42, blue: 0.72)
        ]
    }
}

private struct FairwayProfileTopRoundedShape: Shape {
    let fairwayProfileRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var fairwayProfilePath = Path()
        let fairwayProfileRadius = min(fairwayProfileRadius, min(rect.width, rect.height) / 2)

        fairwayProfilePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        fairwayProfilePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + fairwayProfileRadius))
        fairwayProfilePath.addQuadCurve(
            to: CGPoint(x: rect.minX + fairwayProfileRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        fairwayProfilePath.addLine(to: CGPoint(x: rect.maxX - fairwayProfileRadius, y: rect.minY))
        fairwayProfilePath.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + fairwayProfileRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        fairwayProfilePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        fairwayProfilePath.closeSubpath()

        return fairwayProfilePath
    }
}

#Preview {
    FairwayProfileUserHomeView {
    }
}
