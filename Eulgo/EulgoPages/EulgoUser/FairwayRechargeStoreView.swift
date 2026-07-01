import Combine
@preconcurrency import StoreKit
import SwiftUI

struct FairwayRechargeStoreView: View {
    @StateObject private var fairwayRechargeStoreKit = FairwayRechargeStoreKitOneCenter.fairwayRechargeShared
    @State private var fairwayRechargeRefreshToken = UUID()
    @State private var fairwayRechargeShowsGuestRestriction = false

    let fairwayRechargeBackAction: () -> Void


    private let fairwayRechargePackages = FairwayRechargeStoreKitOneCenter.fairwayRechargeDefaultPackages

    private let fairwayRechargeColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            CourseAccessAuthBackgroundView()

            VStack(spacing: 0) {
                VenueFairwayHeaderView(
                    venueFairwayTitle: "Recharge",
                    venueFairwayBackAction: fairwayRechargeBackAction,
                    venueFairwayTrailingAction: nil,
                    venueFairwayHorizontalPadding: 14
                )
                .padding(.top, 14)

                HStack(spacing: 8) {
                    Image("EULGO_coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)

                    Text("\(fairwayRechargeCurrentCoinCount)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: fairwayRechargeColumns, spacing: 12) {
                        ForEach(fairwayRechargePackages) { fairwayRechargePackage in
                            FairwayRechargePackageCard(
                                fairwayRechargePackage: fairwayRechargePackage,
                                fairwayRechargeBuyAction: {
                                    fairwayRechargeBuyAction(fairwayRechargePackage)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
                }
            }

            if fairwayRechargeShowsGuestRestriction {
                GuestPassBrowseOnlyView {
                    fairwayRechargeShowsGuestRestriction = false
                }
                .transition(.opacity)
                .zIndex(2)
            }

        }
        .id(fairwayRechargeRefreshToken)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: fairwayRechargeShowsGuestRestriction)
        .onAppear {
            fairwayRechargeStoreKit.fairwayRechargeLoadProducts(
                fairwayRechargePackages,
                fairwayRechargeIsInitialConfiguration: true
            )
        }
        .greenPathSwipeBack(greenPathBackAction: fairwayRechargeBackAction)
    }

    private var fairwayRechargeCurrentCoinCount: Int {
        PlayerBadgeSessionStore.playerBadgeReadLoginUser()?.teeBoxCoinCount ?? 0
    }

    private func fairwayRechargeBuyAction(_ fairwayRechargePackage: FairwayRechargePackage) {
        guard GuestPassAccessGuard.guestPassIsGuest == false else {
            fairwayRechargeShowsGuestRestriction = true
            return
        }

        fairwayRechargeStoreKit.fairwayRechargeBuy(
            fairwayRechargePackage,
            fairwayRechargeSuccessAction: {
                fairwayRechargeRefreshToken = UUID()
            }
        )
    }
}

struct FairwayRechargePackage: Identifiable {
    let fairwayRechargeProductID: String?
    let fairwayRechargeCoins: Int
    let fairwayRechargePrice: String
    let fairwayRechargeDollar: Double

    var id: String { fairwayRechargeProductID ?? "fairway-recharge-fixed-\(fairwayRechargeCoins)" }
}

enum FairwayRechargePurchaseResult {
    case success(coins: Int)
    case cancelled
    case pending
    case failed(message: String)
}

private struct FairwayRechargePackageCard: View {
    let fairwayRechargePackage: FairwayRechargePackage
    let fairwayRechargeBuyAction: () -> Void

    var body: some View {
        Button(action: fairwayRechargeBuyAction) {
            VStack(spacing: 7) {
                Spacer(minLength: 0)

                Image("EULGO_coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Text("\(fairwayRechargePackage.fairwayRechargeCoins)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)

                Text(fairwayRechargePackage.fairwayRechargePrice)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.44, blue: 0.75),
                                Color(red: 0.93, green: 0.16, blue: 0.62)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .padding(.horizontal, 12)
                    .padding(.top, 2)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 123)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

final class FairwayRechargeStoreKitOneCenter: NSObject, ObservableObject {
    static let fairwayRechargeShared = FairwayRechargeStoreKitOneCenter()
    
    static let fairwayRechargeDefaultPackages = [
        FairwayRechargePackage(fairwayRechargeProductID: "kfjlddxvsqtchcuw", fairwayRechargeCoins: 400, fairwayRechargePrice: "$ 0.99", fairwayRechargeDollar: 0.99),
        FairwayRechargePackage(fairwayRechargeProductID: "qkaqznlytfbqfllu", fairwayRechargeCoins: 800, fairwayRechargePrice: "$ 1.99", fairwayRechargeDollar: 1.99),
        FairwayRechargePackage(fairwayRechargeProductID: "mzkqvbrltyxnpafh", fairwayRechargeCoins: 1780, fairwayRechargePrice: "$ 3.99", fairwayRechargeDollar: 3.99),
        FairwayRechargePackage(fairwayRechargeProductID: "cmbfsbsszfbamaak", fairwayRechargeCoins: 2450, fairwayRechargePrice: "$ 4.99", fairwayRechargeDollar: 4.99),
        FairwayRechargePackage(fairwayRechargeProductID: "yqgshbdynhmamvkh", fairwayRechargeCoins: 5150, fairwayRechargePrice: "$ 9.99", fairwayRechargeDollar: 9.99),
        FairwayRechargePackage(fairwayRechargeProductID: "mahlyshlxhzdznfw", fairwayRechargeCoins: 10800, fairwayRechargePrice: "$ 19.99", fairwayRechargeDollar: 19.99),
        FairwayRechargePackage(fairwayRechargeProductID: "qjwdcseunhprgklo", fairwayRechargeCoins: 14900, fairwayRechargePrice: "$ 29.99", fairwayRechargeDollar: 29.99),
        FairwayRechargePackage(fairwayRechargeProductID: "herxrexajkgqjqxk", fairwayRechargeCoins: 29400, fairwayRechargePrice: "$ 49.99", fairwayRechargeDollar: 49.99),
        FairwayRechargePackage(fairwayRechargeProductID: "vbtfzmxqaylewrin", fairwayRechargeCoins: 34500, fairwayRechargePrice: "$ 69.99", fairwayRechargeDollar: 69.99),
        FairwayRechargePackage(fairwayRechargeProductID: "zrnvahqmueviabzl", fairwayRechargeCoins: 63700, fairwayRechargePrice: "$ 99.99", fairwayRechargeDollar: 99.99)
    ]

    @Published var fairwayRechargeProductsByID: [String: SKProduct] = [:]
    @Published var fairwayRechargePurchasingProductID: String?

    private var fairwayRechargeProductsRequest: SKProductsRequest?
    private var fairwayRechargePackagesByProductID: [String: FairwayRechargePackage] = [:]
    private var fairwayRechargePendingOrderCodes: [String: String] = [:]
    private var fairwayRechargePendingCompletions: [String: (FairwayRechargePurchaseResult) -> Void] = [:]
    private var fairwayRechargeFinishedTransactionIDs: Set<String> = []
    private var fairwayRechargeRetryCount = 0
    private var fairwayRechargeTotalRequestCount = 0
    private let fairwayRechargeMaxTotalRequestCount = 10
    private let fairwayRechargeMaxRetryCount = 10
    private var fairwayRechargeIsRequesting = false

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        fairwayRechargeProductsRequest?.cancel()
    }

    func fairwayRechargeLoadProducts(
        _ fairwayRechargePackages: [FairwayRechargePackage],
        fairwayRechargeIsInitialConfiguration: Bool = false
    ) {
        guard fairwayRechargeTotalRequestCount < fairwayRechargeMaxTotalRequestCount else {
            if fairwayRechargeIsInitialConfiguration {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            }
            return
        }

        guard fairwayRechargeIsRequesting == false else {
            return
        }

        guard fairwayRechargeProductsByID.isEmpty else {
            if fairwayRechargeIsInitialConfiguration {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            }
            return
        }

        fairwayRechargePackagesByProductID = fairwayRechargePackages.reduce(into: [:]) { fairwayRechargeResult, fairwayRechargePackage in
            guard let fairwayRechargeProductID = fairwayRechargePackage.fairwayRechargeProductID,
                  fairwayRechargeResult[fairwayRechargeProductID] == nil else {
                return
            }

            fairwayRechargeResult[fairwayRechargeProductID] = fairwayRechargePackage
        }

        let fairwayRechargeProductIDs = Set(fairwayRechargePackagesByProductID.keys)
        guard fairwayRechargeProductIDs.isEmpty == false else {
            if fairwayRechargeIsInitialConfiguration {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            }
            return
        }

        fairwayRechargeProductsRequest?.cancel()
        fairwayRechargeIsRequesting = true
        fairwayRechargeTotalRequestCount += 1

        if fairwayRechargeIsInitialConfiguration {
            GolfPulseOverlayCenter.shared.golfPulseShowLoading()
        }

        let fairwayRechargeRequest = SKProductsRequest(productIdentifiers: fairwayRechargeProductIDs)
        fairwayRechargeRequest.delegate = self
        fairwayRechargeProductsRequest = fairwayRechargeRequest
        fairwayRechargeRequest.start()
    }

    func fairwayRechargeBuy(
        _ fairwayRechargePackage: FairwayRechargePackage,
        fairwayRechargeSuccessAction: @escaping () -> Void
    ) {
        guard let fairwayRechargeProductID = fairwayRechargePackage.fairwayRechargeProductID,
              self.fairwayRechargePackage(for: fairwayRechargeProductID) != nil else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Payment package unavailable", style: .error)
            return
        }

        guard PlayerBadgeSessionStore.playerBadgeCurrentUserID != nil else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .error)
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Purchases are unavailable", style: .error)
            return
        }

        guard fairwayRechargePurchasingProductID == nil else {
            return
        }

        fairwayRechargeSetPendingCompletion(productID: fairwayRechargeProductID) { fairwayRechargeResult in
            if case .success = fairwayRechargeResult {
                fairwayRechargeSuccessAction()
            }
        }

        guard let fairwayRechargeProduct = fairwayRechargeProductsByID[fairwayRechargeProductID] else {
            fairwayRechargePendingCompletions.removeValue(forKey: fairwayRechargeProductID)
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Products are loading", style: .normal)
            fairwayRechargePrepareBPackageProducts()
            return
        }

        fairwayRechargeStartPayment(product: fairwayRechargeProduct)
    }

