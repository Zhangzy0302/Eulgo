import Foundation

enum CaddieVaultLocalStore {
    static func caddieVaultReadArray<Model: Codable>(
        _ caddieVaultModelType: Model.Type,
        caddieVaultKey: String
    ) -> [Model] {
        guard let caddieVaultData = UserDefaults.standard.data(forKey: caddieVaultKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([Model].self, from: caddieVaultData)
        } catch {
            return []
        }
    }

    static func caddieVaultSaveArray<Model: Codable>(
        _ caddieVaultModels: [Model],
        caddieVaultKey: String
    ) {
        guard let caddieVaultData = try? JSONEncoder().encode(caddieVaultModels) else {
            return
        }

        UserDefaults.standard.set(caddieVaultData, forKey: caddieVaultKey)
    }

    static func caddieVaultRead<Model: Codable & Identifiable>(
        caddieVaultID: Model.ID,
        caddieVaultKey: String
    ) -> Model? where Model.ID: Equatable {
        caddieVaultReadArray(Model.self, caddieVaultKey: caddieVaultKey)
            .first { $0.id == caddieVaultID }
    }

    static func caddieVaultCreate<Model: Codable & Identifiable>(
        _ caddieVaultModel: Model,
        caddieVaultKey: String
    ) -> Bool where Model.ID: Equatable {
        var caddieVaultModels = caddieVaultReadArray(Model.self, caddieVaultKey: caddieVaultKey)

        guard caddieVaultModels.contains(where: { $0.id == caddieVaultModel.id }) == false else {
            return false
        }

        caddieVaultModels.append(caddieVaultModel)
        caddieVaultSaveArray(caddieVaultModels, caddieVaultKey: caddieVaultKey)
        return true
    }

    static func caddieVaultUpdate<Model: Codable & Identifiable>(
        _ caddieVaultModel: Model,
        caddieVaultKey: String
    ) -> Bool where Model.ID: Equatable {
        var caddieVaultModels = caddieVaultReadArray(Model.self, caddieVaultKey: caddieVaultKey)

        guard let caddieVaultIndex = caddieVaultModels.firstIndex(where: { $0.id == caddieVaultModel.id }) else {
            return false
        }

        caddieVaultModels[caddieVaultIndex] = caddieVaultModel
        caddieVaultSaveArray(caddieVaultModels, caddieVaultKey: caddieVaultKey)
        return true
    }

    static func caddieVaultUpsert<Model: Codable & Identifiable>(
        _ caddieVaultModel: Model,
        caddieVaultKey: String
    ) where Model.ID: Equatable {
        var caddieVaultModels = caddieVaultReadArray(Model.self, caddieVaultKey: caddieVaultKey)

        if let caddieVaultIndex = caddieVaultModels.firstIndex(where: { $0.id == caddieVaultModel.id }) {
            caddieVaultModels[caddieVaultIndex] = caddieVaultModel
        } else {
            caddieVaultModels.append(caddieVaultModel)
        }

        caddieVaultSaveArray(caddieVaultModels, caddieVaultKey: caddieVaultKey)
    }

    static func caddieVaultDelete<Model: Codable & Identifiable>(
        _ caddieVaultModelType: Model.Type,
        caddieVaultID: Model.ID,
        caddieVaultKey: String
    ) -> Bool where Model.ID: Equatable {
        var caddieVaultModels = caddieVaultReadArray(Model.self, caddieVaultKey: caddieVaultKey)
        let caddieVaultOriginalCount = caddieVaultModels.count

        caddieVaultModels.removeAll { $0.id == caddieVaultID }
        caddieVaultSaveArray(caddieVaultModels, caddieVaultKey: caddieVaultKey)

        return caddieVaultModels.count != caddieVaultOriginalCount
    }

    static func caddieVaultDeleteAll(caddieVaultKey: String) {
        UserDefaults.standard.removeObject(forKey: caddieVaultKey)
    }
}
