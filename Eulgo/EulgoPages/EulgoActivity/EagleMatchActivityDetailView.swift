import SwiftUI

struct EagleMatchActivityDetailView: View {
    @State private var eagleMatchRefreshToken = UUID()
    @State private var eagleMatchShowsReportSheet = false
    @State private var eagleMatchShowsGuestRestriction = false
    let eagleMatchActivityID: String?
    let eagleMatchBackAction: () -> Void
    let eagleMatchReportAction: () -> Void

    init(
        eagleMatchActivityID: String? = nil,
        eagleMatchBackAction: @escaping () -> Void,
        eagleMatchReportAction: @escaping () -> Void = {}
    ) {
        self.eagleMatchActivityID = eagleMatchActivityID
        self.eagleMatchBackAction = eagleMatchBackAction
        self.eagleMatchReportAction = eagleMatchReportAction
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 14,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: eagleMatchBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        if eagleMatchCanReportPublisher {
                            VenueFairwayHeaderView.venueFairwayReportButton(action: eagleMatchShowReportSheet)
                        } else {
                            EmptyView()
                        }
                    }
                )
                .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        EagleMatchCoverView(eagleMatchCoverAddress: eagleMatchActivity.matchDayCoverAddress)
                            .frame(height: 307)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                            .padding(.top, 14)

                        Text(eagleMatchActivity.matchDayActivityName)
                            .font(.system(size: 23, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 28)

                        EagleMatchInfoCardView(
                            eagleMatchActivity: eagleMatchActivity,
                            eagleMatchParticipantUsers: eagleMatchParticipantUsers
                        )
                            .padding(.top, 14)

                        Text("Introduction")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 16)

                        Text(eagleMatchActivity.matchDayIntroductionText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.white.opacity(0.72))
                            .lineSpacing(4)
                            .padding(.top, 10)
                            .padding(.bottom, 96)
                    }
                    .padding(.horizontal, 16)
                }
            }

            EagleMatchJoinBarView(eagleMatchJoinAction: eagleMatchJoinAction)
                .padding(.horizontal, 16)
                .padding(.bottom, 22)

            if eagleMatchShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    eagleMatchShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(3)
            }
        }
        .id(eagleMatchRefreshToken)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: eagleMatchShowsGuestRestriction)
        .greenPathSwipeBack(greenPathBackAction: eagleMatchBackAction)
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $eagleMatchShowsReportSheet,
            caddieGuardTargetUserID: eagleMatchActivity.matchDayPublisherID,
            caddieGuardBlockSuccessAction: eagleMatchBackAction
        )
    }

    private func eagleMatchShowReportSheet() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            eagleMatchShowsGuestRestriction = true
            return
        }

        eagleMatchReportAction()
        eagleMatchShowsReportSheet = true
    }

    private var eagleMatchCanReportPublisher: Bool {
        guard let eagleMatchCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID else {
            return eagleMatchActivity.matchDayPublisherID.isEmpty == false
        }

        return eagleMatchActivity.matchDayPublisherID.isEmpty == false
            && eagleMatchActivity.matchDayPublisherID != eagleMatchCurrentUserID
    }

    private func eagleMatchJoinAction() {
        guard let eagleMatchCurrentUserID = PlayerBadgeSessionStore.playerBadgeCurrentUserID,
              var eagleMatchStoredActivity = MatchDayActivityStore.matchDayReadActivity(matchDayActivityID: eagleMatchActivity.matchDayActivityID) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            eagleMatchShowsGuestRestriction = true
            return
        }

        guard eagleMatchStoredActivity.matchDayParticipantUserIDs.contains(eagleMatchCurrentUserID) == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Already joined", style: .normal)
            return
        }

        eagleMatchStoredActivity.matchDayParticipantUserIDs.append(eagleMatchCurrentUserID)
        if MatchDayActivityStore.matchDayUpdateActivity(eagleMatchStoredActivity) {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Joined", style: .success)
            eagleMatchRefreshToken = UUID()
        }
    }

    private var eagleMatchActivity: MatchDayActivityModel {
        if let eagleMatchActivityID,
           let eagleMatchActivity = MatchDayActivityStore.matchDayReadActivity(matchDayActivityID: eagleMatchActivityID) {
            return eagleMatchActivity
        }

        return MatchDayActivityStore.matchDayReadAllActivities()
            .sorted { $0.matchDayDate < $1.matchDayDate }
            .first ?? MatchDayActivityModel(
                matchDayPublisherID: "",
                matchDayActivityName: "Golf Event",
                matchDayCoverAddress: "",
                matchDayIntroductionText: "Join a friendly golf event and meet players around the fairway.",
                matchDayDate: Date(),
                matchDayDurationText: "15:00 - 18:00",
                matchDayLocation: "Golf Course"
            )
    }

    private var eagleMatchParticipantUsers: [TeeBoxUserModel] {
        eagleMatchActivity.matchDayParticipantUserIDs
            .compactMap { TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: $0) }
    }
}

