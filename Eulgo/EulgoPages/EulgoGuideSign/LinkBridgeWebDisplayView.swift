import Combine
import ScreenShield
import SwiftUI
import UIKit
import WebKit

struct LinkBridgeWebDisplayView: View {
    @StateObject private var linkBridgeWebModel: LinkBridgeWebDisplayModel

    let linkBridgeWebAddress: String
    let linkBridgeBackAction: () -> Void

    init(linkBridgeWebAddress: String, linkBridgeBackAction: @escaping () -> Void) {
        self.linkBridgeWebAddress = linkBridgeWebAddress
        self.linkBridgeBackAction = linkBridgeBackAction
        _linkBridgeWebModel = StateObject(
            wrappedValue: LinkBridgeWebDisplayModel(linkBridgeWebAddress: linkBridgeWebAddress)
        )
    }

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            if linkBridgeWebModel.linkBridgeIsBPackageWeb,
               linkBridgeWebModel.linkBridgeIsLoading {
                linkBridgeLaunchBackdrop
            }

            linkBridgePageLayer
                .ignoresSafeArea(edges: linkBridgeWebModel.linkBridgeIsBPackageWeb ? .all : .bottom)

            if linkBridgeWebModel.linkBridgeIsBPackageWeb == false {
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

                    Spacer(minLength: 0)
                }
                .zIndex(20)
            }

            if linkBridgeWebModel.linkBridgeIsLoading {
                LinkBridgeWebLoadingLayer()
                    .zIndex(40)
            }

            if let linkBridgeErrorText = linkBridgeWebModel.linkBridgeLoadErrorText {
                LinkBridgeWebErrorLayer(
                    linkBridgeErrorText: linkBridgeErrorText,
                    linkBridgeRetryAction: linkBridgeWebModel.linkBridgeRetry
                )
                .zIndex(50)
            }

            if linkBridgeWebModel.linkBridgeIsScreenCaptured {
                LinkBridgeWebScreenCaptureLayer()
                    .zIndex(300)
            }
        }
        .protectScreenshot()
        .ignoresSafeArea()
        .greenPathSwipeBack(
            greenPathIsEnabled: linkBridgeWebModel.linkBridgeIsBPackageWeb == false,
            greenPathBackAction: linkBridgeBackAction
        )
        .onAppear {
            linkBridgeWebModel.linkBridgeSceneDidAppear()
        }
        .onDisappear {
            linkBridgeWebModel.linkBridgeSceneDidDisappear()
        }
    }

    @ViewBuilder
    private var linkBridgePageLayer: some View {
        if let linkBridgeURL = linkBridgeWebModel.linkBridgeResolvedURL {
            LinkBridgeWebContainer(
                linkBridgeURL: linkBridgeURL,
                linkBridgeBridge: linkBridgeWebModel.linkBridgeBridge,
                linkBridgeAllowsBackForwardNavigationGestures: linkBridgeWebModel.linkBridgeIsBPackageWeb == false,
                linkBridgeCallbacks: LinkBridgeWebCallbacks(
                    linkBridgeLoadingStarted: linkBridgeWebModel.linkBridgeLoadingStarted,
                    linkBridgeLoadingFinished: linkBridgeWebModel.linkBridgeLoadingFinished,
                    linkBridgeLoadingFailed: linkBridgeWebModel.linkBridgeLoadingFailed,
                    linkBridgeCloseRequested: {
                        linkBridgeWebModel.linkBridgeCloseRequested()
                        linkBridgeBackAction()
                    },
                    linkBridgeRechargeRequested: linkBridgeRechargeRequested,
                    linkBridgeExternalOpenRequested: linkBridgeWebModel.linkBridgeOpenExternalURL
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(linkBridgeWebModel.linkBridgeIsBPackageWeb && linkBridgeWebModel.linkBridgeIsLoading ? 0 : 1)
        } else {
            linkBridgeInvalidAddressView
        }
    }

    private var linkBridgeInvalidAddressView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(FairwayStylePalette.fairwayLinkGreen)

            Text("Invalid web address")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text(linkBridgeWebAddress)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white.opacity(0.70))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var linkBridgeLaunchBackdrop: some View {
        ZStack {
            Image("EULGO_guide_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.02),
                    .black.opacity(0.30),
                    .black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func linkBridgeRechargeRequested(orderCode linkBridgeOrderCode: String, batchNo linkBridgeBatchNo: String) {
        linkBridgeWebModel.linkBridgeRechargeRequested(
            orderCode: linkBridgeOrderCode,
            batchNo: linkBridgeBatchNo
        )
    }
}

@MainActor
private final class LinkBridgeWebDisplayModel: ObservableObject {
    let linkBridgeWebAddress: String
    let linkBridgeBridge = LinkBridgeWebBridge()

    @Published var linkBridgeIsLoading = true
    @Published var linkBridgeLoadErrorText: String?
    @Published var linkBridgeIsScreenCaptured = false

    private var linkBridgeScreenCaptureObservation: NSKeyValueObservation?

    init(linkBridgeWebAddress: String) {
        self.linkBridgeWebAddress = linkBridgeWebAddress
    }

    var linkBridgeResolvedURL: URL? {
        let linkBridgeTrimmedAddress = linkBridgeWebAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard linkBridgeTrimmedAddress.isEmpty == false else {
            return nil
        }

        if let linkBridgeURL = URL(string: linkBridgeTrimmedAddress),
           linkBridgeURL.scheme?.isEmpty == false {
            return linkBridgeURL
        }

        return URL(string: "https://\(linkBridgeTrimmedAddress)")
    }

    var linkBridgeIsBPackageWeb: Bool {
        guard let linkBridgeURL = linkBridgeResolvedURL else {
            return false
        }

        let linkBridgeURLString = linkBridgeURL.absoluteString
        return linkBridgeURLString.contains("openParams=") || linkBridgeURLString.contains("appId=")
    }

    func linkBridgeSceneDidAppear() {
        FairwayRechargeStoreKitOneCenter.fairwayRechargeShared.fairwayRechargePrepareBPackageProducts()
        linkBridgeStartScreenCaptureProtection()
    }

    func linkBridgeSceneDidDisappear() {
        linkBridgeStopScreenCaptureProtection()
    }

    func linkBridgeLoadingStarted() {
        linkBridgeLoadErrorText = nil
        linkBridgeIsLoading = true
    }

    func linkBridgeLoadingFinished(_ linkBridgeDuration: Int) {
        linkBridgeRecordLoadingDuration(linkBridgeDuration)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: linkBridgeIsBPackageWeb ? 250_000_000 : 120_000_000)
            linkBridgeIsLoading = false
        }
    }

    func linkBridgeLoadingFailed(_ linkBridgeErrorText: String) {
        linkBridgeIsLoading = false
        linkBridgeLoadErrorText = linkBridgeErrorText
    }

    func linkBridgeRetry() {
        linkBridgeLoadErrorText = nil
        linkBridgeIsLoading = true
        linkBridgeBridge.linkBridgeReload()
    }

    func linkBridgeCloseRequested() {
        TeeSparkAppStorage.teeSparkUserToken = ""
    }

    func linkBridgeRechargeRequested(orderCode linkBridgeOrderCode: String, batchNo linkBridgeBatchNo: String) {
        teeSparkUsersOrderCode = linkBridgeOrderCode

        FairwayRechargeStoreKitOneCenter.fairwayRechargeShared.fairwayRechargeBuyBPackage(
            productID: linkBridgeBatchNo,
            orderCode: linkBridgeOrderCode
        ) { [weak self] linkBridgeResult in
            Task { @MainActor in
                self?.linkBridgeHandleRechargeResult(linkBridgeResult)
            }
        }
    }

    func linkBridgeOpenExternalURL(_ linkBridgeURLString: String) {
        guard let linkBridgeURL = URL(string: linkBridgeURLString) else {
            linkBridgeNotifyOpenState(state: "failed", urlString: linkBridgeURLString)
            return
        }

        UIApplication.shared.open(linkBridgeURL, options: [:]) { [weak self] linkBridgeSuccess in
            Task { @MainActor in
                self?.linkBridgeNotifyOpenState(
                    state: linkBridgeSuccess ? "success" : "failed",
                    urlString: linkBridgeURL.absoluteString
                )
            }
        }
    }

    private func linkBridgeHandleRechargeResult(_ linkBridgeResult: FairwayRechargePurchaseResult) {
        switch linkBridgeResult {
        case .success(let linkBridgeCoins):
            linkBridgeNotifyRechargeState(state: "success", coins: linkBridgeCoins)

        case .cancelled:
            return

        case .pending:
            linkBridgeNotifyRechargeState(state: "pending")

        case .failed(let linkBridgeMessage):
            GolfPulseOverlayCenter.shared.golfPulseShowToast(linkBridgeMessage, style: .error)
            linkBridgeNotifyRechargeState(state: "failed")
        }
    }

    private func linkBridgeStartScreenCaptureProtection() {
        linkBridgeIsScreenCaptured = UIScreen.main.isCaptured
        linkBridgeScreenCaptureObservation = UIScreen.main.observe(
            \.isCaptured,
            options: [.new]
        ) { [weak self] _, linkBridgeChange in
            let linkBridgeCaptured = linkBridgeChange.newValue ?? false
            Task { @MainActor in
                self?.linkBridgeIsScreenCaptured = linkBridgeCaptured
            }
        }
    }

    private func linkBridgeStopScreenCaptureProtection() {
        linkBridgeScreenCaptureObservation?.invalidate()
        linkBridgeScreenCaptureObservation = nil
        linkBridgeIsScreenCaptured = false
    }

    private func linkBridgeRecordLoadingDuration(_ linkBridgeDuration: Int) {
        guard linkBridgeIsBPackageWeb else {
            return
        }

        Task {
            try? await BirdieBeaconApiCall().birdieBeaconLoadingTimeRecord(linkBridgeDuration)
        }
    }

    private func linkBridgeNotifyOpenState(state linkBridgeState: String, urlString linkBridgeURLString: String) {
        linkBridgeBridge.linkBridgeEvaluateJavaScript(
            linkBridgeNativeOpenStateScript(state: linkBridgeState, urlString: linkBridgeURLString)
        )
    }

    private func linkBridgeNotifyRechargeState(state linkBridgeState: String, coins linkBridgeCoins: Int = 0) {
        linkBridgeBridge.linkBridgeEvaluateJavaScript(
            linkBridgeNativeRechargeStateScript(state: linkBridgeState, coins: linkBridgeCoins)
        )
    }
}

private struct LinkBridgeWebLoadingLayer: View {
    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.28)

            Text("Loading...")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.28))
        .allowsHitTesting(true)
    }
}

