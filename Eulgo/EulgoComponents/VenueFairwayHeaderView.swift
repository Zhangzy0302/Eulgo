import SwiftUI

struct VenueFairwayHeaderView: View {
    private let venueFairwayHeight: CGFloat
    private let venueFairwayHorizontalPadding: CGFloat
    private let venueFairwayLeadingContent: AnyView
    private let venueFairwayCenterContent: AnyView
    private let venueFairwayTrailingContent: AnyView

    init(
        venueFairwayTitle: String,
        venueFairwayBackAction: @escaping () -> Void,
        venueFairwayTrailingAction: (() -> Void)? = nil,
        venueFairwayHorizontalPadding: CGFloat = 16
    ) {
        self.venueFairwayHeight = 48
        self.venueFairwayHorizontalPadding = venueFairwayHorizontalPadding
        self.venueFairwayLeadingContent = AnyView(Self.venueFairwayBackButton(action: venueFairwayBackAction))
        self.venueFairwayCenterContent = AnyView(Self.venueFairwayTitleText(venueFairwayTitle))
        if let venueFairwayTrailingAction {
            self.venueFairwayTrailingContent = AnyView(Self.venueFairwayReportButton(action: venueFairwayTrailingAction))
        } else {
            self.venueFairwayTrailingContent = AnyView(EmptyView())
        }
    }

    init<LeadingContent: View, CenterContent: View, TrailingContent: View>(
        venueFairwayHeight: CGFloat = 48,
        venueFairwayHorizontalPadding: CGFloat = 16,
        @ViewBuilder venueFairwayLeadingContent: () -> LeadingContent,
        @ViewBuilder venueFairwayCenterContent: () -> CenterContent,
        @ViewBuilder venueFairwayTrailingContent: () -> TrailingContent
    ) {
        self.venueFairwayHeight = venueFairwayHeight
        self.venueFairwayHorizontalPadding = venueFairwayHorizontalPadding
        self.venueFairwayLeadingContent = AnyView(venueFairwayLeadingContent())
        self.venueFairwayCenterContent = AnyView(venueFairwayCenterContent())
        self.venueFairwayTrailingContent = AnyView(venueFairwayTrailingContent())
    }

    var body: some View {
        ZStack {
            venueFairwayCenterContent

            HStack {
                venueFairwayLeadingContent

                Spacer()

                venueFairwayTrailingContent
            }
        }
        .frame(height: venueFairwayHeight)
        .padding(.horizontal, venueFairwayHorizontalPadding)
    }

    static func venueFairwayTitleText(_ venueFairwayTitle: String, venueFairwayFontSize: CGFloat = 16) -> some View {
        Text(venueFairwayTitle)
            .font(.system(size: venueFairwayFontSize, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(1)
    }

    static func venueFairwayBackButton(action: @escaping () -> Void, venueFairwaySize: CGFloat = 48) -> some View {
        Button(action: action) {
            Image("EULGO_back_btn")
                .resizable()
                .scaledToFit()
                .frame(width: venueFairwaySize, height: venueFairwaySize)
        }
        .buttonStyle(.plain)
    }

    static func venueFairwayReportButton(action: @escaping () -> Void, venueFairwaySize: CGFloat = 48) -> some View {
        Button(action: action) {
            Image("EULGO_report_icon")
                .resizable()
                .frame(width: 20, height: 20)
                .frame(width: venueFairwaySize, height: venueFairwaySize)
                .background(FairwayStylePalette.fairwayHeaderControlBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()

        VenueFairwayHeaderView(
            venueFairwayTitle: "Cypress Point Club",
            venueFairwayBackAction: {
            }
        )
    }
}
