import SwiftUI

struct ClubHouseHomeView: View {
    @State private var clubHouseShowsVenueDetail = false
    @State private var clubHouseShowsDirectMessage = false
    @State private var clubHouseShowsCommunity = false
    @State private var clubHouseShowsProfile = false
    @State private var clubHouseShowsCreateActivity = false
    @State private var clubHouseShowsCoinPrompt = false
    @State private var clubHouseShowsRecharge = false
    @State private var clubHouseShowsGuestRestriction = false
    @State private var clubHouseSelectedVenueID: String?
    @State private var clubHouseSelectedActivityID: String?
    @State private var clubHouseRefreshToken = UUID()

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    ClubHouseHomeHeaderView(
                        clubHouseCurrentUser: clubHouseCurrentUser,
                        clubHouseProfileAction: {
                            clubHouseShowsProfile = true
                        },
                        clubHouseMessageAction: {
                            clubHouseOpenDirectMessageAction()
                        }
                    )
                        .padding(.top, 18)

                    ClubHouseEventJoinCard(
                        clubHouseCreateAction: {
                            clubHouseCreateActivityAction()
                        },
                        clubHouseEventOpenAction: { clubHouseActivityID in
                            if MatchDayActivityStore.matchDayReadActivity(matchDayActivityID: clubHouseActivityID) != nil {
                                clubHouseSelectedActivityID = clubHouseActivityID
                            }
                        }
                    )

                    ClubHouseCommunityCard {
                        clubHouseShowsCommunity = true
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Venues")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(clubHouseVenueCards) { clubHouseVenueCard in
                                    ClubHouseVenueCard(
                                        clubHouseVenueCard: clubHouseVenueCard,
                                        clubHouseVenueOpenAction: {
                                            clubHouseSelectedVenueID = clubHouseVenueCard.id
                                            clubHouseShowsVenueDetail = true
                                        },
                                        clubHouseVenueLikeAction: {
                                            clubHouseToggleVenueLike(clubHouseVenueID: clubHouseVenueCard.id)
                                        }
                                    )
                                }
                            }
                            .padding(.trailing, 16)
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 26)
            }

            if clubHouseShowsVenueDetail {
                VenueFairwayDetailView(venueFairwayVenueID: clubHouseSelectedVenueID) {
                    clubHouseShowsVenueDetail = false
                    clubHouseRefreshToken = UUID()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
            }

            if clubHouseShowsDirectMessage {
                ClubhouseDirectMessageView {
                    clubHouseShowsDirectMessage = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(2)
            }

            if clubHouseShowsCommunity {
                FairwaySocialCommunityView {
                    clubHouseShowsCommunity = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(3)
            }

            if clubHouseShowsProfile {
                FairwayProfileUserHomeView(fairwayProfileUserID: clubHouseCurrentUser?.teeBoxUserID) {
                    clubHouseShowsProfile = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(4)
            }

            if let clubHouseSelectedActivityID {
                EagleMatchActivityDetailView(eagleMatchActivityID: clubHouseSelectedActivityID) {
                    self.clubHouseSelectedActivityID = nil
                    clubHouseRefreshToken = UUID()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(5)
            }

            if clubHouseShowsCreateActivity {
                GreenTeeCreateActivityView {
                    clubHouseShowsCreateActivity = false
                    clubHouseRefreshToken = UUID()
                }
                .fairwayGreenDismissKeyboardOnTap()
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(6)
            }

            if clubHouseShowsRecharge {
                FairwayRechargeStoreView {
                    clubHouseShowsRecharge = false
                    clubHouseRefreshToken = UUID()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(7)
            }

            if clubHouseShowsCoinPrompt {
                CoinGateRechargePromptView(
                    coinGateOKAction: {
                        clubHouseShowsCoinPrompt = false
                    },
                    coinGateRechargeAction: {
                        clubHouseShowsCoinPrompt = false
                        clubHouseShowsRecharge = true
                    }
                )
                .transition(.opacity)
                .zIndex(8)
            }

            if clubHouseShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    clubHouseShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(9)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsVenueDetail)
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsDirectMessage)
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsCommunity)
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsProfile)
        .animation(.easeInOut(duration: 0.24), value: clubHouseSelectedActivityID)
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsCreateActivity)
        .animation(.easeInOut(duration: 0.24), value: clubHouseShowsRecharge)
        .animation(.easeInOut(duration: 0.2), value: clubHouseShowsCoinPrompt)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: clubHouseShowsGuestRestriction)
        .id(clubHouseRefreshToken)
    }

    private var clubHouseCurrentUser: TeeBoxUserModel? {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()
    }

    private var clubHouseVenueCards: [ClubHouseVenueCardModel] {
        let clubHouseLikedVenueIDs = Set(clubHouseCurrentUser?.teeBoxLikedVenueIDs ?? [])
        let clubHouseVenues = LinksMapVenueStore.linksMapReadAllVenues()

        guard clubHouseVenues.isEmpty == false else {
            return ClubHouseVenueCardModel.clubHousePlaceholderCards
        }

        return clubHouseVenues.map { clubHouseVenue in
            return ClubHouseVenueCardModel(
                clubHouseVenueID: clubHouseVenue.linksMapVenueID,
                clubHouseVenueTitle: clubHouseVenue.linksMapVenueName,
                clubHouseVenueSubtitle: "\(clubHouseVenue.linksMapVenueSize) acres",
                clubHouseVenueImageAddress: clubHouseVenue.linksMapPhotoAddresses.first ?? "",
                clubHouseVenueRating: String(format: "%.1f", clubHouseVenue.linksMapStarRating),
                clubHouseVenueIsLiked: clubHouseLikedVenueIDs.contains(clubHouseVenue.linksMapVenueID)
            )
        }
    }

    private func clubHouseToggleVenueLike(clubHouseVenueID: String) {
        guard var clubHouseCurrentUser else {
            return
        }

        guard clubHouseCurrentUser.teeBoxIsGuest == false else {
            clubHouseShowsGuestRestriction = true
            return
        }

        if clubHouseCurrentUser.teeBoxLikedVenueIDs.contains(clubHouseVenueID) {
            clubHouseCurrentUser.teeBoxLikedVenueIDs.removeAll { $0 == clubHouseVenueID }
        } else {
            clubHouseCurrentUser.teeBoxLikedVenueIDs.append(clubHouseVenueID)
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(clubHouseCurrentUser)
        clubHouseRefreshToken = UUID()
    }

    private func clubHouseCreateActivityAction() {
        guard var clubHouseCurrentUser else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard clubHouseCurrentUser.teeBoxIsGuest == false else {
            clubHouseShowsGuestRestriction = true
            return
        }

        guard clubHouseCurrentUser.teeBoxCoinCount >= 200 else {
            clubHouseShowsCoinPrompt = true
            return
        }

        clubHouseCurrentUser.teeBoxCoinCount -= 200
        _ = TeeBoxUserStore.teeBoxUpdateUser(clubHouseCurrentUser)
        clubHouseRefreshToken = UUID()
        clubHouseShowsCreateActivity = true
    }

    private func clubHouseOpenDirectMessageAction() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            clubHouseShowsGuestRestriction = true
            return
        }

        clubHouseShowsDirectMessage = true
    }
}

