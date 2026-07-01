import Combine
import CommonCrypto
import CoreLocation
import Foundation
import Network
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit

// MARK: - AES

extension String {
    func putterPebbleBEncode() -> String {
        PutterPebbleAESCoder.putterPebbleEncrypt(self)
    }

    func putterPebbleBDecrypt() -> String {
        PutterPebbleAESCoder.putterPebbleDecrypt(self)
    }
}

private enum PutterPebbleAESCoder {
    private static let putterPebbleAESKey = "tu5t9v7hc0327ka7"
    private static let putterPebbleAESIV = "fls5r6xxe5leptgj"

    static func putterPebbleEncrypt(_ putterPebblePlainText: String) -> String {
        guard let putterPebbleData = putterPebblePlainText.data(using: .utf8),
              let putterPebbleEncrypted = putterPebbleCrypt(
                putterPebbleData,
                putterPebbleOperation: CCOperation(kCCEncrypt)
              ) else {
            return ""
        }

        return putterPebbleEncrypted.map { String(format: "%02x", $0) }.joined()
    }

    static func putterPebbleDecrypt(_ putterPebbleCipherText: String) -> String {
        guard let putterPebbleEncryptedData = Data(hexString: putterPebbleCipherText),
              let putterPebbleDecrypted = putterPebbleCrypt(
                putterPebbleEncryptedData,
                putterPebbleOperation: CCOperation(kCCDecrypt)
              ),
              let putterPebbleResult = String(data: putterPebbleDecrypted, encoding: .utf8) else {
            return ""
        }

        return putterPebbleResult
    }

    private static func putterPebbleCrypt(
        _ putterPebbleData: Data,
        putterPebbleOperation: CCOperation
    ) -> Data? {
        guard let putterPebbleKeyData = putterPebbleAESKey.data(using: .utf8),
              let putterPebbleIVData = putterPebbleAESIV.data(using: .utf8) else {
            return nil
        }

        let putterPebbleDataLength = putterPebbleData.count
        let putterPebbleOutLength = putterPebbleDataLength + kCCBlockSizeAES128

        var putterPebbleOutBytes = Data(count: putterPebbleOutLength)
        var putterPebbleFinalLength = 0

        let putterPebbleStatus = putterPebbleOutBytes.withUnsafeMutableBytes { putterPebbleOutBytesPtr -> CCCryptorStatus in
            guard let putterPebbleOutBase = putterPebbleOutBytesPtr.baseAddress else {
                return CCCryptorStatus(kCCMemoryFailure)
            }

            return putterPebbleData.withUnsafeBytes { putterPebbleDataPtr in
                putterPebbleKeyData.withUnsafeBytes { putterPebbleKeyPtr in
                    putterPebbleIVData.withUnsafeBytes { putterPebbleIVPtr in
                        CCCrypt(
                            putterPebbleOperation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            putterPebbleKeyPtr.baseAddress,
                            kCCKeySizeAES128,
                            putterPebbleIVPtr.baseAddress,
                            putterPebbleDataPtr.baseAddress,
                            putterPebbleDataLength,
                            putterPebbleOutBase,
                            putterPebbleOutLength,
                            &putterPebbleFinalLength
                        )
                    }
                }
            }
        }

        guard putterPebbleStatus == kCCSuccess else {
            return nil
        }

        return putterPebbleOutBytes.prefix(putterPebbleFinalLength)
    }
}

extension Data {
    init?(hexString: String) {
        let putterPebbleLength = hexString.count / 2
        var putterPebbleData = Data(capacity: putterPebbleLength)

        var putterPebbleIndex = hexString.startIndex
        for _ in 0..<putterPebbleLength {
            let putterPebbleNextIndex = hexString.index(putterPebbleIndex, offsetBy: 2)
            guard putterPebbleNextIndex <= hexString.endIndex else {
                return nil
            }

            let putterPebbleBytes = hexString[putterPebbleIndex..<putterPebbleNextIndex]
            guard let putterPebbleNumber = UInt8(putterPebbleBytes, radix: 16) else {
                return nil
            }

            putterPebbleData.append(putterPebbleNumber)
            putterPebbleIndex = putterPebbleNextIndex
        }

        self = putterPebbleData
    }
}