    func fairwayRechargePrepareBPackageProducts() {
        fairwayRechargeLoadProducts(Self.fairwayRechargeDefaultPackages)
    }

    func fairwayRechargeBuyBPackage(
        productID fairwayRechargeProductID: String,
        orderCode fairwayRechargeOrderCode: String,
        completion fairwayRechargeCompletion: @escaping (FairwayRechargePurchaseResult) -> Void
    ) {
        let fairwayRechargeConfiguredIDs = Set(
            Self.fairwayRechargeDefaultPackages.compactMap(\.fairwayRechargeProductID)
        ).sorted()
        let fairwayRechargeLoadedIDs = fairwayRechargeProductsByID.keys.sorted()
        print("B package recharge ids, configured: \(fairwayRechargeConfiguredIDs), loaded: \(fairwayRechargeLoadedIDs), selected: \(fairwayRechargeProductID)")

        guard fairwayRechargePackage(for: fairwayRechargeProductID) != nil else {
            fairwayRechargeCompletion(.failed(message: "Payment package unavailable"))
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            fairwayRechargeCompletion(.failed(message: "Payment is unavailable"))
            return
        }

        guard fairwayRechargePurchasingProductID == nil else {
            return
        }

        TeeSparkAppStorage.teeSparkIsB = true

        fairwayRechargePendingOrderCodes[fairwayRechargeProductID] = fairwayRechargeOrderCode
        fairwayRechargePendingCompletions[fairwayRechargeProductID] = fairwayRechargeCompletion

        guard let fairwayRechargeProduct = fairwayRechargeProductsByID[fairwayRechargeProductID] else {
            fairwayRechargePendingOrderCodes.removeValue(forKey: fairwayRechargeProductID)
            fairwayRechargePendingCompletions.removeValue(forKey: fairwayRechargeProductID)
            fairwayRechargePrepareBPackageProducts()
            fairwayRechargeCompletion(.failed(message: "Products are loading"))
            return
        }

        fairwayRechargeStartPayment(product: fairwayRechargeProduct)
    }

