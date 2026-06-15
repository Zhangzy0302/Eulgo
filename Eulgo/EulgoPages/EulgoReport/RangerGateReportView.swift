import SwiftUI
import UIKit

struct RangerGateReportView: View {
    @State private var rangerGateSelectedType = "Harassment"
    @State private var rangerGateSupplementaryText = ""

    let rangerGateBackAction: () -> Void
    let rangerGateSubmitAction: (String, String) -> Void

    private let rangerGateReportTypes = [
        "Harassment",
        "Malicious fraud",
        "Pornography",
        "Malicious insults",
        "False Information"
    ]

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(alignment: .leading, spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: "Report",
                    venueFairwayBackAction: rangerGateBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 0
                )
                .padding(.top, 14)

                Text("Report Type")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)

                VStack(spacing: 13) {
                    ForEach(rangerGateReportTypes, id: \.self) { rangerGateType in
                        RangerGateReportTypeButton(
                            rangerGateTitle: rangerGateType,
                            rangerGateIsSelected: rangerGateSelectedType == rangerGateType,
                            rangerGateAction: {
                                rangerGateSelectedType = rangerGateType
                            }
                        )
                    }
                }
                .padding(.top, 12)

                RangerGateSupplementaryEditor(rangerGateText: $rangerGateSupplementaryText)
                    .padding(.top, 27)

                Spacer(minLength: 24)

                Button(action: rangerGateSubmitReport) {
                    Text("Submit")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(FairwayStylePalette.fairwayBrandGradient())
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
        .greenPathSwipeBack(greenPathBackAction: rangerGateBackAction)
    }

    private func rangerGateSubmitReport() {
        rangerGateSubmitAction(rangerGateSelectedType, rangerGateSupplementaryText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

private struct RangerGateReportTypeButton: View {
    let rangerGateTitle: String
    let rangerGateIsSelected: Bool
    let rangerGateAction: () -> Void

    var body: some View {
        Button(action: rangerGateAction) {
            Text(rangerGateTitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 43)
                .background(rangerGateIsSelected ? FairwayStylePalette.fairwaySuccessGreen : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct RangerGateSupplementaryEditor: View {
    @Binding var rangerGateText: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if rangerGateText.isEmpty {
                Text("Supplementary description (optional)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.38))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
            }

            LawnNoteTransparentTextView(
                lawnNoteText: $rangerGateText,
                lawnNoteInsets: UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
            )
        }
        .frame(height: 140)
        .background(FairwayStylePalette.fairwayPanelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    RangerGateReportView(
        rangerGateBackAction: {
        },
        rangerGateSubmitAction: { _, _ in
        }
    )
    .fairwayGreenDismissKeyboardOnTap()
}