private struct ClubHouseVenueCardModel: Identifiable {
    let clubHouseVenueID: String
    let clubHouseVenueTitle: String
    let clubHouseVenueSubtitle: String
    let clubHouseVenueImageAddress: String
    let clubHouseVenueRating: String
    let clubHouseVenueIsLiked: Bool

    var id: String { clubHouseVenueID }

    static let clubHousePlaceholderCards = [
        ClubHouseVenueCardModel(
            clubHouseVenueID: "clubhouse-placeholder-venue-1",
            clubHouseVenueTitle: "Cypress Point Club",
            clubHouseVenueSubtitle: "50 acres",
            clubHouseVenueImageAddress: "",
            clubHouseVenueRating: "4.9",
            clubHouseVenueIsLiked: true
        ),
        ClubHouseVenueCardModel(
            clubHouseVenueID: "clubhouse-placeholder-venue-2",
            clubHouseVenueTitle: "Cypress Point Club",
            clubHouseVenueSubtitle: "30 acres",
            clubHouseVenueImageAddress: "",
            clubHouseVenueRating: "4.0",
            clubHouseVenueIsLiked: false
        )
    ]
}

private struct ClubHouseHomeHeaderView: View {
    let clubHouseCurrentUser: TeeBoxUserModel?
    let clubHouseProfileAction: () -> Void
    let clubHouseMessageAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Button(action: clubHouseProfileAction) {
                ClubHouseHeaderAvatarView(clubHouseAvatarAddress: clubHouseCurrentUser?.teeBoxAvatarAddress ?? "")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 0) {
                Text("H!~")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)

                Text(clubHouseDisplayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button(action: clubHouseMessageAction) {
                Image("EULGO_message_icon")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .frame(width: 52, height: 52)
                    .background(FairwayStylePalette.fairwayHeaderControlBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, 16)
    }

    private var clubHouseDisplayName: String {
        guard let clubHouseCurrentUser else {
            return "Eulgo Player"
        }

        let clubHouseTrimmedName = clubHouseCurrentUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return clubHouseTrimmedName.isEmpty ? clubHouseCurrentUser.teeBoxEmail : clubHouseTrimmedName
    }
}

private struct ClubHouseHeaderAvatarView: View {
    let clubHouseAvatarAddress: String

