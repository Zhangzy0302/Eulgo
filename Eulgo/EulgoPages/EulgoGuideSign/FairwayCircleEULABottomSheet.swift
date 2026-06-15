import SwiftUI
import UIKit

struct FairwayCircleEULABottomSheet: View {
    let fairwayCircleGotItAction: () -> Void
    private let fairwayCircleProhibitedContentItems = [
        "Hate speech, abuse, harassment, or personal attacks;",
        "Pornographic, explicit, or vulgar content;",
        "Content that promotes violence, discrimination, illegal activities, or violations of the rights of others;",
        "Any content that does not fit the community atmosphere or violates public order and good customs."
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.08))
                .frame(width: 42, height: 4)
                .padding(.top, 10)
                .opacity(0)

            VStack(spacing: 18) {
                Text("EULA")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(FairwayStylePalette.fairwayTextPrimary)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        FairwayCircleEULATextBlock("End User License Agreement (EULA)")

                        FairwayCircleEULATextBlock("This End User License Agreement (EULA) governs your use of the Eulgo Application. By downloading, accessing, or using the App, you agree to be bound by this Agreement. If you do not agree to these terms, you may not use this application.")

                        FairwayCircleEULASectionTitle("1. Qualifications")

                        FairwayCircleEULATextBlock("By using the Eulgo App (the \"App\"), you confirm that you are at least 18 years of age. You agree to provide true and accurate age information during registration or use. If you are under the age of 18, you need the express consent of a parent or legal guardian to use the App.")

                        FairwayCircleEULASectionTitle("2. User Generated Content")

                        FairwayCircleEULATextBlock("This app allows users to post and share content, including but not limited to videos, pictures, and text.")

                        FairwayCircleEULATextBlock("By posting content, you agree to the following terms:")

                        FairwayCircleEULATextBlock("Prohibited Content: You may not post any content that is offensive, harmful, or illegal, including but not limited to:")

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(fairwayCircleProhibitedContentItems, id: \.self) { fairwayCircleProhibitedContentItem in
                                FairwayCircleEULATextBlock("- \(fairwayCircleProhibitedContentItem)")
                            }
                        }

                        FairwayCircleEULATextBlock("Content Licensing: You retain ownership of the content posted, but by posting, you grant Eulgo a non-exclusive license to use, distribute, and display the content within the App.")

                        FairwayCircleEULASectionTitle("3. Reporting and Response Mechanism")

                        FairwayCircleEULASubsectionTitle("3.1 Your Responsibilities")

                        FairwayCircleEULATextBlock("If you become aware of user content that violates this EULA, you agree to report it immediately through Eulgo's reporting mechanism.")

                        FairwayCircleEULASubsectionTitle("3.2 Our Response")

                        FairwayCircleEULATextBlock("We will review the reported content within 24 hours and take appropriate measures, including but not limited to removing the offending content, warning or banning the offending user. Users who repeatedly violate the rules may face permanent suspension.")

                        FairwayCircleEULASectionTitle("4. Privacy Policy")

                        FairwayCircleEULATextBlock("By using the App, you acknowledge that you have read and understood our Privacy Policy, which details how we collect, use, and protect your personal information.")

                        FairwayCircleEULASectionTitle("5. Termination")

                        FairwayCircleEULATextBlock("We may terminate or suspend your access to Eulgo at any time for any reason, with or without prior notice. You can also stop using Eulgo and delete your account at any time.")

                        FairwayCircleEULASectionTitle("6. Modification of the Agreement")

                        FairwayCircleEULATextBlock("We may amend this Agreement at any time. Changes will be announced in the App, and your continued use of the App means your acceptance of the revised terms.")

                        FairwayCircleEULASectionTitle("7. Disclaimer")

                        FairwayCircleEULATextBlock("Eulgo is provided \"AS IS\" without warranties of any kind, express or implied. We do not guarantee that the application will always be interruption-free, error-free, or completely secure.")

                        FairwayCircleEULASectionTitle("8. Limitation of Liability")

                        FairwayCircleEULATextBlock("To the fullest extent permitted by law, we are not liable for any damage caused by your use of Eulgo.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 308)

                Button(action: fairwayCircleGotItAction) {
                    Text("Got it")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [
                                    FairwayStylePalette.fairwayLime,
                                    FairwayStylePalette.fairwayMint
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    .white,
                    FairwayStylePalette.fairwayEULACream
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .clipShape(FairwayCircleTopRoundedSheetShape(radius: 28))
        .ignoresSafeArea()
    }
}

private struct FairwayCircleEULASectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.20))
    }
}

private struct FairwayCircleEULASubsectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(FairwayStylePalette.fairwayTextSecondary)
    }
}

private struct FairwayCircleEULATextBlock: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color(red: 0.30, green: 0.30, blue: 0.30))
            .lineSpacing(3)
    }
}

private struct FairwayCircleTopRoundedSheetShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let fairwayCirclePath = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(fairwayCirclePath.cgPath)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.opacity(0.35)
            .ignoresSafeArea()

        FairwayCircleEULABottomSheet {
        }
    }
}