private struct LinkBridgeWebErrorLayer: View {
    let linkBridgeErrorText: String
    let linkBridgeRetryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Load failed")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(linkBridgeErrorText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)

            Button(action: linkBridgeRetryAction) {
                Text("Retry")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 26)
                    .frame(height: 44)
                    .background(FairwayStylePalette.fairwayBrandGradient())
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.86))
        .allowsHitTesting(true)
    }
}

private struct LinkBridgeWebScreenCaptureLayer: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text("Screen recording not allowed")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }
}

private final class LinkBridgeWebBridge: ObservableObject {
    weak var linkBridgeWebView: WKWebView?

    func linkBridgeReload() {
        linkBridgeWebView?.reload()
    }

    func linkBridgeEvaluateJavaScript(_ linkBridgeJavaScript: String) {
        DispatchQueue.main.async { [weak self] in
            self?.linkBridgeWebView?.evaluateJavaScript(linkBridgeJavaScript)
        }
    }
}

private struct LinkBridgeWebCallbacks {
    let linkBridgeLoadingStarted: () -> Void
    let linkBridgeLoadingFinished: (Int) -> Void
    let linkBridgeLoadingFailed: (String) -> Void
    let linkBridgeCloseRequested: () -> Void
    let linkBridgeRechargeRequested: (_ orderCode: String, _ batchNo: String) -> Void
    let linkBridgeExternalOpenRequested: (String) -> Void
}