    private func fairwayRechargeHandlePurchaseResult(
        _ fairwayRechargeResult: FairwayRechargePurchaseResult,
        productID fairwayRechargeProductID: String
    ) {
        let fairwayRechargeIsBPackageResult = fairwayRechargePendingOrderCodes[fairwayRechargeProductID] != nil
        let fairwayRechargeCompletion = fairwayRechargePendingCompletions.removeValue(forKey: fairwayRechargeProductID)

        switch fairwayRechargeResult {
        case .success(let fairwayRechargeCoins):
            if fairwayRechargeIsBPackageResult == false {
                fairwayRechargeAddCoins(fairwayRechargeCoins)
            }
            fairwayRechargeCompletion?(fairwayRechargeResult)

        case .cancelled:
            if fairwayRechargeIsBPackageResult == false {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Purchase cancelled", style: .normal)
            }
            fairwayRechargeCompletion?(fairwayRechargeResult)

        case .pending:
            if fairwayRechargeIsBPackageResult == false {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Purchase pending", style: .normal)
            }
            fairwayRechargeCompletion?(fairwayRechargeResult)

        case .failed(let fairwayRechargeMessage):
            if fairwayRechargeIsBPackageResult == false {
                GolfPulseOverlayCenter.shared.golfPulseShowToast(fairwayRechargeMessage, style: .error)
            }
            fairwayRechargeCompletion?(fairwayRechargeResult)
        }

        fairwayRechargePendingOrderCodes.removeValue(forKey: fairwayRechargeProductID)
        fairwayRechargePurchasingProductID = nil
    }

