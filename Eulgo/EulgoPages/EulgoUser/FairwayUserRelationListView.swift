import SwiftUI

enum FairwayUserRelationMode {
    case following
    case followers
    case blacklist

    var fairwayRelationTitle: String {
        switch self {
        case .following:
            return "Following"
        case .followers:
            return "Followers"
        case .blacklist:
            return "Blacklist"
        }
    }
}

struct FairwayUserRelationListView: View {
    @State private var fairwayRelationRefreshToken = UUID()
    @State private var fairwayRelationShowsGuestRestriction = false
    let fairwayRelationMode: FairwayUserRelationMode
    let fairwayRelationBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: fairwayRelationMode.fairwayRelationTitle,
                    venueFairwayBackAction: fairwayRelationBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 14
                )
                .padding(.top, 14)

                if fairwayRelationUsers.isEmpty {
                    Spacer()

                    Text(fairwayRelationEmptyText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.62))

                    Spacer()
                } else {
                    LazyVStack(spacing: 24) {
                        ForEach(fairwayRelationUsers) { fairwayRelationUser in
                            FairwayRelationUserRowView(
                                fairwayRelationMode: fairwayRelationMode,
                                fairwayRelationUser: fairwayRelationUser,
                                fairwayRelationIsFollowing: fairwayRelationIsFollowing(fairwayRelationUser.fairwayRelationUserID),
                                fairwayRelationAction: {
                                    fairwayRelationHandleAction(fairwayRelationUserID: fairwayRelationUser.fairwayRelationUserID)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 34)

                    Spacer()
                }
            }

            if fairwayRelationShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    fairwayRelationShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .id(fairwayRelationRefreshToken)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwayRelationShowsGuestRestriction)
        .greenPathSwipeBack(greenPathBackAction: fairwayRelationBackAction)
    }

    private var fairwayRelationCurrentUser: TeeBoxUserModel? {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()
    }

    private var fairwayRelationUsers: [FairwayRelationUserModel] {
        guard let fairwayRelationCurrentUser else {
            return []
        }

        let fairwayRelationIDs: [String]
        switch fairwayRelationMode {
        case .following:
            fairwayRelationIDs = fairwayRelationCurrentUser.teeBoxFollowingIDs
        case .followers:
            fairwayRelationIDs = fairwayRelationCurrentUser.teeBoxFollowerIDs
        case .blacklist:
            fairwayRelationIDs = fairwayRelationCurrentUser.teeBoxBlockedUserIDs
        }

        return fairwayRelationIDs.compactMap { fairwayRelationUserID in
            guard let fairwayRelationUser = TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: fairwayRelationUserID) else {
                return nil
            }

            return FairwayRelationUserModel(fairwayRelationUser: fairwayRelationUser)
        }
    }

    private var fairwayRelationEmptyText: String {
        switch fairwayRelationMode {
        case .following:
            return "No following yet"
        case .followers:
            return "No followers yet"
        case .blacklist:
            return "No blocked users"
        }
    }

    private func fairwayRelationIsFollowing(_ fairwayRelationUserID: String) -> Bool {
        fairwayRelationCurrentUser?.teeBoxFollowingIDs.contains(fairwayRelationUserID) == true
    }

    private func fairwayRelationHandleAction(fairwayRelationUserID: String) {
        guard fairwayRelationCurrentUser?.teeBoxIsGuest == false else {
            fairwayRelationShowsGuestRestriction = true
            return
        }

        switch fairwayRelationMode {
        case .following:
            fairwayRelationUnfollow(fairwayRelationUserID: fairwayRelationUserID)
        case .followers:
            fairwayRelationFollow(fairwayRelationUserID: fairwayRelationUserID)
        case .blacklist:
            fairwayRelationRevokeBlock(fairwayRelationUserID: fairwayRelationUserID)
        }
    }

    private func fairwayRelationFollow(fairwayRelationUserID: String) {
        guard var fairwayRelationCurrentUser,
              var fairwayRelationTargetUser = TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: fairwayRelationUserID),
              fairwayRelationCurrentUser.teeBoxUserID != fairwayRelationUserID else {
            return
        }

        if fairwayRelationCurrentUser.teeBoxFollowingIDs.contains(fairwayRelationUserID) == false {
            fairwayRelationCurrentUser.teeBoxFollowingIDs.append(fairwayRelationUserID)
        }

        if fairwayRelationTargetUser.teeBoxFollowerIDs.contains(fairwayRelationCurrentUser.teeBoxUserID) == false {
            fairwayRelationTargetUser.teeBoxFollowerIDs.append(fairwayRelationCurrentUser.teeBoxUserID)
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRelationCurrentUser)
        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRelationTargetUser)
        fairwayRelationRefreshToken = UUID()
    }

    private func fairwayRelationUnfollow(fairwayRelationUserID: String) {
        guard var fairwayRelationCurrentUser,
              var fairwayRelationTargetUser = TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: fairwayRelationUserID) else {
            return
        }

        fairwayRelationCurrentUser.teeBoxFollowingIDs.removeAll { $0 == fairwayRelationUserID }
        fairwayRelationTargetUser.teeBoxFollowerIDs.removeAll { $0 == fairwayRelationCurrentUser.teeBoxUserID }

        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRelationCurrentUser)
        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRelationTargetUser)
        fairwayRelationRefreshToken = UUID()
    }

    private func fairwayRelationRevokeBlock(fairwayRelationUserID: String) {
        guard var fairwayRelationCurrentUser else {
            return
        }

        fairwayRelationCurrentUser.teeBoxBlockedUserIDs.removeAll { $0 == fairwayRelationUserID }
        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRelationCurrentUser)
        fairwayRelationRefreshToken = UUID()
    }
}

