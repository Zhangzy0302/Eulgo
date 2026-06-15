import SwiftUI

struct VenueFairwayScoreBottomSheet: View {
    @State private var venueFairwayFacilitiesScore: Int
    @State private var venueFairwayServiceScore: Int
    @State private var venueFairwayOverallScore: Int

    let venueFairwaySubmitAction: (_ venueFairwayFacilitiesScore: Int, _ venueFairwayServiceScore: Int, _ venueFairwayOverallScore: Int) -> Void

    init(
        venueFairwayInitialFacilitiesScore: Int = 4,
        venueFairwayInitialServiceScore: Int = 4,
        venueFairwayInitialOverallScore: Int = 4,
        venueFairwaySubmitAction: @escaping (_ venueFairwayFacilitiesScore: Int, _ venueFairwayServiceScore: Int, _ venueFairwayOverallScore: Int) -> Void
    ) {
        self._venueFairwayFacilitiesScore = State(initialValue: ScoreCardVenueRatingModel.scoreCardClampedScore(venueFairwayInitialFacilitiesScore))
        self._venueFairwayServiceScore = State(initialValue: ScoreCardVenueRatingModel.scoreCardClampedScore(venueFairwayInitialServiceScore))
        self._venueFairwayOverallScore = State(initialValue: ScoreCardVenueRatingModel.scoreCardClampedScore(venueFairwayInitialOverallScore))
        self.venueFairwaySubmitAction = venueFairwaySubmitAction
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 22) {
                Text("What do you think of\nthis golf course?")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.black)
                    .lineSpacing(4)
                    .padding(.top, 32)
                    .padding(.trailing, 84)

                VStack(alignment: .leading, spacing: 18) {
                    VenueFairwayScoreRowView(
                        venueFairwayScoreTitle: "Facilities",
                        venueFairwaySelectedScore: $venueFairwayFacilitiesScore
                    )

                    VenueFairwayScoreRowView(
                        venueFairwayScoreTitle: "Service",
                        venueFairwaySelectedScore: $venueFairwayServiceScore
                    )

                    VenueFairwayScoreRowView(
                        venueFairwayScoreTitle: "Overall",
                        venueFairwaySelectedScore: $venueFairwayOverallScore
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button {
                    venueFairwaySubmitAction(
                        venueFairwayFacilitiesScore,
                        venueFairwayServiceScore,
                        venueFairwayOverallScore
                    )
                } label: {
                    Text("Submit")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [
                                    FairwayStylePalette.fairwaySoftLime,
                                FairwayStylePalette.fairwaySoftMint
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .padding(.bottom, 34)
            }
            .padding(.horizontal, 14)
            .background(
                Image("EULGO_mark_bottom_bg")
                    .resizable()
                    .scaledToFill()
            )

            
        }
    }
}

private struct VenueFairwayScoreRowView: View {
    let venueFairwayScoreTitle: String
    @Binding var venueFairwaySelectedScore: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(venueFairwayScoreTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black)

            HStack(spacing: 22) {
                ForEach(1...5, id: \.self) { venueFairwayStarValue in
                    Button {
                        venueFairwaySelectedScore = venueFairwayStarValue
                    } label: {
                        Image(systemName: venueFairwayStarValue <= venueFairwaySelectedScore ? "star.fill" : "star")
                            .font(.system(size: 33, weight: .bold))
                            .foregroundStyle(Color(red: 1.0, green: 0.67, blue: 0.02))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct VenueFairwayTopRoundedSheetShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let venueFairwayPath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(venueFairwayPath.cgPath)
    }
}

#Preview {
    ZStack {
        CourseAccessAuthBackgroundView()
            .opacity(0.45)

        VStack {
            Spacer()

            VenueFairwayScoreBottomSheet { _, _, _ in
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
