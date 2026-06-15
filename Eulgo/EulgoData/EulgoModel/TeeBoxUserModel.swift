import Foundation

struct TeeBoxUserModel: Identifiable, Codable, Equatable {
    let teeBoxUserID: String
    var teeBoxEmail: String
    var teeBoxPassword: String
    var teeBoxAvatarAddress: String
    var teeBoxUsername: String
    var teeBoxBirthdayDate: Date
    var teeBoxLocation: String
    var teeBoxGender: String
    var teeBoxFollowerIDs: [String]
    var teeBoxFollowingIDs: [String]
    var teeBoxBlockedUserIDs: [String]
    var teeBoxPurchasedTutorialIDs: [String]
    var teeBoxLikedPostIDs: [String]
    var teeBoxLikedVenueIDs: [String]
    var teeBoxCoinCount: Int
    var teeBoxIsGuest: Bool

    var id: String { teeBoxUserID }

    init(
        teeBoxUserID: String = UUID().uuidString,
        teeBoxEmail: String,
        teeBoxPassword: String,
        teeBoxAvatarAddress: String = "",
        teeBoxUsername: String,
        teeBoxBirthdayDate: Date,
        teeBoxLocation: String,
        teeBoxGender: String,
        teeBoxFollowerIDs: [String] = [],
        teeBoxFollowingIDs: [String] = [],
        teeBoxBlockedUserIDs: [String] = [],
        teeBoxPurchasedTutorialIDs: [String] = [],
        teeBoxLikedPostIDs: [String] = [],
        teeBoxLikedVenueIDs: [String] = [],
        teeBoxCoinCount: Int = 0,
        teeBoxIsGuest: Bool = false
    ) {
        self.teeBoxUserID = teeBoxUserID
        self.teeBoxEmail = teeBoxEmail
        self.teeBoxPassword = teeBoxPassword
        self.teeBoxAvatarAddress = teeBoxAvatarAddress
        self.teeBoxUsername = teeBoxUsername
        self.teeBoxBirthdayDate = teeBoxBirthdayDate
        self.teeBoxLocation = teeBoxLocation
        self.teeBoxGender = teeBoxGender
        self.teeBoxFollowerIDs = teeBoxFollowerIDs
        self.teeBoxFollowingIDs = teeBoxFollowingIDs
        self.teeBoxBlockedUserIDs = teeBoxBlockedUserIDs
        self.teeBoxPurchasedTutorialIDs = teeBoxPurchasedTutorialIDs
        self.teeBoxLikedPostIDs = teeBoxLikedPostIDs
        self.teeBoxLikedVenueIDs = teeBoxLikedVenueIDs
        self.teeBoxCoinCount = teeBoxCoinCount
        self.teeBoxIsGuest = teeBoxIsGuest
    }

    enum CodingKeys: String, CodingKey {
        case teeBoxUserID
        case teeBoxEmail
        case teeBoxPassword
        case teeBoxAvatarAddress
        case teeBoxUsername
        case teeBoxBirthdayDate
        case teeBoxLocation
        case teeBoxGender
        case teeBoxFollowerIDs
        case teeBoxFollowingIDs
        case teeBoxBlockedUserIDs
        case teeBoxPurchasedTutorialIDs
        case teeBoxLikedPostIDs
        case teeBoxLikedVenueIDs
        case teeBoxCoinCount
        case teeBoxIsGuest
    }

    init(from decoder: Decoder) throws {
        let teeBoxContainer = try decoder.container(keyedBy: CodingKeys.self)

        teeBoxUserID = try teeBoxContainer.decode(String.self, forKey: .teeBoxUserID)
        teeBoxEmail = try teeBoxContainer.decode(String.self, forKey: .teeBoxEmail)
        teeBoxPassword = try teeBoxContainer.decode(String.self, forKey: .teeBoxPassword)
        teeBoxAvatarAddress = try teeBoxContainer.decodeIfPresent(String.self, forKey: .teeBoxAvatarAddress) ?? ""
        teeBoxUsername = try teeBoxContainer.decode(String.self, forKey: .teeBoxUsername)
        teeBoxBirthdayDate = try teeBoxContainer.decode(Date.self, forKey: .teeBoxBirthdayDate)
        teeBoxLocation = try teeBoxContainer.decode(String.self, forKey: .teeBoxLocation)
        teeBoxGender = try teeBoxContainer.decode(String.self, forKey: .teeBoxGender)
        teeBoxFollowerIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxFollowerIDs) ?? []
        teeBoxFollowingIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxFollowingIDs) ?? []
        teeBoxBlockedUserIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxBlockedUserIDs) ?? []
        teeBoxPurchasedTutorialIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxPurchasedTutorialIDs) ?? []
        teeBoxLikedPostIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxLikedPostIDs) ?? []
        teeBoxLikedVenueIDs = try teeBoxContainer.decodeIfPresent([String].self, forKey: .teeBoxLikedVenueIDs) ?? []
        teeBoxCoinCount = try teeBoxContainer.decodeIfPresent(Int.self, forKey: .teeBoxCoinCount) ?? 0
        teeBoxIsGuest = try teeBoxContainer.decodeIfPresent(Bool.self, forKey: .teeBoxIsGuest) ?? false
    }
}

enum TeeBoxUserStore {
    private static let teeBoxStorageKey = "eulgo.local.teeBox.users"

    static func teeBoxReadAllUsers() -> [TeeBoxUserModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(TeeBoxUserModel.self, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxReadUser(teeBoxUserID: String) -> TeeBoxUserModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: teeBoxUserID, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxReadUser(teeBoxEmail: String) -> TeeBoxUserModel? {
        let teeBoxNormalizedEmail = teeBoxEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return teeBoxReadAllUsers()
            .first { $0.teeBoxEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == teeBoxNormalizedEmail }
    }

    static func teeBoxCreateUser(_ teeBoxUser: TeeBoxUserModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(teeBoxUser, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxUpdateUser(_ teeBoxUser: TeeBoxUserModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(teeBoxUser, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxUpsertUser(_ teeBoxUser: TeeBoxUserModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(teeBoxUser, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxDeleteUser(teeBoxUserID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(TeeBoxUserModel.self, caddieVaultID: teeBoxUserID, caddieVaultKey: teeBoxStorageKey)
    }

    static func teeBoxDeleteAllUsers() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: teeBoxStorageKey)
    }
}