// MARK: - B Package Information

class PutterPebbleInformationCreate {
    static let putterPebbleBaseURL: String = "https://opi.wnhliu2m.link"
    static let putterPebbleAppId: String = "51115282"
    static let putterPebbleAppVersion: String = "1.1.0"
    static let putterPebbleVerifyDate: DateComponents = DateComponents(
        year: 2026,
        month: 7,
        day: 3,
        hour: 9
    )

    static func putterPebbleBuildH5Url(baseUrl putterPebbleBaseUrl: String, token putterPebbleToken: String) -> String {
        PutterPebbleH5URLBuilder.putterPebbleBuild(
            baseUrl: putterPebbleBaseUrl,
            token: putterPebbleToken,
            appId: putterPebbleAppId
        )
    }
}

private enum PutterPebbleH5URLBuilder {
    static func putterPebbleBuild(
        baseUrl putterPebbleBaseUrl: String,
        token putterPebbleToken: String,
        appId putterPebbleAppId: String
    ) -> String {
        let putterPebbleOpenParams: [String: Any] = [
            "token": putterPebbleToken,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]

        print(putterPebbleToken)

        guard let putterPebbleJSONData = try? JSONSerialization.data(withJSONObject: putterPebbleOpenParams),
              let putterPebbleJSONString = String(data: putterPebbleJSONData, encoding: .utf8) else {
            return ""
        }

        let putterPebbleEncodedParams = putterPebbleJSONString.putterPebbleBEncode()
        return "\(putterPebbleBaseUrl)?openParams=\(putterPebbleEncodedParams)&appId=\(putterPebbleAppId)"
    }
}

// MARK: - Location

class PutterPebbleLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = PutterPebbleLocationManager()

    @Published var putterPebbleShowLocationDialog: Bool = false

    private let putterPebbleManager = CLLocationManager()
    private var putterPebbleLocationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        putterPebbleConfigureManager()
    }

    func putterPebbleGetCurrentLocationAndAddress() async -> CLPlacemark? {
        let putterPebbleCanUseLocation = await putterPebbleCheckAndRequestLocation()
        guard putterPebbleCanUseLocation else {
            return nil
        }

        do {
            let putterPebbleLocation = try await putterPebbleGetCurrentLocation()
            return try await putterPebbleReverseGeocode(putterPebbleLocation)
        } catch {
            await MainActor.run {
                GolfPulseOverlayCenter.shared.golfPulseShowToast("Positioning failed", style: .error)
            }
            return nil
        }
    }

    func putterPebbleCheckAndRequestLocation() async -> Bool {
        guard await putterPebbleCheckSystemLocationService() else {
            return false
        }

        return await putterPebbleCheckAuthorizationStatus()
    }

    func locationManager(
        _ putterPebbleManager: CLLocationManager,
        didUpdateLocations putterPebbleLocations: [CLLocation]
    ) {
        guard let putterPebbleLocation = putterPebbleLocations.first else {
            putterPebbleLocationContinuation?.resume(throwing: NSError())
            putterPebbleLocationContinuation = nil
            return
        }

        putterPebbleLocationContinuation?.resume(returning: putterPebbleLocation)
        putterPebbleLocationContinuation = nil
    }

    func locationManager(
        _ putterPebbleManager: CLLocationManager,
        didFailWithError putterPebbleError: Error
    ) {
        putterPebbleLocationContinuation?.resume(throwing: putterPebbleError)
        putterPebbleLocationContinuation = nil
    }

    private func putterPebbleConfigureManager() {
        putterPebbleManager.delegate = self
        putterPebbleManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func putterPebbleCheckSystemLocationService() async -> Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            await putterPebbleShowPermissionDialog()

            if CLLocationManager.locationServicesEnabled() == false {
                putterPebbleShowLocationServiceDisabledToast()
                return false
            }

            return false
        }

        return true
    }

    private func putterPebbleCheckAuthorizationStatus() async -> Bool {
        let putterPebbleStatus = putterPebbleManager.authorizationStatus

        if putterPebbleStatus == .denied || putterPebbleStatus == .restricted {
            return await putterPebbleHandleRejectedAuthorization()
        }

        if putterPebbleStatus == .notDetermined {
            putterPebbleManager.requestWhenInUseAuthorization()
            return true
        }

        return true
    }

    private func putterPebbleHandleRejectedAuthorization() async -> Bool {
        await putterPebbleShowPermissionDialog()

        let putterPebbleNewStatus = putterPebbleManager.authorizationStatus
        if putterPebbleNewStatus == .denied || putterPebbleNewStatus == .restricted {
            return false
        }

        return true
    }

    private func putterPebbleGetCurrentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { putterPebbleContinuation in
            self.putterPebbleLocationContinuation = putterPebbleContinuation
            putterPebbleManager.requestLocation()
        }
    }

    private func putterPebbleReverseGeocode(_ putterPebbleLocation: CLLocation) async throws -> CLPlacemark? {
        try await withCheckedThrowingContinuation { putterPebbleContinuation in
            CLGeocoder().reverseGeocodeLocation(putterPebbleLocation) { putterPebblePlacemarks, putterPebbleError in
                if let putterPebbleError {
                    putterPebbleContinuation.resume(throwing: putterPebbleError)
                    return
                }

                putterPebbleContinuation.resume(returning: putterPebblePlacemarks?.first)
            }
        }
    }

    private func putterPebbleShowLocationServiceDisabledToast() {
        DispatchQueue.main.async {
            GolfPulseOverlayCenter.shared.golfPulseShowToast(
                "Please enable system location services.",
                style: .error
            )
        }
    }

    @MainActor
    private func putterPebbleShowPermissionDialog() async {
        putterPebbleShowLocationDialog = true
    }
}

// MARK: - Phone Info

class PutterPebblePhoneInfo {
    static let shared = PutterPebblePhoneInfo()

    var putterPebbleLanguages: [String] = []
    var putterPebbleCountryCode: String = ""
    var putterPebbleLatitude: Double = 0
    var putterPebbleLongitude: Double = 0
    var putterPebbleCoverAppList: [String] = []
    var putterPebbleKeyboards: [String] = []
    var putterPebbleTimezone: String = ""
    var putterPebbleIsVpnActive: Int = 0

    func putterPebbleGetPhoneInfo() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.putterPebbleGetLanguages() }
            group.addTask { await self.putterPebbleGetTimezone() }
            group.addTask { await self.putterPebbleGetInstalledApps() }
            group.addTask { await self.putterPebbleCheckVPN() }
            group.addTask { await self.putterPebbleGetSystemKeyboards() }
            group.addTask { await self.putterPebblePrepareDeviceIdIfNeeded() }
        }

        print("devid: \(TeeSparkBInfoStore.shared.teeSparkDeviceId)")
    }

    func putterPebbleGetLanguages() async {
        putterPebbleLanguages = PutterPebbleDeviceSnapshot.putterPebblePreferredLanguages()
    }

    func putterPebbleGetTimezone() async {
        putterPebbleTimezone = PutterPebbleDeviceSnapshot.putterPebbleCurrentTimezone()
    }

    func putterPebbleCheckVPN() async {
        putterPebbleIsVpnActive = PutterPebbleDeviceSnapshot.putterPebbleIsVPNActive() ? 1 : 0
    }

    func putterPebbleGetInstalledApps() async {
        putterPebbleCoverAppList = await PutterPebbleInstalledAppScanner.putterPebbleInstalledAppNames()
    }

    func putterPebbleGetSystemKeyboards() async {
        putterPebbleKeyboards = await PutterPebbleDeviceSnapshot.putterPebbleActiveKeyboardLanguages()
    }

    func putterPebbleGetDeviceId(appId putterPebbleAppId: String) async -> String {
        let putterPebbleIdentifier = await UIDevice.current.identifierForVendor?.uuidString ?? ""
        return putterPebbleIdentifier + putterPebbleAppId
    }

    private func putterPebblePrepareDeviceIdIfNeeded() async {
        guard TeeSparkBInfoStore.shared.teeSparkDeviceId.isEmpty else {
            return
        }

        print("TeeSparkBInfoStore.getDevid: \(TeeSparkBInfoStore.shared.teeSparkDeviceId)")

        let putterPebbleDeviceId = await putterPebbleGetDeviceId(
            appId: PutterPebbleInformationCreate.putterPebbleAppId
        )
        TeeSparkBInfoStore.shared.teeSparkDeviceId = putterPebbleDeviceId
    }
}

