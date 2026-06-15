import Combine
@preconcurrency import StoreKit
import SwiftUI

struct FairwayRechargeStoreView: View {
    @StateObject private var fairwayRechargeStoreKit = FairwayRechargeStoreKitOneCenter.fairwayRechargeShared
    @State private var fairwayRechargeRefreshToken = UUID()
    @State private var fairwayRechargeShowsGuestRestriction = false

    let fairwayRechargeBackAction: () -> Void

    private let fairwayRechargePackages = [
        FairwayRechargePackage(fairwayRechargeProductID: "hjemjplmfvpczhni", fairwayRechargeCoins: 400, fairwayRechargePrice: "$ 0.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "rucxhrziqvvkvjaw", fairwayRechargeCoins: 800, fairwayRechargePrice: "$ 1.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "qgxlpyilxrboxtxa", fairwayRechargeCoins: 2450, fairwayRechargePrice: "$ 4.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "mxtqvhalrjknpsuz", fairwayRechargeCoins: 3420, fairwayRechargePrice: "$ 6.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "dqnhyfgkmkmwwoym", fairwayRechargeCoins: 5150, fairwayRechargePrice: "$ 9.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "cewbnfykdtrahqol", fairwayRechargeCoins: 9300, fairwayRechargePrice: "$ 18.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "pjmqdhetikzpbwti", fairwayRechargeCoins: 10800, fairwayRechargePrice: "$ 19.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "wcmmyihzzdpqnnja", fairwayRechargeCoins: 29400, fairwayRechargePrice: "$ 49.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "pjsnrvkzuhmaxqte", fairwayRechargeCoins: 34200, fairwayRechargePrice: "$ 69.99"),
        FairwayRechargePackage(fairwayRechargeProductID: "kyfpzzpdrforcfwz", fairwayRechargeCoins: 63700, fairwayRechargePrice: "$ 99.99")
    ]

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

private struct FairwayRechargePackage: Identifiable {
    let fairwayRechargeProductID: String?
    let fairwayRechargeCoins: Int
    let fairwayRechargePrice: String

    var id: String { fairwayRechargeProductID ?? "fairway-recharge-fixed-\(fairwayRechargeCoins)" }
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

private final class FairwayRechargeStoreKitOneCenter: NSObject, ObservableObject {
    static let fairwayRechargeShared = FairwayRechargeStoreKitOneCenter()

    @Published var fairwayRechargeProductsByID: [String: SKProduct] = [:]
    @Published var fairwayRechargePurchasingProductID: String?

    private var fairwayRechargeProductsRequest: SKProductsRequest?
    private var fairwayRechargePackagesByProductID: [String: FairwayRechargePackage] = [:]
    private var fairwayRechargeSuccessAction: (() -> Void)?
    private var fairwayRechargeFinishedTransactionIDs: Set<String> = []

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
        let fairwayRechargeValidPackages = fairwayRechargePackages.filter { $0.fairwayRechargeProductID != nil }
        fairwayRechargePackagesByProductID = Dictionary(
            uniqueKeysWithValues: fairwayRechargeValidPackages.compactMap { fairwayRechargePackage in
                guard let fairwayRechargeProductID = fairwayRechargePackage.fairwayRechargeProductID else {
                    return nil
                }

                return (fairwayRechargeProductID, fairwayRechargePackage)
            }
        )

        let fairwayRechargeProductIDs = Set(fairwayRechargePackagesByProductID.keys)
        guard fairwayRechargeProductIDs.isEmpty == false else {
            if fairwayRechargeIsInitialConfiguration {
                GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            }
            return
        }

        fairwayRechargeProductsRequest?.cancel()
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

        guard let fairwayRechargeProductID = fairwayRechargePackage.fairwayRechargeProductID else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Product unavailable", style: .error)
            return
        }

        guard let fairwayRechargeProduct = fairwayRechargeProductsByID[fairwayRechargeProductID] else {
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Product is loading", style: .normal)
            fairwayRechargeLoadProducts(Array(fairwayRechargePackagesByProductID.values))
            return
        }

        self.fairwayRechargeSuccessAction = fairwayRechargeSuccessAction
        fairwayRechargePurchasingProductID = fairwayRechargeProductID
        GolfPulseOverlayCenter.shared.golfPulseShowLoading()
        SKPaymentQueue.default().add(SKPayment(product: fairwayRechargeProduct))
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

        guard let fairwayRechargePackage = fairwayRechargePackagesByProductID[fairwayRechargeProductID],
              var fairwayRechargeUser = PlayerBadgeSessionStore.playerBadgeReadLoginUser() else {
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            return
        }

        fairwayRechargeUser.teeBoxCoinCount += fairwayRechargePackage.fairwayRechargeCoins
        _ = TeeBoxUserStore.teeBoxUpdateUser(fairwayRechargeUser)
        GolfPulseOverlayCenter.shared.golfPulseHideLoading()
        GolfPulseOverlayCenter.shared.golfPulseShowToast("Recharge successful", style: .success)
        fairwayRechargeSuccessAction?()
    }
}

extension FairwayRechargeStoreKitOneCenter: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.fairwayRechargeProductsByID = Dictionary(
                uniqueKeysWithValues: response.products.map { ($0.productIdentifier, $0) }
            )
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            GolfPulseOverlayCenter.shared.golfPulseHideLoading()
            GolfPulseOverlayCenter.shared.golfPulseShowToast("Products load failed", style: .error)
        }
    }
}

extension FairwayRechargeStoreKitOneCenter: SKPaymentTransactionObserver {
    nonisolated func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for fairwayRechargeTransaction in transactions {
            switch fairwayRechargeTransaction.transactionState {
            case .purchased, .restored:
                DispatchQueue.main.async {
                    self.fairwayRechargeFinishPurchase(
                        fairwayRechargeProductID: fairwayRechargeTransaction.payment.productIdentifier,
                        fairwayRechargeTransactionID: fairwayRechargeTransaction.transactionIdentifier
                    )
                    self.fairwayRechargePurchasingProductID = nil
                }
                queue.finishTransaction(fairwayRechargeTransaction)

            case .failed:
                DispatchQueue.main.async {
                    if let fairwayRechargeError = fairwayRechargeTransaction.error as? SKError,
                       fairwayRechargeError.code != .paymentCancelled {
                        GolfPulseOverlayCenter.shared.golfPulseShowToast("Purchase failed", style: .error)
                    }
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                    self.fairwayRechargePurchasingProductID = nil
                }
                queue.finishTransaction(fairwayRechargeTransaction)

            case .deferred:
                DispatchQueue.main.async {
                    GolfPulseOverlayCenter.shared.golfPulseShowToast("Purchase pending", style: .normal)
                    GolfPulseOverlayCenter.shared.golfPulseHideLoading()
                    self.fairwayRechargePurchasingProductID = nil
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
