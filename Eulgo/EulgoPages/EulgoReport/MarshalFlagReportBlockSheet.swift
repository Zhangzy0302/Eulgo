import SwiftUI

struct MarshalFlagReportBlockSheet: View {
    @State private var marshalFlagShowsReportPage = false

    let marshalFlagTargetUserID: String?
    let marshalFlagReportAction: () -> Void
    let marshalFlagBlockAction: (() -> Void)?
    let marshalFlagBlockSuccessAction: () -> Void
    let marshalFlagCancelAction: () -> Void

    init(
        marshalFlagTargetUserID: String? = nil,
        marshalFlagReportAction: @escaping () -> Void,
        marshalFlagBlockAction: (() -> Void)? = nil,
        marshalFlagBlockSuccessAction: @escaping () -> Void = {},
        marshalFlagCancelAction: @escaping () -> Void
    ) {
        self.marshalFlagTargetUserID = marshalFlagTargetUserID
        self.marshalFlagReportAction = marshalFlagReportAction
        self.marshalFlagBlockAction = marshalFlagBlockAction
        self.marshalFlagBlockSuccessAction = marshalFlagBlockSuccessAction
        self.marshalFlagCancelAction = marshalFlagCancelAction
    }

    var body: some View {
        VStack(spacing: 19) {
            MarshalFlagSheetButton(
                marshalFlagTitle: "Report",
                marshalFlagForegroundColor: .black,
                marshalFlagBackground: AnyShapeStyle(FairwayStylePalette.fairwaySuccessGreen),
                marshalFlagAction: marshalFlagOpenReportPage
            )

            MarshalFlagSheetButton(
                marshalFlagTitle: "Block",
                marshalFlagForegroundColor: .white,
                marshalFlagBackground: AnyShapeStyle(FairwayStylePalette.fairwayCardBlack),
                marshalFlagAction: marshalFlagBlockButtonAction
            )

            MarshalFlagSheetButton(
                marshalFlagTitle: "Cancel",
                marshalFlagForegroundColor: FairwayStylePalette.fairwayTextPrimary,
                marshalFlagBackground: AnyShapeStyle(Color(red: 0.96, green: 0.96, blue: 0.96)),
                marshalFlagAction: marshalFlagCancelAction
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 33)
        .padding(.bottom, 27)
        .frame(maxWidth: .infinity)
        .background(FairwayStylePalette.fairwayScoreCream)
        .clipShape(MarshalFlagTopRoundedShape(marshalFlagRadius: 23))
        .fullScreenCover(isPresented: $marshalFlagShowsReportPage) {
            RangerGateReportView(
                rangerGateBackAction: {
                    marshalFlagShowsReportPage = false
                },
                rangerGateSubmitAction: { _, _ in
                    marshalFlagShowsReportPage = false
                    marshalFlagCancelAction()
                    GolfPulseOverlayCenter.shared.golfPulseShowToast("Report submitted", style: .success)
                }
            )
            .fairwayGreenDismissKeyboardOnTap()
        }
    }

    private func marshalFlagOpenReportPage() {
        marshalFlagReportAction()
        marshalFlagShowsReportPage = true
    }

    private func marshalFlagBlockButtonAction() {
        if let marshalFlagBlockAction {
            marshalFlagBlockAction()
            return
        }

        guard let marshalFlagTargetUserID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("No user to block", style: .error)
            marshalFlagCancelAction()
            return
        }

        guard var marshalFlagCurrentUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            marshalFlagCancelAction()
            return
        }

        guard marshalFlagCurrentUser.teeBoxUserID != marshalFlagTargetUserID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("You can't block yourself", style: .error)
            marshalFlagCancelAction()
            return
        }

        let marshalFlagTargetUser = TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: marshalFlagTargetUserID)

        guard marshalFlagCurrentUser.teeBoxBlockedUserIDs.contains(marshalFlagTargetUserID) == false else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Already blocked", style: .normal)
            marshalFlagCancelAction()
            return
        }

        marshalFlagCurrentUser.teeBoxBlockedUserIDs.append(marshalFlagTargetUserID)
        marshalFlagCurrentUser.teeBoxFollowingIDs.removeAll { $0 == marshalFlagTargetUserID }
        marshalFlagCurrentUser.teeBoxFollowerIDs.removeAll { $0 == marshalFlagTargetUserID }

        if var marshalFlagTargetUser {
            marshalFlagTargetUser.teeBoxFollowingIDs.removeAll { $0 == marshalFlagCurrentUser.teeBoxUserID }
            marshalFlagTargetUser.teeBoxFollowerIDs.removeAll { $0 == marshalFlagCurrentUser.teeBoxUserID }
            _ = TeeBoxUserStore.teeBoxUpdateUser(marshalFlagTargetUser)
        }

        _ = TeeBoxUserStore.teeBoxUpdateUser(marshalFlagCurrentUser)
        GolfPulseOverlayCenter.shared.golfPulseShowToast("Blocked", style: .success)
        marshalFlagCancelAction()
        marshalFlagBlockSuccessAction()
    }
}

private struct MarshalFlagSheetButton: View {
    let marshalFlagTitle: String
    let marshalFlagForegroundColor: Color
    let marshalFlagBackground: AnyShapeStyle
    let marshalFlagAction: () -> Void

    var body: some View {
        Button(action: marshalFlagAction) {
            Text(marshalFlagTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(marshalFlagForegroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(marshalFlagBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MarshalFlagTopRoundedShape: Shape {
    let marshalFlagRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let marshalFlagPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: marshalFlagRadius, height: marshalFlagRadius)
        )
        return Path(marshalFlagPath.cgPath)
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()

        Color.black.opacity(0.52)
            .ignoresSafeArea()

        VStack {
            Spacer()

            MarshalFlagReportBlockSheet(
                marshalFlagReportAction: {
                },
                marshalFlagBlockAction: {
                },
                marshalFlagCancelAction: {
                }
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
