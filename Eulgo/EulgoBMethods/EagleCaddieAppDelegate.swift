
import UIKit
import UserNotifications
import FBSDKCoreKit
import AdjustSdk

final class EagleCaddieAdjustManager: NSObject, AdjustDelegate {
    static let shared = EagleCaddieAdjustManager()

    private let eagleCaddieInstallToken = "xgvl0k"
    private let eagleCaddiePurchaseToken = "u8q48u"
    private let eagleCaddieAppToken = "saq4szjwn18g"
    private var eagleCaddieDidStartInitialization = false
    private var eagleCaddieDidInitialize = false

    private override init() {}

    func eagleCaddieStartLaunchInitialization() {
        guard !eagleCaddieDidStartInitialization else {
            return
        }

        eagleCaddieDidStartInitialization = true

        Task { @MainActor in
            await PutterPebblePhoneInfo.shared.putterPebbleGetPhoneInfo()
            EagleCaddieAdjustManager.shared.eagleCaddieInitialize()
        }
    }

    func eagleCaddieInitialize() {
        guard !eagleCaddieDidInitialize else {
            return
        }

        guard let eagleCaddieAdjustConfig = ADJConfig(
            appToken: eagleCaddieAppToken,
            environment: ADJEnvironmentProduction
        ) else {
            return
        }

        eagleCaddieAdjustConfig.logLevel = ADJLogLevel.verbose
        eagleCaddieAdjustConfig.enableSendingInBackground()
        eagleCaddieAdjustConfig.delegate = self

        print("ta_distinct_id: \(TeeSparkBInfoStore.shared.teeSparkDeviceId)")

        Adjust.addGlobalCallbackParameter(
            TeeSparkBInfoStore.shared.teeSparkDeviceId,
            forKey: "ta_distinct_id"
        )

        Adjust.attribution { [weak self] eagleCaddieAttribution in
            self?.adjustAttributionChanged(eagleCaddieAttribution)
        }

        Adjust.initSdk(eagleCaddieAdjustConfig)
        eagleCaddieDidInitialize = true
    }

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let eagleCaddieInstallEvent = ADJEvent(eventToken: eagleCaddieInstallToken)
        Adjust.trackEvent(eagleCaddieInstallEvent)
    }

    func eagleCaddieTrackPurchase(dollar: Double) {
        let eagleCaddiePurchaseEvent = ADJEvent(eventToken: eagleCaddiePurchaseToken)
        eagleCaddiePurchaseEvent?.setRevenue(dollar, currency: "USD")
        Adjust.trackEvent(eagleCaddiePurchaseEvent)
        // fb
        eagleCaddieTrackFacebookPurchase(price: dollar)
    }

    private func eagleCaddieTrackFacebookPurchase(price eagleCaddiePrice: Double) {
        AppEvents.shared.logPurchase(
            amount: eagleCaddiePrice,
            currency: "USD",
            parameters: [
                AppEvents.ParameterName(rawValue: "fb_mobile_purchase"): "true"
            ]
        )
    }
}

class EagleCaddieAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        EagleCaddieAdjustManager.shared.eagleCaddieStartLaunchInitialization()
        eagleCaddieRegisterPush(application)

        return true
    }

    private func eagleCaddieRegisterPush(_ application: UIApplication) {

        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let eagleCaddiePushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // 保存
        TeeSparkAppStorage.teeSparkPushToken = eagleCaddiePushToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Push 注册失败:", error)
    }
}
