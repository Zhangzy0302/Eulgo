import SwiftUI
import UIKit

struct FairwayGalleryImageView: View {
    let fairwayGalleryImageAddress: String
    let fairwayGalleryContentMode: ContentMode
    let fairwayGalleryPlaceholderColor: Color
    let fairwayGalleryFailureIconName: String

    init(
        fairwayGalleryImageAddress: String,
        fairwayGalleryContentMode: ContentMode = .fill,
        fairwayGalleryPlaceholderColor: Color = Color.white.opacity(0.18),
        fairwayGalleryFailureIconName: String = "photo"
    ) {
        self.fairwayGalleryImageAddress = fairwayGalleryImageAddress
        self.fairwayGalleryContentMode = fairwayGalleryContentMode
        self.fairwayGalleryPlaceholderColor = fairwayGalleryPlaceholderColor
        self.fairwayGalleryFailureIconName = fairwayGalleryFailureIconName
    }

    var body: some View {
        switch FairwayGalleryImageSource.resolve(fairwayGalleryImageAddress) {
        case .network(let fairwayGalleryURL):
            AsyncImage(url: fairwayGalleryURL) { fairwayGalleryPhase in
                switch fairwayGalleryPhase {
                case .empty:
                    FairwayGalleryImagePlaceholderView(
                        fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                        fairwayGalleryIconName: "photo"
                    )
                case .success(let fairwayGalleryImage):
                    fairwayGalleryConfiguredImage(fairwayGalleryImage)
                case .failure:
                    FairwayGalleryImagePlaceholderView(
                        fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                        fairwayGalleryIconName: fairwayGalleryFailureIconName
                    )
                @unknown default:
                    FairwayGalleryImagePlaceholderView(
                        fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                        fairwayGalleryIconName: fairwayGalleryFailureIconName
                    )
                }
            }

        case .file(let fairwayGalleryURL):
            if let fairwayGalleryUIImage = UIImage(contentsOfFile: fairwayGalleryURL.path) {
                fairwayGalleryConfiguredImage(Image(uiImage: fairwayGalleryUIImage))
            } else {
                FairwayGalleryImagePlaceholderView(
                    fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                    fairwayGalleryIconName: fairwayGalleryFailureIconName
                )
            }

        case .asset(let fairwayGalleryAssetName):
            if let fairwayGalleryUIImage = UIImage(named: fairwayGalleryAssetName) {
                fairwayGalleryConfiguredImage(Image(uiImage: fairwayGalleryUIImage))
            } else {
                FairwayGalleryImagePlaceholderView(
                    fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                    fairwayGalleryIconName: fairwayGalleryFailureIconName
                )
            }

        case .missing:
            FairwayGalleryImagePlaceholderView(
                fairwayGalleryPlaceholderColor: fairwayGalleryPlaceholderColor,
                fairwayGalleryIconName: fairwayGalleryFailureIconName
            )
        }
    }

    private func fairwayGalleryConfiguredImage(_ fairwayGalleryImage: Image) -> some View {
        fairwayGalleryImage
            .resizable()
            .aspectRatio(contentMode: fairwayGalleryContentMode)
    }
}

private enum FairwayGalleryImageSource {
    case network(URL)
    case file(URL)
    case asset(String)
    case missing

    static func resolve(_ fairwayGalleryAddress: String) -> FairwayGalleryImageSource {
        let fairwayGalleryTrimmedAddress = fairwayGalleryAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard fairwayGalleryTrimmedAddress.isEmpty == false else {
            return .missing
        }

        if let fairwayGalleryURL = URL(string: fairwayGalleryTrimmedAddress),
           let fairwayGalleryScheme = fairwayGalleryURL.scheme?.lowercased() {
            if fairwayGalleryScheme == "http" || fairwayGalleryScheme == "https" {
                return .network(fairwayGalleryURL)
            }

            if fairwayGalleryScheme == "file" {
                return .file(fairwayGalleryURL)
            }
        }

        let fairwayGalleryExpandedPath = fairwayGalleryTrimmedAddress.replacingOccurrences(
            of: "~/",
            with: NSHomeDirectory() + "/"
        )

        if fairwayGalleryExpandedPath.hasPrefix("/") {
            return .file(URL(fileURLWithPath: fairwayGalleryExpandedPath))
        }

        return .asset(fairwayGalleryTrimmedAddress)
    }
}

private struct FairwayGalleryImagePlaceholderView: View {
    let fairwayGalleryPlaceholderColor: Color
    let fairwayGalleryIconName: String

    var body: some View {
        ZStack {
            fairwayGalleryPlaceholderColor

            Image(systemName: fairwayGalleryIconName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.58))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        FairwayGalleryImageView(fairwayGalleryImageAddress: "EULGO_App_Icon")
            .frame(width: 88, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

        FairwayGalleryImageView(fairwayGalleryImageAddress: "https://example.com/course.png")
            .frame(width: 180, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .padding()
    .background(Color(red: 0.05, green: 0.18, blue: 0.10))
}
