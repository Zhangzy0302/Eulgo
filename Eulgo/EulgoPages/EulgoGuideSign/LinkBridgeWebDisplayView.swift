import SwiftUI
import WebKit

struct LinkBridgeWebDisplayView: View {
    let linkBridgeWebAddress: String
    let linkBridgeBackAction: () -> Void

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayHeight: 48,
                    venueFairwayHorizontalPadding: 16,
                    venueFairwayLeadingContent: {
                        VenueFairwayHeaderView.venueFairwayBackButton(action: linkBridgeBackAction)
                    },
                    venueFairwayCenterContent: {
                        EmptyView()
                    },
                    venueFairwayTrailingContent: {
                        EmptyView()
                    }
                )
                .padding(.top, 14)
                .padding(.bottom, 10)

                LinkBridgeWebView(linkBridgeWebAddress: linkBridgeWebAddress)
                    .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .greenPathSwipeBack(greenPathBackAction: linkBridgeBackAction)
    }
}

private struct LinkBridgeWebView: UIViewRepresentable {
    let linkBridgeWebAddress: String

    func makeUIView(context: Context) -> WKWebView {
        let linkBridgeConfiguration = WKWebViewConfiguration()
        let linkBridgeWebView = WKWebView(frame: .zero, configuration: linkBridgeConfiguration)
        linkBridgeWebView.allowsBackForwardNavigationGestures = true
        linkBridgeWebView.backgroundColor = .clear
        linkBridgeWebView.scrollView.backgroundColor = .clear
        return linkBridgeWebView
    }

    func updateUIView(_ linkBridgeWebView: WKWebView, context: Context) {
        guard let linkBridgeURL = linkBridgeResolvedURL else {
            linkBridgeWebView.loadHTMLString(
                "<html><body style='font-family:-apple-system;padding:24px;'>Invalid web address.</body></html>",
                baseURL: nil
            )
            return
        }

        if linkBridgeWebView.url != linkBridgeURL {
            linkBridgeWebView.load(URLRequest(url: linkBridgeURL))
        }
    }

    private var linkBridgeResolvedURL: URL? {
        let linkBridgeTrimmedAddress = linkBridgeWebAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard linkBridgeTrimmedAddress.isEmpty == false else {
            return nil
        }

        if let linkBridgeURL = URL(string: linkBridgeTrimmedAddress),
           linkBridgeURL.scheme != nil {
            return linkBridgeURL
        }

        return URL(string: "https://\(linkBridgeTrimmedAddress)")
    }
}

#Preview {
    LinkBridgeWebDisplayView(linkBridgeWebAddress: "https://www.apple.com") {
    }
}
