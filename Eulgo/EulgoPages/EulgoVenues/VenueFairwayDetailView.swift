import SwiftUI

struct VenueFairwayDetailView: View {
    @State private var venueFairwaySelectedImageIndex = 0
    @State private var venueFairwayShowsScoreSheet = false
    @State private var venueFairwayShowsGuestRestriction = false
    @State private var venueFairwayRefreshToken = UUID()
    let venueFairwayVenueID: String?
    let venueFairwayBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: venueFairwayVenue.linksMapVenueName,
                    venueFairwayBackAction: venueFairwayBackAction,
                    venueFairwayTrailingAction: nil
                )
                    .padding(.top, 14)

                VenueFairwayImageCarouselView(
                    venueFairwayImageAddresses: venueFairwayImageAddresses,
                    venueFairwaySelectedImageIndex: $venueFairwaySelectedImageIndex
                )
                    .padding(.top, 12)

                VenueFairwayPageIndicatorView(
                    venueFairwayImageCount: venueFairwayImageAddresses.count,
                    venueFairwaySelectedImageIndex: venueFairwaySelectedImageIndex
                )
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center) {
                        Text(venueFairwayVenue.linksMapVenueName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Spacer()

                        VenueFairwayRatingPill(venueFairwayRating: venueFairwayFormattedRating)
                    }

                    Text(venueFairwayVenue.linksMapIntroductionText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(venueFairwayVenue.linksMapVenueSize) acres")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(FairwayStylePalette.fairwayPanelBackground)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                Spacer(minLength: 24)

                HStack(spacing: 10) {
                    Button(action: venueFairwayLikeAction) {
                        Group {
                            if venueFairwayIsLiked {
                                Image("EULGO_liked")
                                    .resizable()
                            } else {
                                Image("EULGO_like")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(.black)
                            }
                        }
                        .frame(width: 22, height: 22)
                        .frame(width: 80, height: 52)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button(action: venueFairwayScoreAction) {
                        Text("Score")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(FairwayStylePalette.fairwayScoreCream)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }

            if venueFairwayShowsScoreSheet {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            venueFairwayShowsScoreSheet = false
                        }
                    }

                VStack {
                    Spacer()

                    VenueFairwayScoreBottomSheet(
                        venueFairwayInitialFacilitiesScore: venueFairwaySubmittedRating?.scoreCardFacilitiesScore ?? 4,
                        venueFairwayInitialServiceScore: venueFairwaySubmittedRating?.scoreCardServiceScore ?? 4,
                        venueFairwayInitialOverallScore: venueFairwaySubmittedRating?.scoreCardOverallScore ?? 4,
                        venueFairwaySubmitAction: { venueFairwayFacilitiesScore, venueFairwayServiceScore, venueFairwayOverallScore in
                            venueFairwaySubmitScore(
                                venueFairwayFacilitiesScore: venueFairwayFacilitiesScore,
                                venueFairwayServiceScore: venueFairwayServiceScore,
                                venueFairwayOverallScore: venueFairwayOverallScore
                            )

                            withAnimation(.easeInOut(duration: 0.2)) {
                                venueFairwayShowsScoreSheet = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }

            if venueFairwayShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    venueFairwayShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: venueFairwayShowsScoreSheet)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: venueFairwayShowsGuestRestriction)
        .onChange(of: venueFairwayImageAddresses.count) { venueFairwayImageCount in
            if venueFairwaySelectedImageIndex >= venueFairwayImageCount {
                venueFairwaySelectedImageIndex = 0
            }
        }
        .greenPathSwipeBack(greenPathBackAction: venueFairwayBackAction)
    }

    private var venueFairwayVenue: LinksMapVenueModel {
        _ = venueFairwayRefreshToken

        if let venueFairwayVenueID,
           let venueFairwayFoundVenue = LinksMapVenueStore.linksMapReadVenue(linksMapVenueID: venueFairwayVenueID) {
            return venueFairwayFoundVenue
        }

        return LinksMapVenueStore.linksMapReadAllVenues().first ?? LinksMapVenueModel(
            linksMapVenueName: "Golf Course",
            linksMapIntroductionText: "Explore this golf course, check the atmosphere, and choose your next round.",
            linksMapVenueSize: 0,
            linksMapStarRating: 4.0
        )
    }

    private var venueFairwayImageAddresses: [String] {
        let venueFairwayAddresses = venueFairwayVenue.linksMapPhotoAddresses
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        return venueFairwayAddresses.isEmpty ? [""] : venueFairwayAddresses
    }

    private var venueFairwayFormattedRating: String {
        String(format: "%.1f", venueFairwayVenue.linksMapStarRating)
    }

    private var venueFairwayCurrentUser: TeeBoxUserModel? {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()
    }

    private var venueFairwayIsLiked: Bool {
        venueFairwayCurrentUser?.teeBoxLikedVenueIDs.contains(venueFairwayVenue.linksMapVenueID) == true
    }

    private var venueFairwaySubmittedRating: ScoreCardVenueRatingModel? {
        guard let venueFairwayCurrentUser else {
            return nil
        }

        return ScoreCardVenueRatingStore.scoreCardReadRating(
            scoreCardVenueID: venueFairwayVenue.linksMapVenueID,
            scoreCardUserID: venueFairwayCurrentUser.teeBoxUserID
        )
    }

    private func venueFairwayLikeAction() {
        guard var venueFairwayCurrentUser else {
            return
        }

        guard venueFairwayCurrentUser.teeBoxIsGuest == false else {
            venueFairwayShowsGuestRestriction = true
            return
        }

        let venueFairwayVenueID = venueFairwayVenue.linksMapVenueID
        if venueFairwayCurrentUser.teeBoxLikedVenueIDs.contains(venueFairwayVenueID) {
            venueFairwayCurrentUser.teeBoxLikedVenueIDs.removeAll { $0 == venueFairwayVenueID }
        } else {
            venueFairwayCurrentUser.teeBoxLikedVenueIDs.append(venueFairwayVenueID)
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(venueFairwayCurrentUser)
        venueFairwayRefreshToken = UUID()
    }

    private func venueFairwayScoreAction() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            venueFairwayShowsGuestRestriction = true
            return
        }

        venueFairwayShowsScoreSheet = true
    }

    private func venueFairwaySubmitScore(
        venueFairwayFacilitiesScore: Int,
        venueFairwayServiceScore: Int,
        venueFairwayOverallScore: Int
    ) {
        guard let venueFairwayCurrentUser else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard venueFairwayCurrentUser.teeBoxIsGuest == false else {
            venueFairwayShowsGuestRestriction = true
            return
        }

        let venueFairwayVenueID = venueFairwayVenue.linksMapVenueID
        if var venueFairwayExistingRating = ScoreCardVenueRatingStore.scoreCardReadRating(
            scoreCardVenueID: venueFairwayVenueID,
            scoreCardUserID: venueFairwayCurrentUser.teeBoxUserID
        ) {
            venueFairwayExistingRating.scoreCardFacilitiesScore = venueFairwayFacilitiesScore
            venueFairwayExistingRating.scoreCardServiceScore = venueFairwayServiceScore
            venueFairwayExistingRating.scoreCardOverallScore = venueFairwayOverallScore
            _ = ScoreCardVenueRatingStore.scoreCardUpdateRating(venueFairwayExistingRating)
        } else {
            _ = ScoreCardVenueRatingStore.scoreCardCreateRating(
                ScoreCardVenueRatingModel(
                    scoreCardVenueID: venueFairwayVenueID,
                    scoreCardUserID: venueFairwayCurrentUser.teeBoxUserID,
                    scoreCardFacilitiesScore: venueFairwayFacilitiesScore,
                    scoreCardServiceScore: venueFairwayServiceScore,
                    scoreCardOverallScore: venueFairwayOverallScore
                )
            )
        }

        GolfPulseOverlayCenter.shared.golfPulseShowToast("Score submitted", style: .success)
        venueFairwayRefreshToken = UUID()
    }
}

private struct VenueFairwayImageCarouselView: View {
    let venueFairwayImageAddresses: [String]
    @Binding var venueFairwaySelectedImageIndex: Int

    var body: some View {
        TabView(selection: $venueFairwaySelectedImageIndex) {
            ForEach(Array(venueFairwayImageAddresses.enumerated()), id: \.offset) { venueFairwayImageIndex, venueFairwayImageAddress in
                VenueFairwayImageCard(venueFairwayImageAddress: venueFairwayImageAddress)
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .tag(venueFairwayImageIndex)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 230)
    }
}

private struct VenueFairwayImageCard: View {
    let venueFairwayImageAddress: String

    var body: some View {
        if venueFairwayImageAddress.isEmpty {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.gray.opacity(0.42))

                Image(systemName: "flag.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white.opacity(0.34))
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            FairwayGalleryImageView(
                fairwayGalleryImageAddress: venueFairwayImageAddress,
                fairwayGalleryContentMode: .fill,
                fairwayGalleryPlaceholderColor: Color.gray.opacity(0.42),
                fairwayGalleryFailureIconName: "photo"
            )
            
        }
    }
}

private struct VenueFairwayPageIndicatorView: View {
    let venueFairwayImageCount: Int
    let venueFairwaySelectedImageIndex: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<venueFairwayImageCount, id: \.self) { venueFairwayImageIndex in
                if venueFairwayImageIndex == venueFairwaySelectedImageIndex {
                    Capsule()
                        .fill(Color(red: 0.45, green: 0.96, blue: 0.39))
                        .frame(width: 26, height: 7)
                } else {
                    Circle()
                        .fill(FairwayStylePalette.fairwayPlaceholderWhite)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: venueFairwaySelectedImageIndex)
    }
}

private struct VenueFairwayRatingPill: View {
    let venueFairwayRating: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(FairwayStylePalette.fairwayStarOrange)

            Text(venueFairwayRating)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(.white)
        .clipShape(Capsule())
    }
}

#Preview {
    VenueFairwayDetailView(venueFairwayVenueID: nil) {
    }
}
