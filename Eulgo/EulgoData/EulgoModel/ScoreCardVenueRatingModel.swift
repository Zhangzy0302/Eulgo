import Foundation

struct ScoreCardVenueRatingModel: Identifiable, Codable, Equatable {
    let scoreCardRatingID: String
    var scoreCardVenueID: String
    var scoreCardUserID: String
    var scoreCardFacilitiesScore: Int {
        didSet {
            scoreCardFacilitiesScore = Self.scoreCardClampedScore(scoreCardFacilitiesScore)
        }
    }
    var scoreCardServiceScore: Int {
        didSet {
            scoreCardServiceScore = Self.scoreCardClampedScore(scoreCardServiceScore)
        }
    }
    var scoreCardOverallScore: Int {
        didSet {
            scoreCardOverallScore = Self.scoreCardClampedScore(scoreCardOverallScore)
        }
    }

    var id: String { scoreCardRatingID }

    init(
        scoreCardRatingID: String = UUID().uuidString,
        scoreCardVenueID: String,
        scoreCardUserID: String,
        scoreCardFacilitiesScore: Int,
        scoreCardServiceScore: Int,
        scoreCardOverallScore: Int
    ) {
        self.scoreCardRatingID = scoreCardRatingID
        self.scoreCardVenueID = scoreCardVenueID
        self.scoreCardUserID = scoreCardUserID
        self.scoreCardFacilitiesScore = Self.scoreCardClampedScore(scoreCardFacilitiesScore)
        self.scoreCardServiceScore = Self.scoreCardClampedScore(scoreCardServiceScore)
        self.scoreCardOverallScore = Self.scoreCardClampedScore(scoreCardOverallScore)
    }

    static func scoreCardClampedScore(_ scoreCardValue: Int) -> Int {
        min(max(scoreCardValue, 1), 5)
    }
}

enum ScoreCardVenueRatingStore {
    private static let scoreCardStorageKey = "eulgo.local.scoreCard.venueRatings"

    static func scoreCardReadAllRatings() -> [ScoreCardVenueRatingModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(ScoreCardVenueRatingModel.self, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardReadRating(scoreCardRatingID: String) -> ScoreCardVenueRatingModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: scoreCardRatingID, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardReadRatings(scoreCardVenueID: String) -> [ScoreCardVenueRatingModel] {
        scoreCardReadAllRatings()
            .filter { $0.scoreCardVenueID == scoreCardVenueID }
    }

    static func scoreCardReadRating(scoreCardVenueID: String, scoreCardUserID: String) -> ScoreCardVenueRatingModel? {
        scoreCardReadAllRatings()
            .first {
                $0.scoreCardVenueID == scoreCardVenueID
                && $0.scoreCardUserID == scoreCardUserID
            }
    }

    static func scoreCardCreateRating(_ scoreCardRating: ScoreCardVenueRatingModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(scoreCardRating, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardUpdateRating(_ scoreCardRating: ScoreCardVenueRatingModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(scoreCardRating, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardUpsertRating(_ scoreCardRating: ScoreCardVenueRatingModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(scoreCardRating, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardDeleteRating(scoreCardRatingID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(ScoreCardVenueRatingModel.self, caddieVaultID: scoreCardRatingID, caddieVaultKey: scoreCardStorageKey)
    }

    static func scoreCardDeleteAllRatings() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: scoreCardStorageKey)
    }
}