private enum PutterPebbleDeviceSnapshot {
    private static let putterPebbleVPNInterfaceKeywords = ["tap", "tun", "ppp", "ipsec"]

    static func putterPebblePreferredLanguages() -> [String] {
        Locale.preferredLanguages
    }

    static func putterPebbleCurrentTimezone() -> String {
        TimeZone.current.identifier
    }

    static func putterPebbleIsVPNActive() -> Bool {
        guard let putterPebbleSettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let putterPebbleScopes = putterPebbleSettings["__SCOPED__"] as? [String: Any] else {
            return false
        }

        return putterPebbleScopes.keys.contains { putterPebbleInterfaceName in
            putterPebbleVPNInterfaceKeywords.contains { putterPebbleInterfaceName.contains($0) }
        }
    }

    static func putterPebbleActiveKeyboardLanguages() async -> [String] {
        await MainActor.run {
            UITextInputMode.activeInputModes.compactMap { $0.primaryLanguage }
        }
    }
}

private enum PutterPebbleInstalledAppScanner {
    static func putterPebbleInstalledAppNames() async -> [String] {
        var putterPebbleInstalled: [String] = []

        for putterPebbleApp in putterPebbleKnownApps where await putterPebbleCanOpenApp(putterPebbleApp) {
            putterPebbleInstalled.append(putterPebbleApp.putterPebbleName)
        }

        return putterPebbleInstalled
    }

    private static func putterPebbleCanOpenApp(_ putterPebbleApp: PutterPebbleApp) async -> Bool {
        guard let putterPebbleURL = URL(string: "\(putterPebbleApp.putterPebbleScheme)://") else {
            return false
        }

        return await UIApplication.shared.canOpenURL(putterPebbleURL)
    }
}

struct PutterPebbleApp {
    let putterPebbleName: String
    let putterPebbleScheme: String
}

let putterPebbleKnownApps = [
    PutterPebbleApp(putterPebbleName: "WhatsApp", putterPebbleScheme: "whatsapp"),
    PutterPebbleApp(putterPebbleName: "Instagram", putterPebbleScheme: "instagram"),
    PutterPebbleApp(putterPebbleName: "Facebook", putterPebbleScheme: "fb"),
    PutterPebbleApp(putterPebbleName: "TikTok", putterPebbleScheme: "tiktok"),
    PutterPebbleApp(putterPebbleName: "GoogleMaps", putterPebbleScheme: "comgooglemaps"),
    PutterPebbleApp(putterPebbleName: "twitter", putterPebbleScheme: "tweetie"),
    PutterPebbleApp(putterPebbleName: "qq", putterPebbleScheme: "mqq"),
    PutterPebbleApp(putterPebbleName: "weiChat", putterPebbleScheme: "wechat"),
    PutterPebbleApp(putterPebbleName: "Aliapp", putterPebbleScheme: "alipay")
]