private struct LinkBridgeWebContainer: UIViewRepresentable {
    let linkBridgeURL: URL
    let linkBridgeBridge: LinkBridgeWebBridge
    let linkBridgeAllowsBackForwardNavigationGestures: Bool
    let linkBridgeCallbacks: LinkBridgeWebCallbacks

    func makeUIView(context: Context) -> WKWebView {
        let linkBridgeConfiguration = WKWebViewConfiguration()
        let linkBridgeContentController = WKUserContentController()

        LinkBridgeWebAction.allCases.forEach {
            linkBridgeContentController.add(context.coordinator, name: $0.rawValue)
        }

        linkBridgeConfiguration.userContentController = linkBridgeContentController
        linkBridgeConfiguration.mediaTypesRequiringUserActionForPlayback = []
        linkBridgeConfiguration.allowsInlineMediaPlayback = true

        let linkBridgeWebView = WKWebView(frame: .zero, configuration: linkBridgeConfiguration)
        linkBridgeApplySettings(to: linkBridgeWebView, coordinator: context.coordinator)
        linkBridgeBridge.linkBridgeWebView = linkBridgeWebView
        linkBridgeWebView.load(URLRequest(url: linkBridgeURL))
        return linkBridgeWebView
    }

    func updateUIView(_ linkBridgeWebView: WKWebView, context: Context) {
        context.coordinator.linkBridgeContainer = self
    }

