import Foundation

struct ClubPairChatRoomModel: Identifiable, Codable, Equatable {
    let clubPairRoomID: String
    var clubPairUserIDs: [String]
    var clubPairLastMessageSentAt: Date
    var clubPairLastSenderID: String
    var clubPairLastMessageText: String
    var clubPairUnreadMessageCount: Int

    var id: String { clubPairRoomID }

    init(
        clubPairRoomID: String = UUID().uuidString,
        clubPairUserIDs: [String],
        clubPairLastMessageSentAt: Date = Date(),
        clubPairLastSenderID: String = "",
        clubPairLastMessageText: String = "",
        clubPairUnreadMessageCount: Int = 0
    ) {
        self.clubPairRoomID = clubPairRoomID
        self.clubPairUserIDs = clubPairUserIDs
        self.clubPairLastMessageSentAt = clubPairLastMessageSentAt
        self.clubPairLastSenderID = clubPairLastSenderID
        self.clubPairLastMessageText = clubPairLastMessageText
        self.clubPairUnreadMessageCount = clubPairUnreadMessageCount
    }
}

enum ClubPairChatRoomStore {
    private static let clubPairStorageKey = "eulgo.local.clubPair.chatRooms"

    static func clubPairReadAllRooms() -> [ClubPairChatRoomModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(ClubPairChatRoomModel.self, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairReadRoom(clubPairRoomID: String) -> ClubPairChatRoomModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: clubPairRoomID, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairReadRooms(clubPairUserID: String) -> [ClubPairChatRoomModel] {
        clubPairReadAllRooms()
            .filter { $0.clubPairUserIDs.contains(clubPairUserID) }
            .sorted { $0.clubPairLastMessageSentAt > $1.clubPairLastMessageSentAt }
    }

    static func clubPairCreateRoom(_ clubPairRoom: ClubPairChatRoomModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(clubPairRoom, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairUpdateRoom(_ clubPairRoom: ClubPairChatRoomModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(clubPairRoom, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairUpsertRoom(_ clubPairRoom: ClubPairChatRoomModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(clubPairRoom, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairDeleteRoom(clubPairRoomID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(ClubPairChatRoomModel.self, caddieVaultID: clubPairRoomID, caddieVaultKey: clubPairStorageKey)
    }

    static func clubPairDeleteAllRooms() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: clubPairStorageKey)
    }
}