    private func fairwayRechargeFinishPurchase(
        fairwayRechargeProductID: String,
        fairwayRechargeTransactionID: String?
    ) {
        if let fairwayRechargeTransactionID {
            guard fairwayRechargeFinishedTransactionIDs.contains(fairwayRechargeTransactionID) == false else {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                return
            }

            fairwayRechargeFinishedTransactionIDs.insert(fairwayRechargeTransactionID)
        }

        guard let fairwayRechargePackage = fairwayRechargePackage(for: fairwayRechargeProductID) else {
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            return
        }

        EagleCaddieAdjustManager.shared.eagleCaddieTrackPurchase(dollar: fairwayRechargePackage.fairwayRechargeDollar)
        fairwayRechargeHandlePurchaseResult(
            .success(coins: fairwayRechargePackage.fairwayRechargeCoins),
            productID: fairwayRechargeProductID
        )
        GolfPulseOverlayCenter.shared.golfPulseHideLoading()
    }

    private func fairwayRechargeFinishBPackagePurchase(_ fairwayRechargeTransaction: SKPaymentTransaction) {
        let fairwayRechargeProductID = fairwayRechargeTransaction.payment.productIdentifier
        let fairwayRechargePurchaseID = fairwayRechargeTransaction.transactionIdentifier ?? ""
        let fairwayRechargeOrderCode = fairwayRechargePendingOrderCodes[fairwayRechargeProductID] ?? teeSparkUsersOrderCode
        let fairwayRechargeVerificationData = fairwayRechargeReceiptDataString()

        if let fairwayRechargeTransactionID = fairwayRechargeTransaction.transactionIdentifier {
            guard fairwayRechargeFinishedTransactionIDs.contains(fairwayRechargeTransactionID) == false else {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                return
            }

            fairwayRechargeFinishedTransactionIDs.insert(fairwayRechargeTransactionID)
        }

        guard let fairwayRechargePackage = fairwayRechargePackage(for: fairwayRechargeProductID) else {
            SKPaymentQueue.default().finishTransaction(fairwayRechargeTransaction)
            fairwayRechargeHandlePurchaseResult(
                .failed(message: "Payment package unavailable"),
                productID: fairwayRechargeProductID
            )
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            return
        }

        Task {
            do {
                let fairwayRechargeDidVerify = try await BirdieBeaconApiCall().birdieBeaconPayCall(
                    purchaseID: fairwayRechargePurchaseID,
                    serverVerificationData: fairwayRechargeVerificationData,
                    orderCode: fairwayRechargeOrderCode
                )

                await MainActor.run {
                    SKPaymentQueue.default().finishTransaction(fairwayRechargeTransaction)

                    if fairwayRechargeDidVerify {
                        EagleCaddieAdjustManager.shared.eagleCaddieTrackPurchase(dollar: fairwayRechargePackage.fairwayRechargeDollar)
                        self.fairwayRechargeHandlePurchaseResult(
                            .success(coins: fairwayRechargePackage.fairwayRechargeCoins),
                            productID: fairwayRechargeProductID
                        )
                    } else {
                        self.fairwayRechargeHandlePurchaseResult(
                            .failed(message: "Purchase unverified"),
                            productID: fairwayRechargeProductID
                        )
                    }
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                }
            } catch {
                await MainActor.run {
                    SKPaymentQueue.default().finishTransaction(fairwayRechargeTransaction)
                    self.fairwayRechargeHandlePurchaseResult(
                        .failed(message: error.localizedDescription),
                        productID: fairwayRechargeProductID
                    )
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                }
            }
        }
    }

    private func fairwayRechargeAddCoins(_ fairwayRechargeCoins: Int) {
        guard var fairwayRechargeUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Please log in first", style: .normal)
            return
        }