private struct FairwayRelationUserModel: Identifiable {
    let fairwayRelationUserID: String
    let fairwayRelationName: String
    let fairwayRelationAvatarAddress: String

    var id: String { fairwayRelationUserID }

    init(fairwayRelationUser: TeeBoxUserModel) {
        fairwayRelationUserID = fairwayRelationUser.teeBoxUserID
        fairwayRelationAvatarAddress = fairwayRelationUser.teeBoxAvatarAddress

        let fairwayRelationTrimmedName = fairwayRelationUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        fairwayRelationName = fairwayRelationTrimmedName.isEmpty ? fairwayRelationUser.teeBoxEmail : fairwayRelationTrimmedName
    }
}

private struct FairwayRelationUserRowView: View {
    let fairwayRelationMode: FairwayUserRelationMode
    let fairwayRelationUser: FairwayRelationUserModel
    let fairwayRelationIsFollowing: Bool
    let fairwayRelationAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            FairwayRelationAvatarView(fairwayRelationAvatarAddress: fairwayRelationUser.fairwayRelationAvatarAddress)

            Text(fairwayRelationUser.fairwayRelationName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button(action: fairwayRelationAction) {
                Text(fairwayRelationButtonTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(fairwayRelationMode == .following || fairwayRelationIsFollowing ? .white : .black)
                    .padding(.horizontal, 12)
                    .frame(height: 26)
                    .background(fairwayRelationButtonBackground)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var fairwayRelationButtonTitle: String {
        switch fairwayRelationMode {
        case .following:
            return "Followed"
        case .followers:
            return fairwayRelationIsFollowing ? "Followed" : "+ Follow"
        case .blacklist:
            return "Revocate"
        }
    }

    private var fairwayRelationButtonBackground: Color {
        switch fairwayRelationMode {
        case .following:
            return Color(red: 0.66, green: 0.74, blue: 0.78)
        case .followers:
            return fairwayRelationIsFollowing ? Color(red: 0.66, green: 0.74, blue: 0.78) : Color(red: 0.42, green: 0.96, blue: 0.42)
        case .blacklist:
            return Color(red: 1.0, green: 0.68, blue: 0.06)
        }
    }
}

private struct FairwayRelationAvatarView: View {
    let fairwayRelationAvatarAddress: String

    var body: some View {
        ZStack {
            if fairwayRelationAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.74, green: 0.86, blue: 0.88),
                                Color(red: 0.16, green: 0.42, blue: 0.48)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.86))
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: fairwayRelationAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground,
                    fairwayGalleryFailureIconName: "person.fill"
                )
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    FairwayUserRelationListView(fairwayRelationMode: .following) {
    }
}
