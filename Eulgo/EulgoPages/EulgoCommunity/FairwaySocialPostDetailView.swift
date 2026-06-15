import AVKit
import SwiftUI
import UIKit

struct FairwaySocialPostDetailView: View {
    @State private var fairwaySocialShowsCommentSheet = false
    @State private var fairwaySocialRefreshToken = UUID()
    @State private var fairwaySocialPlayer: AVPlayer?
    @State private var fairwaySocialIsPlaying = false
    @State private var fairwaySocialIsVideoLoading = true
    @State private var fairwaySocialSelectedUserID: String?
    @State private var fairwaySocialShowsReportSheet = false
    @State private var fairwaySocialShowsGuestRestriction = false

    let fairwaySocialPostID: String
    let fairwaySocialBackAction: () -> Void

    var body: some View {
        ZStack {
            Group {
                if fairwaySocialIsVideoLoading {
                    FairwaySocialVideoLoadingView()
                } else {
                    FairwaySocialDetailHeroMediaView(
                        fairwaySocialPost: fairwaySocialResolvedPost,
                        fairwaySocialPlayer: fairwaySocialPlayer,
                        fairwaySocialIsPlaying: fairwaySocialIsPlaying
                    )
                }
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture(perform: fairwaySocialToggleVideoPlayback)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.03),
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.74)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 14,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: fairwaySocialBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        if fairwaySocialCanReportPostPublisher {
                            VenueFairwayHeaderView.venueFairwayReportButton(action: fairwaySocialReportAction)
                        } else {
                            EmptyView()
                        }
                    }
                )
                .padding(.top, 12)

                Spacer()

                if let fairwaySocialResolvedPost {
                    HStack {
                        Spacer()

                        FairwaySocialDetailActionRailView(
                            fairwaySocialPost: fairwaySocialResolvedPost,
                            fairwaySocialLikeAction: {
                                fairwaySocialTogglePostLike(fairwaySocialPostID: fairwaySocialResolvedPost.fairwaySocialPostID)
                            },
                            fairwaySocialCommentAction: fairwaySocialShowCommentSheet
                        )
                    }
                    .padding(.trailing, 15)
                    .padding(.bottom, 18)

                    FairwaySocialDetailCaptionView(
                        fairwaySocialPost: fairwaySocialResolvedPost,
                        fairwaySocialProfileAction: {
                            fairwaySocialPauseVideo()
                            fairwaySocialSelectedUserID = fairwaySocialResolvedPost.fairwaySocialPublisherID
                        }
                    )
                        .padding(.horizontal, 15)
                        .padding(.bottom, 28)
                } else {
                    FairwaySocialMissingPostView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                }
            }

            if fairwaySocialShowsCommentSheet {
                FairwayStylePalette.fairwaySheetMask
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            fairwaySocialShowsCommentSheet = false
                        }
                    }

                VStack {
                    Spacer()

                    FairwaySocialCommentBottomSheet(
                        fairwaySocialVideoPostID: fairwaySocialPostID,
                        fairwaySocialGuestRestrictionAction: {
                            fairwaySocialShowsGuestRestriction = true
                        }
                    )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .zIndex(2)
            }

            if let fairwaySocialSelectedUserID {
                FairwayProfileUserHomeView(fairwayProfileUserID: fairwaySocialSelectedUserID) {
                    self.fairwaySocialSelectedUserID = nil
                    fairwaySocialPlayer?.play()
                    fairwaySocialIsPlaying = true
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
        .animation(.easeInOut(duration: 0.2), value: fairwaySocialShowsCommentSheet)
        .animation(.easeInOut(duration: 0.24), value: fairwaySocialSelectedUserID)
        .animation(.easeInOut(duration: 0.18), value: fairwaySocialIsVideoLoading)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwaySocialShowsGuestRestriction)
        .caddieGuardReportSheet(
            caddieGuardIsPresented: $fairwaySocialShowsReportSheet,
            caddieGuardTargetUserID: fairwaySocialResolvedPost?.fairwaySocialPublisherID,
            caddieGuardBlockSuccessAction: fairwaySocialBackAction
        )
        .onAppear(perform: fairwaySocialLoadVideoWithDelay)
        .onDisappear(perform: fairwaySocialPauseVideo)
        .onChange(of: fairwaySocialPostID) { _ in
            fairwaySocialLoadVideoWithDelay()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { fairwaySocialNotification in
            fairwaySocialLoopVideoIfNeeded(fairwaySocialFinishedItem: fairwaySocialNotification.object as? AVPlayerItem)
        }
        .greenPathSwipeBack(greenPathBackAction: fairwaySocialBackAction)
    }

    private func fairwaySocialReportAction() {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwaySocialShowsGuestRestriction = true
            return
        }

        fairwaySocialPauseVideo()
        fairwaySocialShowsReportSheet = true
    }

    private var fairwaySocialCanReportPostPublisher: Bool {
        guard let fairwaySocialPublisherID = fairwaySocialResolvedPost?.fairwaySocialPublisherID,
              fairwaySocialPublisherID.isEmpty == false else {
            return false
        }

        return fairwaySocialPublisherID != PlayerBadgeSessionStore.playerBadgeCurrentUserID
    }

    private func fairwaySocialShowCommentSheet() {
        fairwaySocialShowsCommentSheet = true
    }

    private func fairwaySocialLoadVideoWithDelay() {
        fairwaySocialPauseVideo()
        fairwaySocialPlayer = nil
        fairwaySocialIsVideoLoading = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            fairwaySocialPrepareAndPlayVideo()
            fairwaySocialIsVideoLoading = false
        }
    }

    private func fairwaySocialPrepareAndPlayVideo() {
        guard let fairwaySocialVideoURL else {
            fairwaySocialPlayer = nil
            fairwaySocialIsPlaying = false
            return
        }

        if let fairwaySocialCurrentItemURL = (fairwaySocialPlayer?.currentItem?.asset as? AVURLAsset)?.url,
           fairwaySocialCurrentItemURL == fairwaySocialVideoURL {
            fairwaySocialPlayer?.play()
            fairwaySocialIsPlaying = true
            return
        }

        let fairwaySocialPreparedPlayer = AVPlayer(url: fairwaySocialVideoURL)
        fairwaySocialPlayer = fairwaySocialPreparedPlayer
        fairwaySocialPreparedPlayer.play()
        fairwaySocialIsPlaying = true
    }

    private func fairwaySocialToggleVideoPlayback() {
        guard let fairwaySocialPlayer else {
            return
        }

        if fairwaySocialIsPlaying {
            fairwaySocialPlayer.pause()
            fairwaySocialIsPlaying = false
        } else {
            fairwaySocialPlayer.play()
            fairwaySocialIsPlaying = true
        }
    }

    private func fairwaySocialPauseVideo() {
        fairwaySocialPlayer?.pause()
        fairwaySocialIsPlaying = false
    }

    private func fairwaySocialLoopVideoIfNeeded(fairwaySocialFinishedItem: AVPlayerItem?) {
        guard let fairwaySocialPlayer,
              fairwaySocialFinishedItem === fairwaySocialPlayer.currentItem else {
            return
        }

        fairwaySocialPlayer.seek(to: .zero)

        if fairwaySocialIsPlaying {
            fairwaySocialPlayer.play()
        }
    }

    private var fairwaySocialResolvedPost: FairwaySocialPost? {
        _ = fairwaySocialRefreshToken

        guard let fairwaySocialStoredPost = BirdieClipVideoPostStore.birdieClipReadPost(birdieClipPostID: fairwaySocialPostID) else {
            return nil
        }

        let fairwaySocialPublisher = TeeBoxUserStore.teeBoxReadUser(
            teeBoxUserID: fairwaySocialStoredPost.birdieClipPublisherID
        )
        let fairwaySocialCommentCount = GreenNoteCommentStore.greenNoteReadComments(
            greenNoteVideoID: fairwaySocialStoredPost.birdieClipPostID
        ).count
        let fairwaySocialLikedPostIDs = Set(PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxLikedPostIDs ?? [])

        return FairwaySocialPost(
            fairwaySocialPostID: fairwaySocialStoredPost.birdieClipPostID,
            fairwaySocialPublisherID: fairwaySocialStoredPost.birdieClipPublisherID,
            fairwaySocialName: fairwaySocialPublisher.map(fairwaySocialDisplayName(for:)) ?? "Eulgo Player",
            fairwaySocialAvatarAddress: fairwaySocialPublisher?.teeBoxAvatarAddress ?? "",
            fairwaySocialCoverAddress: fairwaySocialStoredPost.birdieClipCoverAddress,
            fairwaySocialVideoAddress: fairwaySocialStoredPost.birdieClipVideoAddress,
            fairwaySocialTime: "2 mins ago",
            fairwaySocialCaption: fairwaySocialStoredPost.birdieClipCaptionText,
            fairwaySocialLikes: "\(fairwaySocialStoredPost.birdieClipLikeCount) Like",
            fairwaySocialComments: "\(fairwaySocialCommentCount)",
            fairwaySocialStyle: .greenPlayer,
            fairwaySocialIsLiked: fairwaySocialLikedPostIDs.contains(fairwaySocialStoredPost.birdieClipPostID)
        )
    }

    private var fairwaySocialVideoURL: URL? {
        guard let fairwaySocialVideoAddress = fairwaySocialResolvedPost?.fairwaySocialVideoAddress else {
            return nil
        }

        let fairwaySocialTrimmedAddress = fairwaySocialVideoAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard fairwaySocialTrimmedAddress.isEmpty == false else {
            return nil
        }

        if let fairwaySocialURL = URL(string: fairwaySocialTrimmedAddress),
           let fairwaySocialScheme = fairwaySocialURL.scheme?.lowercased(),
           fairwaySocialScheme == "http" || fairwaySocialScheme == "https" || fairwaySocialScheme == "file" {
            return fairwaySocialURL
        }

        let fairwaySocialExpandedPath = fairwaySocialTrimmedAddress.replacingOccurrences(
            of: "~/",
            with: NSHomeDirectory() + "/"
        )

        if fairwaySocialExpandedPath.hasPrefix("/") {
            return URL(fileURLWithPath: fairwaySocialExpandedPath)
        }

        if let fairwaySocialDataAsset = NSDataAsset(name: fairwaySocialTrimmedAddress) {
            return fairwaySocialWriteVideoDataAsset(
                fairwaySocialDataAsset,
                fairwaySocialAssetName: fairwaySocialTrimmedAddress
            )
        }

        return Bundle.main.url(forResource: fairwaySocialTrimmedAddress, withExtension: nil)
            ?? Bundle.main.url(forResource: fairwaySocialTrimmedAddress, withExtension: "mp4")
    }

    private func fairwaySocialWriteVideoDataAsset(
        _ fairwaySocialDataAsset: NSDataAsset,
        fairwaySocialAssetName: String
    ) -> URL? {
        let fairwaySocialSafeName = fairwaySocialAssetName.replacingOccurrences(of: "/", with: "_")
        let fairwaySocialTemporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(fairwaySocialSafeName).mp4")

        if FileManager.default.fileExists(atPath: fairwaySocialTemporaryURL.path) {
            return fairwaySocialTemporaryURL
        }

        do {
            try fairwaySocialDataAsset.data.write(to: fairwaySocialTemporaryURL, options: [.atomic])
            return fairwaySocialTemporaryURL
        } catch {
            return nil
        }
    }

    private func fairwaySocialDisplayName(for fairwaySocialUser: TeeBoxUserModel) -> String {
        let fairwaySocialTrimmedName = fairwaySocialUser.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return fairwaySocialTrimmedName.isEmpty ? fairwaySocialUser.teeBoxEmail : fairwaySocialTrimmedName
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

private struct FairwaySocialDetailCaptionView: View {
    let fairwaySocialPost: FairwaySocialPost
    let fairwaySocialProfileAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button(action: fairwaySocialProfileAction) {
                    HStack(spacing: 8) {
                        FairwaySocialUserAvatarBadge(
                            fairwaySocialAvatarAddress: fairwaySocialPost.fairwaySocialAvatarAddress,
                            fairwaySocialStyle: fairwaySocialPost.fairwaySocialStyle == .greenPlayer ? .rose : .twilight,
                            fairwaySocialSize: 28,
                            fairwaySocialShowsRing: false
                        )

                        Text(fairwaySocialPost.fairwaySocialName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text(fairwaySocialPost.fairwaySocialCaption)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct FairwaySocialDetailActionRailView: View {
    let fairwaySocialPost: FairwaySocialPost
    let fairwaySocialLikeAction: () -> Void
    let fairwaySocialCommentAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Button(action: fairwaySocialLikeAction) {
                VStack(spacing: 4) {
                    if fairwaySocialPost.fairwaySocialIsLiked {
                        Image("EULGO_liked")
                            .resizable()
                            .frame(width: 30, height: 30)
                    } else {
                        Image("EULGO_like")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                    }

                    Text(fairwaySocialCompactLikes)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(fairwaySocialPost.fairwaySocialIsLiked ? FairwayStylePalette.fairwayLikePink : .black)
                }
            }
            .buttonStyle(.plain)

            Button(action: fairwaySocialCommentAction) {
                VStack(spacing: 4) {
                    Image("EULGO_comment")
                        .resizable()
                        .frame(width: 30, height: 30)

                    Text(fairwaySocialPost.fairwaySocialComments)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
        }.padding(15)
        .frame(width: 60)
        
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var fairwaySocialCompactLikes: String {
        fairwaySocialPost.fairwaySocialLikes.replacingOccurrences(of: " Like", with: "")
    }

}

private struct FairwaySocialDetailHeroMediaView: View {
    let fairwaySocialPost: FairwaySocialPost?
    let fairwaySocialPlayer: AVPlayer?
    let fairwaySocialIsPlaying: Bool

    var body: some View {
        GeometryReader { _ in
            ZStack {
                if let fairwaySocialPlayer {
                    VideoPlayer(player: fairwaySocialPlayer)
                        .background(Color.black)
                        .allowsHitTesting(false)

                    if fairwaySocialIsPlaying == false {
                        Image(systemName: "play.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 78, height: 78)
                            .background(Color.black.opacity(0.42))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.32), lineWidth: 1)
                            )
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                    }
                } else if let fairwaySocialPost {
                    FairwaySocialDetailFallbackMediaView(
                        fairwaySocialCoverAddress: fairwaySocialPost.fairwaySocialCoverAddress,
                        fairwaySocialStyle: fairwaySocialPost.fairwaySocialStyle
                    )
                } else {
                    FairwaySocialDetailFallbackMediaView(
                        fairwaySocialCoverAddress: "",
                        fairwaySocialStyle: .greenPlayer
                    )
                }
            }
            .animation(.easeInOut(duration: 0.18), value: fairwaySocialIsPlaying)
        }
    }
}

private struct FairwaySocialVideoLoadingView: View {
    var body: some View {
        ZStack {
            Color.black

            ProgressView()
                .tint(.white)
                .scaleEffect(1.15)
        }
    }
}

private struct FairwaySocialDetailFallbackMediaView: View {
    let fairwaySocialCoverAddress: String
    let fairwaySocialStyle: FairwaySocialPostStyle

    private var fairwaySocialCourseColors: [Color] {
        switch fairwaySocialStyle {
        case .greenPlayer:
            return [
                Color(red: 0.56, green: 0.74, blue: 0.38),
                Color(red: 0.18, green: 0.43, blue: 0.20),
                Color(red: 0.72, green: 0.86, blue: 0.48)
            ]
        case .clubhouseWall:
            return [
                Color(red: 0.74, green: 0.64, blue: 0.48),
                Color(red: 0.28, green: 0.39, blue: 0.23),
                Color(red: 0.50, green: 0.62, blue: 0.36)
            ]
        }
    }

    var body: some View {
        ZStack {
            if fairwaySocialCoverAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                LinearGradient(
                    colors: fairwaySocialCourseColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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

private struct FairwaySocialMissingPostView: View {
    var body: some View {
        Text("This post is unavailable.")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(FairwayStylePalette.fairwayCardBlack)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    FairwaySocialPostDetailView(fairwaySocialPostID: "preview-post") {
    }
}
