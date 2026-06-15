import Foundation

enum PlayerBadgeSessionStore {
    private static let playerBadgeCurrentUserIDKey = "eulgo.local.playerBadge.currentUserID"
    static let playerBadgeSessionDidChangeNotification = Notification.Name("eulgo.local.playerBadge.sessionDidChange")

    static var playerBadgeCurrentUserID: String? {
        get {
            UserDefaults.standard.string(forKey: playerBadgeCurrentUserIDKey)
        }
        set {
            let playerBadgeTrimmedUserID = newValue?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let playerBadgeTrimmedUserID, playerBadgeTrimmedUserID.isEmpty == false {
                UserDefaults.standard.set(playerBadgeTrimmedUserID, forKey: playerBadgeCurrentUserIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: playerBadgeCurrentUserIDKey)
            }
        }
    }

    static var playerBadgeIsLoggedIn: Bool {
        playerBadgeCurrentUserID != nil
    }

    static func playerBadgeSaveLoginUserID(_ playerBadgeUserID: String) {
        playerBadgeCurrentUserID = playerBadgeUserID
        NotificationCenter.default.post(name: playerBadgeSessionDidChangeNotification, object: nil)
    }

    static func playerBadgeReadLoginUser() -> TeeBoxUserModel? {
        guard let playerBadgeCurrentUserID else {
            return nil
        }

        return TeeBoxUserStore.teeBoxReadUser(teeBoxUserID: playerBadgeCurrentUserID)
    }

    static func playerBadgeClearLoginUser() {
        playerBadgeCurrentUserID = nil
        NotificationCenter.default.post(name: playerBadgeSessionDidChangeNotification, object: nil)
    }
}