    static func dismantleUIView(_ linkBridgeWebView: WKWebView, coordinator: Coordinator) {
        LinkBridgeWebAction.allCases.forEach {
            linkBridgeWebView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
        linkBridgeWebView.navigationDelegate = nil
        linkBridgeWebView.uiDelegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func linkBridgeApplySettings(to linkBridgeWebView: WKWebView, coordinator: Coordinator) {
        linkBridgeWebView.navigationDelegate = coordinator
        linkBridgeWebView.uiDelegate = coordinator
        linkBridgeWebView.backgroundColor = .clear
        linkBridgeWebView.isOpaque = false
        linkBridgeWebView.scrollView.backgroundColor = .clear
        linkBridgeWebView.scrollView.contentInsetAdjustmentBehavior = .never
        linkBridgeWebView.scrollView.contentInset = .zero
        linkBridgeWebView.scrollView.scrollIndicatorInsets = .zero
        linkBridgeWebView.allowsBackForwardNavigationGestures = true
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var linkBridgeContainer: LinkBridgeWebContainer
        var linkBridgeStartTime: Date?

        init(_ linkBridgeContainer: LinkBridgeWebContainer) {
            self.linkBridgeContainer = linkBridgeContainer
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            linkBridgeStartTime = Date()
            linkBridgeContainer.linkBridgeCallbacks.linkBridgeLoadingStarted()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            linkBridgeContainer.linkBridgeCallbacks.linkBridgeLoadingFinished(linkBridgeElapsedMilliseconds())
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            linkBridgeContainer.linkBridgeCallbacks.linkBridgeLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            linkBridgeContainer.linkBridgeCallbacks.linkBridgeLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let linkBridgeURL = navigationAction.request.url,
                  let linkBridgeScheme = linkBridgeURL.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }

            guard LinkBridgeWebNavigationPolicy.linkBridgeShouldAllow(scheme: linkBridgeScheme) == false else {
                decisionHandler(.allow)
                return
            }

            linkBridgeOpenNonWebURL(linkBridgeURL, webView: webView)
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let linkBridgeURL = navigationAction.request.url else {
                return nil
            }

            if LinkBridgeWebNavigationPolicy.linkBridgeShouldOpenExternally(url: linkBridgeURL) {
                UIApplication.shared.open(linkBridgeURL)
                return nil
            }

            webView.load(URLRequest(url: linkBridgeURL))
            return nil
        }

        @available(iOS 15.0, *)
        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.grant)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let linkBridgeAction = LinkBridgeWebAction(rawValue: message.name) else {
                return
            }

            switch linkBridgeAction {
            case .rechargePay:
                guard let linkBridgeOrder = LinkBridgeWebOrder(body: message.body) else {
                    return
                }
                linkBridgeContainer.linkBridgeCallbacks.linkBridgeRechargeRequested(
                    linkBridgeOrder.linkBridgeOrderCode,
                    linkBridgeOrder.linkBridgeBatchNo
                )

            case .close:
                linkBridgeContainer.linkBridgeCallbacks.linkBridgeCloseRequested()

            case .openBrowser:
                guard let linkBridgeURLString = LinkBridgeWebExternalLink.urlString(from: message.body) else {
                    return
                }
                linkBridgeContainer.linkBridgeCallbacks.linkBridgeExternalOpenRequested(linkBridgeURLString)
            }
        }

