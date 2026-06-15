import Foundation

struct WhisperLineChatMessageModel: Identifiable, Codable, Equatable {
    let whisperLineMessageID: String
    var whisperLineRoomID: String
    var whisperLineSenderID: String
    var whisperLineTextMessage: String
    var whisperLineVoiceMessageAddress: String
    var whisperLineVoiceDuration: TimeInterval
    var whisperLineSentAt: Date

    var id: String { whisperLineMessageID }

    init(
        whisperLineMessageID: String = UUID().uuidString,
        whisperLineRoomID: String,
        whisperLineSenderID: String,
        whisperLineTextMessage: String = "",
        whisperLineVoiceMessageAddress: String = "",
        whisperLineVoiceDuration: TimeInterval = 0,
        whisperLineSentAt: Date = Date()
    ) {
        self.whisperLineMessageID = whisperLineMessageID
        self.whisperLineRoomID = whisperLineRoomID
        self.whisperLineSenderID = whisperLineSenderID
        self.whisperLineTextMessage = whisperLineTextMessage
        self.whisperLineVoiceMessageAddress = whisperLineVoiceMessageAddress
        self.whisperLineVoiceDuration = whisperLineVoiceDuration
        self.whisperLineSentAt = whisperLineSentAt
    }
}

enum WhisperLineChatMessageStore {
    private static let whisperLineStorageKey = "eulgo.local.whisperLine.chatMessages"

    static func whisperLineReadAllMessages() -> [WhisperLineChatMessageModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(WhisperLineChatMessageModel.self, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineReadMessage(whisperLineMessageID: String) -> WhisperLineChatMessageModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: whisperLineMessageID, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineReadMessages(whisperLineRoomID: String) -> [WhisperLineChatMessageModel] {
        whisperLineReadAllMessages()
            .filter { $0.whisperLineRoomID == whisperLineRoomID }
            .sorted { $0.whisperLineSentAt < $1.whisperLineSentAt }
    }

    static func whisperLineCreateMessage(_ whisperLineMessage: WhisperLineChatMessageModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(whisperLineMessage, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineUpdateMessage(_ whisperLineMessage: WhisperLineChatMessageModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(whisperLineMessage, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineUpsertMessage(_ whisperLineMessage: WhisperLineChatMessageModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(whisperLineMessage, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineDeleteMessage(whisperLineMessageID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(WhisperLineChatMessageModel.self, caddieVaultID: whisperLineMessageID, caddieVaultKey: whisperLineStorageKey)
    }

    static func whisperLineDeleteAllMessages() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: whisperLineStorageKey)
    }
}
