
import Foundation
import Security

// MARK: - Secure Keys

enum TeeSparkSecureKey {
    case teeSparkDeviceId
    case teeSparkPassword

    var teeSparkKey: String {
        switch self {
        case .teeSparkDeviceId:
            return "teeSparkDeviceId2"
        case .teeSparkPassword:
            return "teeSparkPassword2"
        }
    }
}

// MARK: - Keychain Store

final class TeeSparkBInfoStore {

    static let shared = TeeSparkBInfoStore()

    private init() {}

    var teeSparkDeviceId: String {
        get { teeSparkReadSecureValue(.teeSparkDeviceId) ?? "" }
        set { _ = teeSparkSaveSecureValue(newValue, for: .teeSparkDeviceId) }
    }

    var teeSparkPassword: String {
        get { teeSparkReadSecureValue(.teeSparkPassword) ?? "" }
        set { _ = teeSparkSaveSecureValue(newValue, for: .teeSparkPassword) }
    }

    private func teeSparkSaveSecureValue(_ teeSparkValue: String, for teeSparkKey: TeeSparkSecureKey) -> Bool {
        guard let teeSparkData = teeSparkValue.data(using: .utf8) else {
            return false
        }

        teeSparkDeleteSecureValue(teeSparkKey)

        var teeSparkQuery = teeSparkBaseSecureQuery(for: teeSparkKey)
        teeSparkQuery[kSecValueData as String] = teeSparkData
        teeSparkQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        return SecItemAdd(teeSparkQuery as CFDictionary, nil) == errSecSuccess
    }

    private func teeSparkReadSecureValue(_ teeSparkKey: TeeSparkSecureKey) -> String? {
        var teeSparkQuery = teeSparkBaseSecureQuery(for: teeSparkKey)
        teeSparkQuery[kSecReturnData as String] = true
        teeSparkQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var teeSparkResult: AnyObject?
        let teeSparkStatus = SecItemCopyMatching(teeSparkQuery as CFDictionary, &teeSparkResult)

        guard
            teeSparkStatus == errSecSuccess,
            let teeSparkData = teeSparkResult as? Data
        else {
            return nil
        }

        return String(data: teeSparkData, encoding: .utf8)
    }

    private func teeSparkDeleteSecureValue(_ teeSparkKey: TeeSparkSecureKey) {
        let teeSparkQuery = teeSparkBaseSecureQuery(for: teeSparkKey)
        SecItemDelete(teeSparkQuery as CFDictionary)
    }

    private func teeSparkBaseSecureQuery(for teeSparkKey: TeeSparkSecureKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: teeSparkKey.teeSparkKey
        ]
    }
}

// MARK: - App Storage Keys

enum TeeSparkAppStorageKey {
    static let teeSparkIsB = "teeSparkIsB"
    static let teeSparkPushToken = "teeSparkPushToken"
    static let teeSparkH5Url = "teeSparkH5Url"
    static let teeSparkUserToken = "teeSparkUserToken"
}

// MARK: - UserDefaults Store

final class TeeSparkAppStorage {

    private static let teeSparkDefaults = UserDefaults.standard

    static var teeSparkIsB: Bool {
        get { teeSparkDefaults.bool(forKey: TeeSparkAppStorageKey.teeSparkIsB) }
        set { teeSparkDefaults.set(newValue, forKey: TeeSparkAppStorageKey.teeSparkIsB) }
    }

    static var teeSparkUserToken: String {
        get { teeSparkStringValue(for: TeeSparkAppStorageKey.teeSparkUserToken) }
        set { teeSparkDefaults.set(newValue, forKey: TeeSparkAppStorageKey.teeSparkUserToken) }
    }

    static var teeSparkPushToken: String {
        get { teeSparkStringValue(for: TeeSparkAppStorageKey.teeSparkPushToken) }
        set { teeSparkDefaults.set(newValue, forKey: TeeSparkAppStorageKey.teeSparkPushToken) }
    }

    static var teeSparkH5Url: String {
        get { teeSparkStringValue(for: TeeSparkAppStorageKey.teeSparkH5Url) }
        set { teeSparkDefaults.set(newValue, forKey: TeeSparkAppStorageKey.teeSparkH5Url) }
    }

    private static func teeSparkStringValue(for teeSparkKey: String) -> String {
        teeSparkDefaults.string(forKey: teeSparkKey) ?? ""
    }
}

var teeSparkUsersOrderCode: String = ""