    var body: some View {
        Group {
            if clubHouseAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Image("EULGO_default_avatar")
                    .resizable()
                    .scaledToFill()
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: clubHouseAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: Color.white.opacity(0.18),
                    fairwayGalleryFailureIconName: "person.fill"
                )
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(Circle())
    }
}

private struct ClubHouseEventJoinCard: View {
    let clubHouseCreateAction: () -> Void
    let clubHouseEventOpenAction: (String) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("EULGO_dialog_bg")
                .resizable()

            HStack(alignment: .bottom, spacing: 13) {
                ClubHouseCreateEventButton(clubHouseCreateAction: clubHouseCreateAction)

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose and join a golf event")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Text("or create a new one")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.black.opacity(0.86))
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(clubHouseEventThumbnails) { clubHouseEventThumbnail in
                                ClubHouseEventThumbnail(
                                    clubHouseEventThumbnail: clubHouseEventThumbnail,
                                    clubHouseEventOpenAction: {
                                        clubHouseEventOpenAction(clubHouseEventThumbnail.clubHouseEventID)
                                    }
                                )
                            }
                        }
                        .padding(.trailing, 8)
                    }
                    .frame(height: 62)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)

            VStack{
                
                Spacer()
            }
            
        }
        .frame(height: 166)
        .padding(.trailing, 16)
        .background(
            LinearGradient(
                colors: [
                    FairwayStylePalette.fairwayLime,
                                    FairwayStylePalette.fairwayMint
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .offset(x: 6, y: 7)
            .padding(.trailing, 16)
        )
    }

    private var clubHouseEventThumbnails: [ClubHouseEventThumbnailModel] {
        let clubHouseActivities = MatchDayActivityStore.matchDayReadAllActivities()
            .sorted { $0.matchDayDate < $1.matchDayDate }
            .map {
                ClubHouseEventThumbnailModel(
                    clubHouseEventID: $0.matchDayActivityID,
                    clubHouseEventCoverAddress: $0.matchDayCoverAddress,
                    clubHouseEventFallbackSystemName: "flag.fill"
                )
            }

        if clubHouseActivities.isEmpty == false {
            return Array(clubHouseActivities)
        }

        return [
            ClubHouseEventThumbnailModel(clubHouseEventID: "clubhouse-event-placeholder-1", clubHouseEventCoverAddress: "", clubHouseEventFallbackSystemName: "person.fill"),
            ClubHouseEventThumbnailModel(clubHouseEventID: "clubhouse-event-placeholder-2", clubHouseEventCoverAddress: "", clubHouseEventFallbackSystemName: "person.2.fill"),
            ClubHouseEventThumbnailModel(clubHouseEventID: "clubhouse-event-placeholder-3", clubHouseEventCoverAddress: "", clubHouseEventFallbackSystemName: "flag.fill")
        ]
    }
}

private struct ClubHouseCreateEventButton: View {
    let clubHouseCreateAction: () -> Void

    var body: some View {
        Button(action: clubHouseCreateAction) {
            VStack(spacing: 7) {
                ZStack(alignment: .bottom) {
                    Image("EULGO_golf_event_logo")
                        .resizable()
                        .frame(width: 68, height: 86)
                        .offset(y: -8)
                    HStack(spacing: 4){
                        Image("EULGO_coin")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("-200")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.black)
                    }.padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.98, green: 0.87, blue: 0.15))
                        .clipShape(Capsule())
                        .offset(y: 5)
                    
                }

                VStack{
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 20)
                        .background(Color(red: 0.39, green: 0.94, blue: 0.39))
                        .clipShape(Circle())

                    Text("Create")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.black)
                }.frame(
                    width: 60, height: 60
                ).background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            Color(red: 239/255, green: 239/255, blue: 239/255)
                        )
                )
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
    }
}

private struct ClubHouseEventThumbnailModel: Identifiable {
    let clubHouseEventID: String
    let clubHouseEventCoverAddress: String
    let clubHouseEventFallbackSystemName: String

    var id: String { clubHouseEventID }
}

private struct ClubHouseEventThumbnail: View {
    let clubHouseEventThumbnail: ClubHouseEventThumbnailModel
    let clubHouseEventOpenAction: () -> Void

