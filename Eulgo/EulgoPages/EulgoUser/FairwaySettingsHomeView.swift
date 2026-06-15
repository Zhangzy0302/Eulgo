import SwiftUI

struct FairwaySettingsHomeView: View {
    @State private var fairwaySettingsShowsProfileEdit = false
    @State private var fairwaySettingsShowsBlacklist = false
    @State private var fairwaySettingsShowsDeleteAlert = false
    @State private var fairwaySettingsShowsGuestRestriction = false
    @State private var fairwaySettingsWebAddress: String?

    let fairwaySettingsBackAction: () -> Void

    private let fairwaySettingsItems = [
        "Edit personal profile",
        "Blacklist",
        "User Agreement",
        "Privacy Agreement"
    ]

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: "Settings",
                    venueFairwayBackAction: fairwaySettingsBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 14
                )
                .padding(.top, 14)

                VStack(spacing: 20) {
                    ForEach(fairwaySettingsItems, id: \.self) { fairwaySettingsItem in
                        FairwaySettingsMenuRowView(
                            fairwaySettingsTitle: fairwaySettingsItem,
                            fairwaySettingsAction: {
                                fairwaySettingsMenuAction(fairwaySettingsItem)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)

                Spacer()

                VStack(spacing: 18) {
                    Button(action: fairwaySettingsDeleteAccountAction) {
                        Text("Delete Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 1.0, green: 0.68, blue: 0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button(action: fairwaySettingsLogOutAction) {
                        Text("Log Out")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(FairwayStylePalette.fairwayBrandGradient())
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }

            if fairwaySettingsShowsProfileEdit {
                FairwayProfileEditView {
                    fairwaySettingsShowsProfileEdit = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
            }

            if fairwaySettingsShowsBlacklist {
                FairwayUserRelationListView(fairwayRelationMode: .blacklist) {
                    fairwaySettingsShowsBlacklist = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(2)
            }

            if fairwaySettingsShowsDeleteAlert {
                FairwayAccountDeleteAlertView(
                    fairwayAccountCancelAction: {
                        fairwaySettingsShowsDeleteAlert = false
                    },
                    fairwayAccountConfirmAction: {
                        fairwaySettingsConfirmDeleteAccount()
                    }
                )
                .transition(.opacity)
                .zIndex(3)
            }

            if let fairwaySettingsWebAddress {
                LinkBridgeWebDisplayView(linkBridgeWebAddress: fairwaySettingsWebAddress) {
                    self.fairwaySettingsWebAddress = nil
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(4)
            }

            if fairwaySettingsShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    fairwaySettingsShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(5)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: fairwaySettingsShowsProfileEdit)
        .animation(.easeInOut(duration: 0.24), value: fairwaySettingsShowsBlacklist)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwaySettingsShowsDeleteAlert)
        .animation(.easeInOut(duration: 0.24), value: fairwaySettingsWebAddress)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwaySettingsShowsGuestRestriction)
        .greenPathSwipeBack(greenPathBackAction: fairwaySettingsBackAction)
    }

    private func fairwaySettingsMenuAction(_ fairwaySettingsItem: String) {
        if fairwaySettingsItem == "Edit personal profile" {
            guard GuestPassAccessGuard.guestPassIsGuest == false else {
                fairwaySettingsShowsGuestRestriction = true
                return
            }

            fairwaySettingsShowsProfileEdit = true
        } else if fairwaySettingsItem == "Blacklist" {
            guard GuestPassAccessGuard.guestPassIsGuest == false else {
                fairwaySettingsShowsGuestRestriction = true
                return
            }

            fairwaySettingsShowsBlacklist = true
        } else if fairwaySettingsItem == "User Agreement" {
            fairwaySettingsWebAddress = "https://app.wnhliu2m.link/users"
        } else if fairwaySettingsItem == "Privacy Agreement" {
            fairwaySettingsWebAddress = "https://app.wnhliu2m.link/privacy"
        }
    }

    private func fairwaySettingsDeleteAccountAction() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySettingsShowsGuestRestriction = true
            return
        }

        fairwaySettingsShowsDeleteAlert = true
    }

    private func fairwaySettingsLogOutAction() {
        PlayerBadgeSessionStore.playerBadgeClearLoginUser()
    }

    private func fairwaySettingsConfirmDeleteAccount() {
        guard let fairwaySettingsCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            fairwaySettingsShowsDeleteAlert = false
            PlayerBadgeSessionStore.playerBadgeClearLoginUser()
            return
        }

        fairwaySettingsShowsDeleteAlert = false
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            fairwaySettingsDeleteAccountData(fairwaySettingsCurrentUser)
        }
    }

    private func fairwaySettingsDeleteAccountData(_ fairwaySettingsCurrentUser: TeeBoxUserModel) {
        let fairwaySettingsUserID = fairwaySettingsCurrentUser.teeBoxUserID
        fairwaySettingsDeleteUserOwnedPosts(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsDeleteUserComments(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsDeleteUserRatings(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsDeleteUserChatRooms(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsCleanUserRelations(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsCleanUserActivities(fairwaySettingsUserID: fairwaySettingsUserID)
        fairwaySettingsCleanUserPostLikes(fairwaySettingsCurrentUser)

        guard TeeBoxUserStore.teeBoxDeleteUser(teeBoxUserID: fairwaySettingsUserID) else {
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Delete failed", style: .error)
            return
        }

        GolfPulseOverlayCenter.shared.golfPulseHideLoading()
        GolfPulseOverlayCenter.shared.golfPulseShowToast("Account deleted", style: .success)
        PlayerBadgeSessionStore.playerBadgeClearLoginUser()
    }

    private func fairwaySettingsDeleteUserOwnedPosts(fairwaySettingsUserID: String) {
        let fairwaySettingsOwnedPostIDs = BirdieClipVideoPostStore.birdieClipReadAllPosts()
            .filter { $0.birdieClipPublisherID == fairwaySettingsUserID }
            .map(\.birdieClipPostID)

        guard fairwaySettingsOwnedPostIDs.isEmpty == false else {
            return
        }

        let fairwaySettingsOwnedPostIDSet = Set(fairwaySettingsOwnedPostIDs)

        GreenNoteCommentStore.greenNoteReadAllComments()
            .filter { fairwaySettingsOwnedPostIDSet.contains($0.greenNoteVideoID) }
            .forEach { _ = GreenNoteCommentStore.greenNoteDeleteComment(greenNoteCommentID: $0.greenNoteCommentID) }

        TeeBoxUserStore.teeBoxReadAllUsers().forEach { fairwaySettingsUser in
            var fairwaySettingsUpdatedUser = fairwaySettingsUser
            let fairwaySettingsOriginalLikedPostIDs = fairwaySettingsUpdatedUser.teeBoxLikedPostIDs
            fairwaySettingsUpdatedUser.teeBoxLikedPostIDs.removeAll { fairwaySettingsOwnedPostIDSet.contains($0) }

            if fairwaySettingsOriginalLikedPostIDs != fairwaySettingsUpdatedUser.teeBoxLikedPostIDs {
                _ = TeeBoxUserStore.teeBoxUpdateUser(fairwaySettingsUpdatedUser)
            }
        }

        fairwaySettingsOwnedPostIDs.forEach {
            _ = BirdieClipVideoPostStore.birdieClipDeletePost(birdieClipPostID: $0)
        }
    }

    private func fairwaySettingsDeleteUserComments(fairwaySettingsUserID: String) {
        GreenNoteCommentStore.greenNoteReadAllComments()
            .filter { $0.greenNotePublisherID == fairwaySettingsUserID }
            .forEach { _ = GreenNoteCommentStore.greenNoteDeleteComment(greenNoteCommentID: $0.greenNoteCommentID) }
    }

    private func fairwaySettingsDeleteUserRatings(fairwaySettingsUserID: String) {
        ScoreCardVenueRatingStore.scoreCardReadAllRatings()
            .filter { $0.scoreCardUserID == fairwaySettingsUserID }
            .forEach { _ = ScoreCardVenueRatingStore.scoreCardDeleteRating(scoreCardRatingID: $0.scoreCardRatingID) }
    }

    private func fairwaySettingsDeleteUserChatRooms(fairwaySettingsUserID: String) {
        let fairwaySettingsRoomIDs = ClubPairChatRoomStore.clubPairReadRooms(clubPairUserID: fairwaySettingsUserID)
            .map(\.clubPairRoomID)

        guard fairwaySettingsRoomIDs.isEmpty == false else {
            return
        }

        let fairwaySettingsRoomIDSet = Set(fairwaySettingsRoomIDs)

        WhisperLineChatMessageStore.whisperLineReadAllMessages()
            .filter { fairwaySettingsRoomIDSet.contains($0.whisperLineRoomID) }
            .forEach { _ = WhisperLineChatMessageStore.whisperLineDeleteMessage(whisperLineMessageID: $0.whisperLineMessageID) }

        fairwaySettingsRoomIDs.forEach {
            _ = ClubPairChatRoomStore.clubPairDeleteRoom(clubPairRoomID: $0)
        }
    }

    private func fairwaySettingsCleanUserRelations(fairwaySettingsUserID: String) {
        TeeBoxUserStore.teeBoxReadAllUsers()
            .filter { $0.teeBoxUserID != fairwaySettingsUserID }
            .forEach { fairwaySettingsUser in
                var fairwaySettingsUpdatedUser = fairwaySettingsUser
                let fairwaySettingsOriginalUser = fairwaySettingsUpdatedUser

                fairwaySettingsUpdatedUser.teeBoxFollowerIDs.removeAll { $0 == fairwaySettingsUserID }
                fairwaySettingsUpdatedUser.teeBoxFollowingIDs.removeAll { $0 == fairwaySettingsUserID }
                fairwaySettingsUpdatedUser.teeBoxBlockedUserIDs.removeAll { $0 == fairwaySettingsUserID }

                if fairwaySettingsOriginalUser != fairwaySettingsUpdatedUser {
                    _ = TeeBoxUserStore.teeBoxUpdateUser(fairwaySettingsUpdatedUser)
                }
            }
    }

    private func fairwaySettingsCleanUserActivities(fairwaySettingsUserID: String) {
        MatchDayActivityStore.matchDayReadAllActivities().forEach { fairwaySettingsActivity in
            if fairwaySettingsActivity.matchDayPublisherID == fairwaySettingsUserID {
                _ = MatchDayActivityStore.matchDayDeleteActivity(matchDayActivityID: fairwaySettingsActivity.matchDayActivityID)
            } else if fairwaySettingsActivity.matchDayParticipantUserIDs.contains(fairwaySettingsUserID) {
                var fairwaySettingsUpdatedActivity = fairwaySettingsActivity
                fairwaySettingsUpdatedActivity.matchDayParticipantUserIDs.removeAll { $0 == fairwaySettingsUserID }
                _ = MatchDayActivityStore.matchDayUpdateActivity(fairwaySettingsUpdatedActivity)
            }
        }
    }

    private func fairwaySettingsCleanUserPostLikes(_ fairwaySettingsCurrentUser: TeeBoxUserModel) {
        fairwaySettingsCurrentUser.teeBoxLikedPostIDs.forEach { fairwaySettingsPostID in
            guard var fairwaySettingsPost = BirdieClipVideoPostStore.birdieClipReadPost(birdieClipPostID: fairwaySettingsPostID),
                  fairwaySettingsPost.birdieClipPublisherID != fairwaySettingsCurrentUser.teeBoxUserID else {
                return
            }

            fairwaySettingsPost.birdieClipLikeCount = max(0, fairwaySettingsPost.birdieClipLikeCount - 1)
            _ = BirdieClipVideoPostStore.birdieClipUpdatePost(fairwaySettingsPost)
        }
    }
}

private struct FairwaySettingsMenuRowView: View {
    let fairwaySettingsTitle: String
    let fairwaySettingsAction: () -> Void

    var body: some View {
        Button(action: fairwaySettingsAction) {
            HStack(spacing: 12) {
                Text(fairwaySettingsTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 29, height: 29)
                    .background(Color.white.opacity(0.22))
                    .clipShape(Circle())
            }
            .frame(height: 22)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FairwaySettingsHomeView {
    }
}
