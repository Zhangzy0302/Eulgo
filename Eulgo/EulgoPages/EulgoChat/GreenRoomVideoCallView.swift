import SwiftUI

struct GreenRoomVideoCallView: View {
    @State private var clubhouseVideoIsAnimating = false

    let clubhouseVideoRoomID: String
    let clubhouseVideoHangUpAction: () -> Void

    var body: some View {
        ZStack {
            GeometryReader { clubhouseVideoProxy in
                GreenRoomVideoBackgroundView(clubhouseVideoAvatarAddress: clubhouseVideoOpponent?.teeBoxAvatarAddress ?? "")
                    .frame(width: clubhouseVideoProxy.size.width, height: clubhouseVideoProxy.size.height)
                    .scaleEffect(clubhouseVideoIsAnimating ? 1.04 : 1.0)
                    .ignoresSafeArea()
            }
            

            Color.black.opacity(clubhouseVideoIsAnimating ? 0.38 : 0.32)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: clubhouseVideoIsAnimating)

            LinearGradient(
                colors: [
                    .black.opacity(0.18),
                    .clear,
                    .black.opacity(0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 102)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.26), lineWidth: 1)
                        .frame(width: 104, height: 104)
                        .scaleEffect(clubhouseVideoIsAnimating ? 1.12 : 0.92)
                        .opacity(clubhouseVideoIsAnimating ? 0.18 : 0.48)

                    ClubhouseDirectRoomAvatarView(
                        clubhouseDirectAvatarAddress: clubhouseVideoOpponent?.teeBoxAvatarAddress ?? "",
                        clubhouseDirectAvatarSymbol: "person.fill",
                        clubhouseDirectAvatarSize: 86,
                        clubhouseDirectAvatarColors: [
                            Color(red: 0.94, green: 0.68, blue: 0.64),
                            Color(red: 0.38, green: 0.49, blue: 0.39)
                        ]
                    )
                    .scaleEffect(clubhouseVideoIsAnimating ? 1.035 : 0.985)
                    .shadow(color: .black.opacity(0.24), radius: 16, y: 8)
                }
                .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: clubhouseVideoIsAnimating)

                Text(clubhouseVideoName)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                HStack(spacing: 6) {
                    Text("Video call")
                        .font(.system(size: 14, weight: .regular))

                    HStack(spacing: 4) {
                        ForEach(0..<3) { clubhouseVideoDotIndex in
                            Circle()
                                .fill(.white.opacity(0.68))
                                .frame(width: 4, height: 4)
                                .offset(y: clubhouseVideoIsAnimating ? -3 : 3)
                                .animation(
                                    .easeInOut(duration: 0.58)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(clubhouseVideoDotIndex) * 0.18),
                                    value: clubhouseVideoIsAnimating
                                )
                        }
                    }
                }
                .foregroundStyle(.white.opacity(0.62))
                .padding(.top, 4)

                Spacer()

                Button(action: clubhouseVideoHangUpAction) {
                    ZStack {
                        ForEach(0..<3) { clubhouseVideoRingIndex in
                            Circle()
                                .stroke(Color.white.opacity(0.28 - Double(clubhouseVideoRingIndex) * 0.06), lineWidth: 1)
                                .frame(
                                    width: CGFloat(96 + clubhouseVideoRingIndex * 22),
                                    height: CGFloat(96 + clubhouseVideoRingIndex * 22)
                                )
                                .scaleEffect(clubhouseVideoIsAnimating ? 1.18 : 0.84)
                                .opacity(clubhouseVideoIsAnimating ? 0.08 : 0.42)
                                .animation(
                                    .easeOut(duration: 1.45)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(clubhouseVideoRingIndex) * 0.22),
                                    value: clubhouseVideoIsAnimating
                                )
                        }

                        Circle()
                            .fill(Color(red: 1.0, green: 0.16, blue: 0.43))
                            .frame(width: 68, height: 68)
                            .scaleEffect(clubhouseVideoIsAnimating ? 1.03 : 0.97)
                            .shadow(color: Color(red: 1.0, green: 0.16, blue: 0.43).opacity(0.34), radius: 18, y: 8)

                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 142, height: 142)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 44)
            }
        }.ignoresSafeArea()
        .onAppear {
            clubhouseVideoIsAnimating = true
        }
    }

    private var clubhouseVideoCurrentUserID: String? {
        PlayerBadgeSessionStore.playerBadgeCurrentUserID
    }

    private var clubhouseVideoRoom: ClubPairChatRoomModel? {
        ClubPairChatRoomStore.clubPairReadRoom(clubPairRoomID: clubhouseVideoRoomID)
    }

    private var clubhouseVideoOpponent: TeeBoxUserModel? {
        guard let clubhouseVideoCurrentUserID,
              let clubhouseVideoOpponentID = clubhouseVideoRoom?.clubPairUserIDs.first(where: { $0 != clubhouseVideoCurrentUserID }) else {
            return nil
        }

        return TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: clubhouseVideoOpponentID)
    }

    private var clubhouseVideoName: String {
        guard let clubhouseVideoOpponent else {
            return "Eulgo Player"
        }

        let clubhouseVideoTrimmedName = clubhouseVideoOpponent.teeBoxUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        return clubhouseVideoTrimmedName.isEmpty ? clubhouseVideoOpponent.teeBoxEmail : clubhouseVideoTrimmedName
    }
}

private struct GreenRoomVideoBackgroundView: View {
    let clubhouseVideoAvatarAddress: String

    var body: some View {
        GeometryReader { clubhouseVideoProxy in
            ZStack {
                if clubhouseVideoAvatarAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    LinearGradient(
                        colors: [
                            Color(red: 0.34, green: 0.42, blue: 0.32),
                            Color(red: 0.12, green: 0.18, blue: 0.13),
                            Color(red: 0.42, green: 0.34, blue: 0.30)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image("EULGO_golf_person")
                        .resizable()
                        .scaledToFill()
                        .frame(width: clubhouseVideoProxy.size.width, height: clubhouseVideoProxy.size.height)
                        .scaleEffect(1.7)
                        .opacity(0.42)
                } else {
                    FairwayGalleryImageView(
                        fairwayGalleryImageAddress: clubhouseVideoAvatarAddress,
                        fairwayGalleryContentMode: .fill,
                        fairwayGalleryPlaceholderColor: Color.black.opacity(0.4),
                        fairwayGalleryFailureIconName: "person.fill"
                    )
                    .frame(width: clubhouseVideoProxy.size.width, height: clubhouseVideoProxy.size.height)
                    .blur(radius: 2.2)
                }
            }
            .frame(width: clubhouseVideoProxy.size.width, height: clubhouseVideoProxy.size.height, alignment: .center)
            .clipped()
        }
    }
}

#Preview {
    GreenRoomVideoCallView(clubhouseVideoRoomID: "preview-room") {
    }
}