        private func linkBridgeElapsedMilliseconds() -> Int {
            linkBridgeStartTime.map {
                Int(Date().timeIntervalSince($0) * 1000)
            } ?? 0
        }

        private func linkBridgeOpenNonWebURL(_ linkBridgeURL: URL, webView: WKWebView) {
            UIApplication.shared.open(linkBridgeURL, options: [:]) { linkBridgeSuccess in
                let linkBridgeScript = linkBridgeNativeOpenStateScript(
                    state: linkBridgeSuccess ? "success" : "failed",
                    urlString: linkBridgeURL.absoluteString
                )
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(linkBridgeScript)
                }
            }
        }
    }
}

private enum LinkBridgeWebAction: String, CaseIterable {
    case rechargePay
    case close = "Close"
    case openBrowser
}

private enum LinkBridgeWebNavigationPolicy {
    static func linkBridgeShouldAllow(scheme linkBridgeScheme: String) -> Bool {
        ["http", "https", "file", "about"].contains(linkBridgeScheme)
    }

    static func linkBridgeShouldOpenExternally(url linkBridgeURL: URL) -> Bool {
        let linkBridgeURLString = linkBridgeURL.absoluteString.lowercased()
        return linkBridgeURL.scheme == "itms-apps"
            || linkBridgeURL.scheme == "itms-services"
            || linkBridgeURLString.contains("apps.apple.com")
    }
}

private struct LinkBridgeWebOrder {
    let linkBridgeOrderCode: String
    let linkBridgeBatchNo: String

    init?(body linkBridgeBody: Any) {
        guard let linkBridgeDict = linkBridgeBody as? [String: Any],
              let linkBridgeOrderCode = linkBridgeDict["orderCode"] as? String,
              let linkBridgeBatchNo = linkBridgeDict["batchNo"] as? String else {
            return nil
        }

        self.linkBridgeOrderCode = linkBridgeOrderCode
        self.linkBridgeBatchNo = linkBridgeBatchNo
    }
}

private enum LinkBridgeWebExternalLink {
    static func urlString(from linkBridgeBody: Any) -> String? {
        if let linkBridgeDict = linkBridgeBody as? [String: Any],
           let linkBridgeURLString = linkBridgeDict["url"] as? String {
            return linkBridgeURLString
        }

        return linkBridgeBody as? String
    }
}

private func linkBridgeJavaScriptEscaped(_ linkBridgeValue: String) -> String {
    linkBridgeValue
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
}

private func linkBridgeNativeOpenStateScript(state linkBridgeState: String, urlString linkBridgeURLString: String) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeOpenState', {
        detail: { state: '\(linkBridgeJavaScriptEscaped(linkBridgeState))', url: '\(linkBridgeJavaScriptEscaped(linkBridgeURLString))' }
    }));
    """
}

private func linkBridgeNativeRechargeStateScript(state linkBridgeState: String, coins linkBridgeCoins: Int) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeRechargeState', {
        detail: { state: '\(linkBridgeJavaScriptEscaped(linkBridgeState))', coins: \(linkBridgeCoins) }
    }));
    """
}

#Preview {
    LinkBridgeWebDisplayView(linkBridgeWebAddress: "https://www.apple.com") {
    }
}
