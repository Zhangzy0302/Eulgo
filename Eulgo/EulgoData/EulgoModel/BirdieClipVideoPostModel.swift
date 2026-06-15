import Foundation

struct BirdieClipVideoPostModel: Identifiable, Codable, Equatable {
    let birdieClipPostID: String
    var birdieClipPublisherID: String
    var birdieClipCoverAddress: String
    var birdieClipVideoAddress: String
    var birdieClipCaptionText: String
    var birdieClipLikeCount: Int

    var id: String { birdieClipPostID }

    init(
        birdieClipPostID: String = UUID().uuidString,
        birdieClipPublisherID: String,
        birdieClipCoverAddress: String,
        birdieClipVideoAddress: String,
        birdieClipCaptionText: String,
        birdieClipLikeCount: Int = 0
    ) {
        self.birdieClipPostID = birdieClipPostID
        self.birdieClipPublisherID = birdieClipPublisherID
        self.birdieClipCoverAddress = birdieClipCoverAddress
        self.birdieClipVideoAddress = birdieClipVideoAddress
        self.birdieClipCaptionText = birdieClipCaptionText
        self.birdieClipLikeCount = birdieClipLikeCount
    }
}

enum BirdieClipVideoPostStore {
    private static let birdieClipStorageKey = "eulgo.local.birdieClip.videoPosts"

    static func birdieClipReadAllPosts() -> [BirdieClipVideoPostModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(BirdieClipVideoPostModel.self, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipReadPost(birdieClipPostID: String) -> BirdieClipVideoPostModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: birdieClipPostID, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipCreatePost(_ birdieClipPost: BirdieClipVideoPostModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(birdieClipPost, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipUpdatePost(_ birdieClipPost: BirdieClipVideoPostModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(birdieClipPost, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipUpsertPost(_ birdieClipPost: BirdieClipVideoPostModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(birdieClipPost, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipDeletePost(birdieClipPostID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(BirdieClipVideoPostModel.self, caddieVaultID: birdieClipPostID, caddieVaultKey: birdieClipStorageKey)
    }

    static func birdieClipDeleteAllPosts() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: birdieClipStorageKey)
    }
}