private struct EagleMatchCoverView: View {
    let eagleMatchCoverAddress: String

    var body: some View {
        ZStack {
            FairwayGalleryImageView(
                fairwayGalleryImageAddress: eagleMatchCoverAddress,
                fairwayGalleryContentMode: .fill,
                fairwayGalleryPlaceholderColor: FairwayStylePalette.fairwayPanelBackground
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()

                HStack(spacing: -8) {
                    ForEach(0..<5) { eagleMatchIndex in
                        EagleMatchTinyAvatarView(eagleMatchIndex: eagleMatchIndex)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .opacity(0.0)
            }
        }
    }
}

private struct EagleMatchInfoCardView: View {
    let eagleMatchActivity: MatchDayActivityModel
    let eagleMatchParticipantUsers: [TeeBoxUserModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 0) {
                EagleMatchInfoPairView(
                    eagleMatchIconName: "calendar",
                    eagleMatchText: Self.eagleMatchDateFormatter.string(from: eagleMatchActivity.matchDayDate)
                )

                Spacer(minLength: 12)

                EagleMatchInfoPairView(
                    eagleMatchIconName: "clock.fill",
                    eagleMatchText: eagleMatchActivity.matchDayDurationText
                )
            }

            EagleMatchInfoPairView(
                eagleMatchIconName: "mappin.circle.fill",
                eagleMatchText: eagleMatchActivity.matchDayLocation
            )

            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 20)

                HStack(spacing: -8) {
                    ForEach(Array(eagleMatchParticipantUsers.prefix(5).enumerated()), id: \.element.teeBoxUserID) { eagleMatchIndex, eagleMatchUser in
                        EagleMatchTinyAvatarView(
                            eagleMatchIndex: eagleMatchIndex,
                            eagleMatchAvatarAddress: eagleMatchUser.teeBoxAvatarAddress
                        )
                    }
                }

                Text("+\(eagleMatchActivity.matchDayParticipantUserIDs.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(FairwayStylePalette.fairwayCreamGradient())
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private static let eagleMatchDateFormatter: DateFormatter = {
        let eagleMatchFormatter = DateFormatter()
        eagleMatchFormatter.locale = Locale(identifier: "en_US_POSIX")
        eagleMatchFormatter.dateFormat = "EEE, d MMM yyyy"
        return eagleMatchFormatter
    }()
}

private struct EagleMatchInfoPairView: View {
    let eagleMatchIconName: String
    let eagleMatchText: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: eagleMatchIconName)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 18)

            Text(eagleMatchText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
    }
}

private struct EagleMatchTinyAvatarView: View {
    let eagleMatchIndex: Int
    var eagleMatchAvatarAddress: String = ""

