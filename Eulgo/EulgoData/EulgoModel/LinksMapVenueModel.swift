import Foundation

struct LinksMapVenueModel: Identifiable, Codable, Equatable {
    let linksMapVenueID: String
    var linksMapPhotoAddresses: [String]
    var linksMapVenueName: String
    var linksMapIntroductionText: String
    var linksMapVenueSize: Int
    var linksMapStarRating: Double

    var id: String { linksMapVenueID }

    init(
        linksMapVenueID: String = UUID().uuidString,
        linksMapPhotoAddresses: [String] = [],
        linksMapVenueName: String,
        linksMapIntroductionText: String,
        linksMapVenueSize: Int = 0,
        linksMapStarRating: Double = 4.0
    ) {
        self.linksMapVenueID = linksMapVenueID
        self.linksMapPhotoAddresses = linksMapPhotoAddresses
        self.linksMapVenueName = linksMapVenueName
        self.linksMapIntroductionText = linksMapIntroductionText
        self.linksMapVenueSize = linksMapVenueSize
        self.linksMapStarRating = LinksMapVenueModel.linksMapClampedStarRating(linksMapStarRating)
    }

    enum CodingKeys: String, CodingKey {
        case linksMapVenueID
        case linksMapPhotoAddresses
        case linksMapVenueName
        case linksMapIntroductionText
        case linksMapVenueSize
        case linksMapStarRating
    }

    init(from decoder: Decoder) throws {
        let linksMapContainer = try decoder.container(keyedBy: CodingKeys.self)

        linksMapVenueID = try linksMapContainer.decode(String.self, forKey: .linksMapVenueID)
        linksMapPhotoAddresses = try linksMapContainer.decodeIfPresent([String].self, forKey: .linksMapPhotoAddresses) ?? []
        linksMapVenueName = try linksMapContainer.decode(String.self, forKey: .linksMapVenueName)
        linksMapIntroductionText = try linksMapContainer.decode(String.self, forKey: .linksMapIntroductionText)
        linksMapVenueSize = try linksMapContainer.decodeIfPresent(Int.self, forKey: .linksMapVenueSize) ?? 0
        linksMapStarRating = LinksMapVenueModel.linksMapClampedStarRating(
            try linksMapContainer.decodeIfPresent(Double.self, forKey: .linksMapStarRating) ?? 4.0
        )
    }

    private static func linksMapClampedStarRating(_ linksMapStarRating: Double) -> Double {
        min(5.0, max(1.0, linksMapStarRating))
    }
}

enum LinksMapVenueStore {
    private static let linksMapStorageKey = "eulgo.local.linksMap.venues"

    static func linksMapReadAllVenues() -> [LinksMapVenueModel] {
        CaddieVaultLocalStore.caddieVaultReadArray(LinksMapVenueModel.self, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapReadVenue(linksMapVenueID: String) -> LinksMapVenueModel? {
        CaddieVaultLocalStore.caddieVaultRead(caddieVaultID: linksMapVenueID, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapCreateVenue(_ linksMapVenue: LinksMapVenueModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultCreate(linksMapVenue, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapUpdateVenue(_ linksMapVenue: LinksMapVenueModel) -> Bool {
        CaddieVaultLocalStore.caddieVaultUpdate(linksMapVenue, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapUpsertVenue(_ linksMapVenue: LinksMapVenueModel) {
        CaddieVaultLocalStore.caddieVaultUpsert(linksMapVenue, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapDeleteVenue(linksMapVenueID: String) -> Bool {
        CaddieVaultLocalStore.caddieVaultDelete(LinksMapVenueModel.self, caddieVaultID: linksMapVenueID, caddieVaultKey: linksMapStorageKey)
    }

    static func linksMapDeleteAllVenues() {
        CaddieVaultLocalStore.caddieVaultDeleteAll(caddieVaultKey: linksMapStorageKey)
    }
}