        fairwayRechargeUser.teeBoxCoinCount += fairwayRechargeCoins
        guard TeeBoxUserStore.teeBoxUpdateUser(fairwayRechargeUser) else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Recharge save failed", style: .error)
            return
        }

        GolfPulseOverlayCenter.shared.golfPulseShowToast("Recharge successful", style: .success)
    }

    private func fairwayRechargeReceiptDataString() -> String {
        guard let fairwayRechargeReceiptURL = Bundle.main.appStoreReceiptURL,
              let fairwayRechargeReceiptData = try? Data(contentsOf: fairwayRechargeReceiptURL) else {
            return ""
        }

        return fairwayRechargeReceiptData.base64EncodedString()
    }

    private func fairwayRechargeRetryFetch() {
        fairwayRechargeRetryCount += 1

        guard fairwayRechargeRetryCount < fairwayRechargeMaxRetryCount,
              fairwayRechargeTotalRequestCount < fairwayRechargeMaxTotalRequestCount else {
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Products load failed", style: .error)
            return
        }

        let fairwayRechargeDelay = pow(2.0, Double(fairwayRechargeRetryCount))
        DispatchQueue.main.asyncAfter(deadline: .now() + fairwayRechargeDelay) {
            self.fairwayRechargeLoadProducts(Array(self.fairwayRechargePackagesByProductID.values))
        }
    }
}

private extension FairwayRechargeStoreKitOneCenter {
    func fairwayRechargePackage(for fairwayRechargeProductID: String) -> FairwayRechargePackage? {
        if let fairwayRechargePackage = fairwayRechargePackagesByProductID[fairwayRechargeProductID] {
            return fairwayRechargePackage
        }

        return Self.fairwayRechargeDefaultPackages.first {
            $0.fairwayRechargeProductID == fairwayRechargeProductID
        }
    }

    func fairwayRechargeStartPayment(product fairwayRechargeProduct: SKProduct) {
        fairwayRechargePurchasingProductID = fairwayRechargeProduct.productIdentifier
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()
        SKPaymentQueue.default().add(SKPayment(product: fairwayRechargeProduct))
    }

    func fairwayRechargeSetPendingCompletion(
        productID fairwayRechargeProductID: String,
        completion fairwayRechargeCompletion: @escaping (FairwayRechargePurchaseResult) -> Void
    ) {
        fairwayRechargePendingCompletions[fairwayRechargeProductID] = fairwayRechargeCompletion
    }
}

extension FairwayRechargeStoreKitOneCenter: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.fairwayRechargeIsRequesting = false
            self.fairwayRechargeRetryCount = 0
            self.fairwayRechargeProductsByID = Dictionary(
                uniqueKeysWithValues: response.products.map { ($0.productIdentifier, $0) }
            )

            if response.products.isEmpty {
                self.fairwayRechargeRetryFetch()
                return
            }

            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.fairwayRechargeIsRequesting = false
            self.fairwayRechargeRetryFetch()
        }
    }
}

extension FairwayRechargeStoreKitOneCenter: SKPaymentTransactionObserver {
    nonisolated func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for fairwayRechargeTransaction in transactions {
            switch fairwayRechargeTransaction.transactionState {
            case .purchased:
                DispatchQueue.main.async {
                    if TeeSparkAppStorage.teeSparkIsB {
                        self.fairwayRechargeFinishBPackagePurchase(fairwayRechargeTransaction)
                    } else {
                        self.fairwayRechargeFinishPurchase(
                            fairwayRechargeProductID: fairwayRechargeTransaction.payment.productIdentifier,
                            fairwayRechargeTransactionID: fairwayRechargeTransaction.transactionIdentifier
                        )
                        queue.finishTransaction(fairwayRechargeTransaction)
                    }
                }

            case .restored:
                DispatchQueue.main.async {
                    self.fairwayRechargeHandlePurchaseResult(
                        .cancelled,
                        productID: fairwayRechargeTransaction.payment.productIdentifier
                    )
                    self.fairwayRechargePurchasingProductID = nil
                }
                queue.finishTransaction(fairwayRechargeTransaction)

            case .failed:
                DispatchQueue.main.async {
                    if let fairwayRechargeError = fairwayRechargeTransaction.error as? SKError,
                       fairwayRechargeError.code == .paymentCancelled {
                        self.fairwayRechargeHandlePurchaseResult(
                            .cancelled,
                            productID: fairwayRechargeTransaction.payment.productIdentifier
                        )
                    } else {
                        self.fairwayRechargeHandlePurchaseResult(
                            .failed(message: fairwayRechargeTransaction.error?.localizedDescription ?? "Purchase failed"),
                            productID: fairwayRechargeTransaction.payment.productIdentifier
                        )
                    }
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                }
                queue.finishTransaction(fairwayRechargeTransaction)

            case .deferred:
                DispatchQueue.main.async {
                    self.fairwayRechargeHandlePurchaseResult(
                        .pending,
                        productID: fairwayRechargeTransaction.payment.productIdentifier
                    )
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                }

            case .purchasing:
                break

            @unknown default:
                break
            }
        }
    }
}

#Preview {
    FairwayRechargeStoreView {
    }
}
