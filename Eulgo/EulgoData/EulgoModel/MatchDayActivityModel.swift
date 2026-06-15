import Foundation

struct MatchDayActivityModel: Identifiable, Codable, Equatable {
    let matchDayActivityID: String
    var matchDayPublisherID: String
    var matchDayActivityName: String
    var matchDayCoverAddress: String
    var matchDayIntroductionText: String
    var matchDayDate: Date
    var matchDayDurationText: String
    var matchDayLocation: String
    var matchDayParticipantUserIDs: [String]

    var id: String { matchDayActivityID }

    init(
        matchDayActivityID: String = UUID().uuidString,
        matchDayPublisherID: String,
        matchDayActivityName: String,
        matchDayCoverAddress: String,
        matchDayIntroductionText: String,
        matchDayDate: Date,
        matchDayDurationText: String,
        matchDayLocation: String,
        matchDayParticipantUserIDs: [String] = []
    ) {
        self.matchDayActivityID = matchDayActivityID
        self.matchDayPublisherID = matchDayPublisherID
        self.matchDayActivityName = matchDayActivityName
        self.matchDayCoverAddress = matchDayCoverAddress
        self.matchDayIntroductionText = matchDayIntroductionText
        self.matchDayDate = matchDayDate
        self.matchDayDurationText = matchDayDurationText
        self.matchDayLocation = matchDayLocation
        self.matchDayParticipantUserIDs = matchDayParticipantUserIDs
    }
}

enum MatchDayActivityStore {
    private static let matchDayStorageKey = "eulgo.local.matchDay.activities"

    static func matchDayReadAllActivities() -> [MatchDayActivityModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(MatchDayActivityModel.self, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayReadActivity(matchDayActivityID: String) -> MatchDayActivityModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: matchDayActivityID, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayCreateActivity(_ matchDayActivity: MatchDayActivityModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(matchDayActivity, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayUpdateActivity(_ matchDayActivity: MatchDayActivityModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(matchDayActivity, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayUpsertActivity(_ matchDayActivity: MatchDayActivityModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(matchDayActivity, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayDeleteActivity(matchDayActivityID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(MatchDayActivityModel.self, caddieVaultID: matchDayActivityID, caddieVaultKey: matchDayStorageKey)
    }

    static func matchDayDeleteAllActivities() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: matchDayStorageKey)
    }
}