    var body: some View {
        ZStack {
            if eagleMatchAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Circle()
                    .fill(eagleMatchAvatarGradient)

                Image(systemName: eagleMatchSystemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            } else {
                FairwayGalleryImageView(
                    fairwayGalleryImageAddress: eagleMatchAvatarAddress,
                    fairwayGalleryContentMode: .fill,
                    fairwayGalleryPlaceholderColor: Color.white.opacity(0.22),
                    fairwayGalleryFailureIconName: eagleMatchSystemImage
                )
            }
        }
        .frame(width: 31, height: 31)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 1.2)
        )
    }

    private var eagleMatchAvatarGradient: LinearGradient {
        let eagleMatchColors: [[Color]] = [
            [Color(red: 0.36, green: 0.58, blue: 0.86), Color(red: 0.78, green: 0.90, blue: 0.98)],
            [Color(red: 0.12, green: 0.42, blue: 0.28), Color(red: 0.72, green: 0.92, blue: 0.42)],
            [Color(red: 0.95, green: 0.52, blue: 0.64), Color(red: 1.0, green: 0.82, blue: 0.52)],
            [Color(red: 0.20, green: 0.70, blue: 0.76), Color(red: 0.76, green: 0.94, blue: 0.72)],
            [Color(red: 0.45, green: 0.36, blue: 0.82), Color(red: 0.82, green: 0.76, blue: 0.96)]
        ]
        let eagleMatchSelectedColors = eagleMatchColors[eagleMatchIndex % eagleMatchColors.count]

        return LinearGradient(
            colors: eagleMatchSelectedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var eagleMatchSystemImage: String {
        ["figure.golf", "person.fill", "flag.fill", "trophy.fill", "figure.walk"][eagleMatchIndex % 5]
    }
}

private struct EagleMatchJoinBarView: View {
    @State private var eagleMatchDragOffset: CGFloat = 0
    @State private var eagleMatchIsCompleting = false

    let eagleMatchJoinAction: () -> Void

    var body: some View {
        GeometryReader { eagleMatchProxy in
            let eagleMatchHandleSize: CGFloat = 61
            let eagleMatchTrackWidth = eagleMatchProxy.size.width
            let eagleMatchMaxOffset = max(0, eagleMatchTrackWidth - eagleMatchHandleSize)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(FairwayStylePalette.fairwayScoreCream)

                HStack(spacing: 8) {
                    Spacer(minLength: eagleMatchHandleSize + 10)

                    Text(eagleMatchIsCompleting ? "Joined" : "Slide to Join")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black.opacity(eagleMatchIsCompleting ? 0.48 : 0.94))
                        .lineLimit(1)

                    Spacer(minLength: 14)
                }
                .allowsHitTesting(false)

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(FairwayStylePalette.fairwayBrandGradient())
                    .frame(width: eagleMatchHandleSize + eagleMatchDragOffset, height: 47)
                    .opacity(0.92)
                    .allowsHitTesting(false)

                EagleMatchSlideHandleView()
                    .offset(x: eagleMatchDragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { eagleMatchValue in
                                guard eagleMatchIsCompleting == false else {
                                    return
                                }

                                eagleMatchDragOffset = min(
                                    max(0, eagleMatchValue.translation.width),
                                    eagleMatchMaxOffset
                                )
                            }
                            .onEnded { _ in
                                guard eagleMatchIsCompleting == false else {
                                    return
                                }

                                if eagleMatchDragOffset >= eagleMatchMaxOffset * 0.78 {
                                    eagleMatchCompleteSlide(eagleMatchMaxOffset: eagleMatchMaxOffset)
                                } else {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                        eagleMatchDragOffset = 0
                                    }
                                }
                            }
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .frame(height: 47)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 8)
    }

    private func eagleMatchCompleteSlide(eagleMatchMaxOffset: CGFloat) {
        withAnimation(.easeOut(duration: 0.16)) {
            eagleMatchDragOffset = eagleMatchMaxOffset
            eagleMatchIsCompleting = true
        }

        eagleMatchJoinAction()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                eagleMatchDragOffset = 0
                eagleMatchIsCompleting = false
            }
        }
    }
}

private struct EagleMatchSlideHandleView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FairwayStylePalette.fairwayBrandGradient())

            Image(systemName: "chevron.right.2")
                .font(.system(size: 23, weight: .heavy))
                .foregroundStyle(.white)
        }
        .frame(width: 61, height: 47)
    }
}

#Preview {
    EagleMatchActivityDetailView {
    }
}
