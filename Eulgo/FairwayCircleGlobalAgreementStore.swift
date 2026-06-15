import Foundation

enum FairwayCircleGlobalAgreementStore {
    static let fairwayCircleUserAgreementAcceptedKey = "FairwayCircleGlobalAgreementStore.userAgreementAccepted"
    static let fairwayCircleEULAAgreementAcceptedKey = "FairwayCircleGlobalAgreementStore.eulaAgreementAccepted"

    static var fairwayCircleHasAcceptedUserAgreement: Bool {
        get {
            UserDefaults.standard.bool(forKey: fairwayCircleUserAgreementAcceptedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: fairwayCircleUserAgreementAcceptedKey)
        }
    }

    static var fairwayCircleHasAcceptedEULAAgreement: Bool {
        get {
            UserDefaults.standard.bool(forKey: fairwayCircleEULAAgreementAcceptedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: fairwayCircleEULAAgreementAcceptedKey)
        }
    }

    static func fairwayCircleResetAgreementState() {
        UserDefaults.standard.removeObject(forKey: fairwayCircleUserAgreementAcceptedKey)
        UserDefaults.standard.removeObject(forKey: fairwayCircleEULAAgreementAcceptedKey)
    }
}
