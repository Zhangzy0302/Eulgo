import Foundation

struct GreenNoteCommentModel: Identifiable, Codable, Equatable {
    let greenNoteCommentID: String
    var greenNoteVideoID: String
    var greenNotePublisherID: String
    var greenNoteContentText: String
    var greenNoteCreatedAt: Date

    var id: String { greenNoteCommentID }

    init(
        greenNoteCommentID: String = UUID().uuidString,
        greenNoteVideoID: String,
        greenNotePublisherID: String,
        greenNoteContentText: String,
        greenNoteCreatedAt: Date = Date()
    ) {
        self.greenNoteCommentID = greenNoteCommentID
        self.greenNoteVideoID = greenNoteVideoID
        self.greenNotePublisherID = greenNotePublisherID
        self.greenNoteContentText = greenNoteContentText
        self.greenNoteCreatedAt = greenNoteCreatedAt
    }
}

enum GreenNoteCommentStore {
    private static let greenNoteStorageKey = "eulgo.local.greenNote.comments"

    static func greenNoteReadAllComments() -> [GreenNoteCommentModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(GreenNoteCommentModel.self, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteReadComment(greenNoteCommentID: String) -> GreenNoteCommentModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: greenNoteCommentID, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteReadComments(greenNoteVideoID: String) -> [GreenNoteCommentModel] {
        greenNoteReadAllComments()
            .filter { $0.greenNoteVideoID == greenNoteVideoID }
            .sorted { $0.greenNoteCreatedAt < $1.greenNoteCreatedAt }
    }

    static func greenNoteCreateComment(_ greenNoteComment: GreenNoteCommentModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(greenNoteComment, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteUpdateComment(_ greenNoteComment: GreenNoteCommentModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(greenNoteComment, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteUpsertComment(_ greenNoteComment: GreenNoteCommentModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(greenNoteComment, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteDeleteComment(greenNoteCommentID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(GreenNoteCommentModel.self, caddieVaultID: greenNoteCommentID, caddieVaultKey: greenNoteStorageKey)
    }

    static func greenNoteDeleteAllComments() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: greenNoteStorageKey)
    }
}