    var body: some View {
        Button(action: clubHouseEventOpenAction) {
            ZStack {
                if clubHouseEventThumbnail.clubHouseEventCoverAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Color.gray.opacity(0.46)

                    Image(systemName: clubHouseEventThumbnail.clubHouseEventFallbackSystemName)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.white.opacity(0.86))
                } else {
                    FairwayGalleryImageView(
                        fairwayGalleryImageAddress: clubHouseEventThumbnail.clubHouseEventCoverAddress,
                        fairwayGalleryContentMode: .fill,
                        fairwayGalleryPlaceholderColor: Color.gray.opacity(0.46),
                        fairwayGalleryFailureIconName: clubHouseEventThumbnail.clubHouseEventFallbackSystemName
                    )
                }
            }
            .frame(width: 62, height: 62)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ClubHouseCommunityCard: View {
    let clubHouseCommunityAction: () -> Void

    var body: some View {
        Button(action: clubHouseCommunityAction) {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [
                        Color(red: 0.44, green: 0.96, blue: 0.34),
                        Color(red: 1.00, green: 0.98, blue: 0.72)
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(height: 160)

                Image("EULGO_golf_person")
                    .resizable()
                    .frame(width: 127, height: 185)
                    .offset(x: 16)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Do you want to learn\nmore about golf?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .lineSpacing(1)

                    Text("Go to the community and take a look!")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.black.opacity(0.76))
                        .padding(.top, 5)
                        .padding(.bottom, 26)

                    HStack(spacing: 9) {
                        HStack(spacing: -9) {
                            ForEach(Array(clubHouseCommunityMembers.prefix(4).enumerated()), id: \.element.teeBoxUserID) { clubHouseAvatarIndex, clubHouseUser in
                                ClubHouseMiniAvatar(
                                    clubHouseAvatarAddress: clubHouseUser.teeBoxAvatarAddress,
                                    clubHouseAvatarIndex: clubHouseAvatarIndex
                                )
                            }
                        }

                        Text("\(clubHouseCommunityMemberCount) Join")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                        
                        Text("Go")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 34)
                            .background(FairwayStylePalette.fairwayCardBlack)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 116)
                .padding(.bottom, 20)
            }
        }
        .buttonStyle(.plain)
        .padding(.trailing, 16)
    }

    private var clubHouseCommunityMemberCount: Int {
        clubHouseCommunityMembers.count
    }

    private var clubHouseCommunityMembers: [TeeBoxUserModel] {
        let clubHouseBlockedUserIDs = Set(PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxBlockedUserIDs ?? [])

        return TeeBoxUserStore.teeBoxReadAllUsers()
            .filter { clubHouseUser in
                clubHouseUser.teeBoxIsGuest == false
                && clubHouseBlockedUserIDs.contains(clubHouseUser.teeBoxUserID) == false
            }
            .sorted {
                $0.teeBoxUsername.localizedCaseInsensitiveCompare($1.teeBoxUsername) == .orderedAscending
            }
    }
}

private struct ClubHouseMiniAvatar: View {
    let clubHouseAvatarAddress: String
    let clubHouseAvatarIndex: Int

    var body: some View {
        Group {
            if clubHouseAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: Double(clubHouseAvatarIndex) * 0.12 + 0.12, saturation: 0.55, brightness: 0.95),
                                    Color(hue: Double(clubHouseAvatarIndex) * 0.12 + 0.48, saturation: 0.50, brightness: 0.72)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image("EULGO_default_avatar")
                        .resizable()
                        .scaledToFill()
                        .padding(2)
                }
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: clubHouseAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: Color.white.opacity(0.24),
                    fairwayGalleryFailureIconName: "person.fill"
                )
            }
        }
        .frame(width: 30, height: 30)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white, lineWidth: 2))
        .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

private struct ClubHouseVenueCard: View {
    let clubHouseVenueCard: ClubHouseVenueCardModel
    let clubHouseVenueOpenAction: () -> Void
    let clubHouseVenueLikeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                if clubHouseVenueCard.clubHouseVenueImageAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.gray.opacity(0.42))
                        .frame(width: 200, height: 160)
                } else {
                    FairwayGalleryImageView(
                        fairwayGalleryImageAddress: clubHouseVenueCard.clubHouseVenueImageAddress,
                        fairwayGalleryContentMode: .fill,
                        fairwayGalleryPlaceholderColor: Color.gray.opacity(0.42),
                        fairwayGalleryFailureIconName: "photo"
                    )
                    .frame(width: 200, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                
                HStack{
                    

                    Button(action: clubHouseVenueLikeAction) {
                        Image(clubHouseVenueCard.clubHouseVenueIsLiked ? "EULGO_liked" : "EULGO_like")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .frame(width: 34, height: 34)
                            .background(FairwayStylePalette.fairwaySegmentBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }.padding(8)

                

                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(FairwayStylePalette.fairwayStarOrange)

                    Text(clubHouseVenueCard.clubHouseVenueRating)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(10)
            }

            Text(clubHouseVenueCard.clubHouseVenueTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .padding(.leading, 8)

            Text(clubHouseVenueCard.clubHouseVenueSubtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(FairwayStylePalette.fairwayPanelBackground)
                .clipShape(Capsule())
                .padding(.leading, 8)
        }
        .frame(width: 200, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            clubHouseVenueOpenAction()
        }
    }
}

#Preview {
    ClubHouseHomeView()
}
