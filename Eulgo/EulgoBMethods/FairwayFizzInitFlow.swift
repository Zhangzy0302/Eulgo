import Combine
import CoreLocation
import Foundation
import SwiftUI
import UIKit

enum FairwayFizzBRoute {
    case fairwayFizzAgreement(fairwayFizzURL: String)
}

enum FairwayFizzInitStatus {
    case fairwayFizzLoading
    case fairwayFizzB
    case fairwayFizzA
}

private enum FairwayFizzInitConstants {
    static let fairwayFizzSuccessCode = "0000"
    static let fairwayFizzPollingInterval: UInt64 = 2_000_000_000
    static let fairwayFizzMaxErrorInterval: UInt64 = 10_000_000_000
}

private enum FairwayFizzInitMessage {
    static let fairwayFizzCommonError = "error"
    static let fairwayFizzLoginError = "Login Error"
    static let fairwayFizzNetworkError = "Network Error"
}

private enum FairwayFizzPayloadKey {
    static let fairwayFizzCode = "code"
    static let fairwayFizzResult = "result"
    static let fairwayFizzOpenValue = "openValue"
    static let fairwayFizzPassword = "password"
    static let fairwayFizzToken = "token"
    static let fairwayFizzLoginFlag = "loginFlag"
    static let fairwayFizzLocationFlag = "locationFlag"
}

private struct FairwayFizzDecisionPayload {
    let fairwayFizzStorage: [String: Any]

    var fairwayFizzOpenValue: String {
        fairwayFizzStorage[FairwayFizzPayloadKey.fairwayFizzOpenValue] as? String ?? ""
    }

    var fairwayFizzLoginFlag: Int {
        FairwayFizzValueReader.fairwayFizzIntValue(
            from: fairwayFizzStorage[FairwayFizzPayloadKey.fairwayFizzLoginFlag]
        )
    }

    var fairwayFizzLocationFlag: Int {
        FairwayFizzValueReader.fairwayFizzIntValue(
            from: fairwayFizzStorage[FairwayFizzPayloadKey.fairwayFizzLocationFlag]
        )
    }
}

private enum FairwayFizzValueReader {
    static func fairwayFizzIntValue(from fairwayFizzValue: Any?) -> Int {
        if let fairwayFizzInt = fairwayFizzValue as? Int {
            return fairwayFizzInt
        }

        if let fairwayFizzNumber = fairwayFizzValue as? NSNumber {
            return fairwayFizzNumber.intValue
        }

        if let fairwayFizzString = fairwayFizzValue as? String {
            return Int(fairwayFizzString.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        }

        return 0
    }
}

private enum FairwayFizzPayloadDecoder {
    static func fairwayFizzDecodeEncryptedResult(from fairwayFizzResponse: [String: Any]?) -> [String: Any] {
        guard let fairwayFizzResultString = fairwayFizzResponse?[FairwayFizzPayloadKey.fairwayFizzResult] as? String else {
            return [:]
        }

        let fairwayFizzDecryptedString = fairwayFizzResultString.putterPebbleBDecrypt()

        guard let fairwayFizzJSONData = fairwayFizzDecryptedString.data(using: .utf8),
              let fairwayFizzResultDict = try? JSONSerialization.jsonObject(with: fairwayFizzJSONData) as? [String: Any] else {
            return [:]
        }

        return fairwayFizzResultDict
    }
}

final class FairwayFizzInitUtils {
    static let shared = FairwayFizzInitUtils()

    var fairwayFizzApiCallResponse: [String: Any]?
    var fairwayFizzShouldFetchLocation: Bool = true

    private init() {}

    func fairwayFizzFetchDecision() async {
        do {
            fairwayFizzApiCallResponse = try await BirdieBeaconApiCall().birdieBeaconGetDecision()
        } catch {
            // Keep the original silent failure behavior. Polling decides when to show network feedback.
        }
    }

    func fairwayFizzGoLogin() async -> FairwayFizzBRoute? {
        do {
            try await fairwayFizzPrepareLocationIfNeeded()
            guard let fairwayFizzResponse = try await fairwayFizzQuickLoginResponse() else {
                return nil
            }
            return await fairwayFizzProcessLoginResponse(fairwayFizzResponse)
        } catch {
            await fairwayFizzShowToast(FairwayFizzInitMessage.fairwayFizzCommonError)
            return nil
        }
    }

    func fairwayFizzHandleLocation() async throws {
        guard let fairwayFizzPlacemark = await PutterPebbleLocationManager.shared.putterPebbleGetCurrentLocationAndAddress() else {
            throw NSError(domain: "LocationError", code: -1)
        }

        guard let fairwayFizzLocation = fairwayFizzPlacemark.location else {
            return
        }

        PutterPebblePhoneInfo.shared.putterPebbleLatitude = fairwayFizzLocation.coordinate.latitude
        PutterPebblePhoneInfo.shared.putterPebbleLongitude = fairwayFizzLocation.coordinate.longitude
    }

    func fairwayFizzProcessLoginResponse(_ fairwayFizzResponse: [String: Any]) async -> FairwayFizzBRoute? {
        guard let fairwayFizzCode = fairwayFizzResponse[FairwayFizzPayloadKey.fairwayFizzCode] as? String else {
            return nil
        }

        guard fairwayFizzCode == FairwayFizzInitConstants.fairwayFizzSuccessCode else {
            await fairwayFizzShowToast(FairwayFizzInitMessage.fairwayFizzLoginError)
            return nil
        }

        let fairwayFizzResultDict = FairwayFizzPayloadDecoder.fairwayFizzDecodeEncryptedResult(from: fairwayFizzResponse)
        guard fairwayFizzResultDict.isEmpty == false else {
            return nil
        }

        await fairwayFizzUpdateUserState(fairwayFizzResultDict)

        let fairwayFizzURL = fairwayFizzBuildH5RouteURL()
        print("h5url: \(fairwayFizzURL) ------end")

        return .fairwayFizzAgreement(fairwayFizzURL: fairwayFizzURL)
    }

    func fairwayFizzUpdateUserState(_ fairwayFizzResult: [String: Any]) async {
        if TeeSparkBInfoStore.shared.teeSparkPassword.isEmpty,
           let fairwayFizzPassword = fairwayFizzResult[FairwayFizzPayloadKey.fairwayFizzPassword] as? String {
            TeeSparkBInfoStore.shared.teeSparkPassword = fairwayFizzPassword
        }

        if let fairwayFizzToken = fairwayFizzResult[FairwayFizzPayloadKey.fairwayFizzToken] as? String {
            TeeSparkAppStorage.teeSparkUserToken = fairwayFizzToken
        }
    }

    func fairwayFizzHandleDeviceAndPolling() async {
        await fairwayFizzFetchDecision()

        var fairwayFizzElapsed: UInt64 = 0

        while fairwayFizzApiCallResponse == nil {
            try? await Task.sleep(nanoseconds: FairwayFizzInitConstants.fairwayFizzPollingInterval)
            fairwayFizzElapsed += FairwayFizzInitConstants.fairwayFizzPollingInterval

            await fairwayFizzFetchDecision()

            if fairwayFizzElapsed >= FairwayFizzInitConstants.fairwayFizzMaxErrorInterval {
                fairwayFizzElapsed = 0
                await fairwayFizzShowToast(FairwayFizzInitMessage.fairwayFizzNetworkError)
            }
        }
    }

    func fairwayFizzBuildH5RouteURL() -> String {
        PutterPebbleInformationCreate.putterPebbleBuildH5Url(
            baseUrl: TeeSparkAppStorage.teeSparkH5Url,
            token: TeeSparkAppStorage.teeSparkUserToken
        )
    }

    private func fairwayFizzPrepareLocationIfNeeded() async throws {
        guard fairwayFizzShouldFetchLocation else {
            return
        }

        try await fairwayFizzHandleLocation()
    }

    private func fairwayFizzQuickLoginResponse() async throws -> [String: Any]? {
        guard let fairwayFizzResponse = try await BirdieBeaconApiCall().birdieBeaconQuickLogin() else {
            await fairwayFizzShowToast(FairwayFizzInitMessage.fairwayFizzCommonError)
            return nil
        }

        return fairwayFizzResponse
    }

    @MainActor
    private func fairwayFizzShowToast(_ fairwayFizzMessage: String) {
        GolfPulseOverlayCenter.shared.golfPulseShowToast(fairwayFizzMessage, style: .error)
    }
}

@MainActor
final class FairwayFizzInitViewModel: ObservableObject {
    @Published var fairwayFizzStatus: FairwayFizzInitStatus = .fairwayFizzLoading
    @Published var fairwayFizzNextRoute: FairwayFizzBRoute?

    private let fairwayFizzInitUtils = FairwayFizzInitUtils.shared

    func fairwayFizzStartBInit() async {
        await PutterPebblePhoneInfo.shared.putterPebbleGetPhoneInfo()
        await fairwayFizzInitUtils.fairwayFizzHandleDeviceAndPolling()
        await fairwayFizzProcessApiResponse()
    }

    func fairwayFizzProcessApiResponse() async {
        guard let fairwayFizzPayload = fairwayFizzDecisionPayload() else {
            fairwayFizzUpdateStatus(.fairwayFizzA)
            return
        }

        TeeSparkAppStorage.teeSparkIsB = true
        TeeSparkAppStorage.teeSparkH5Url = fairwayFizzPayload.fairwayFizzOpenValue

        print("openValue: \(fairwayFizzPayload.fairwayFizzStorage[FairwayFizzPayloadKey.fairwayFizzOpenValue] ?? "null")")

        await fairwayFizzInitUtils.fairwayFizzUpdateUserState(fairwayFizzPayload.fairwayFizzStorage)
        await fairwayFizzRouteAfterDecision(fairwayFizzPayload)
    }

    func fairwayFizzBuildRedirectRoute() async -> FairwayFizzBRoute {
        let fairwayFizzURL = fairwayFizzInitUtils.fairwayFizzBuildH5RouteURL()
        return .fairwayFizzAgreement(fairwayFizzURL: fairwayFizzURL)
    }

    func fairwayFizzInitFlow() async {
        guard fairwayFizzIsPastVerifyDate() else {
            fairwayFizzUpdateStatus(.fairwayFizzA)
            return
        }

        TeeSparkAppStorage.teeSparkIsB = false

        if TeeSparkAppStorage.teeSparkIsB {
            fairwayFizzUpdateStatus(.fairwayFizzB)
        } else {
            await fairwayFizzStartBInit()
        }
    }

    private func fairwayFizzDecisionPayload() -> FairwayFizzDecisionPayload? {
        guard fairwayFizzIsResponseValid() else {
            return nil
        }

        let fairwayFizzDecryptedData = fairwayFizzDecryptResult()
        return FairwayFizzDecisionPayload(fairwayFizzStorage: fairwayFizzDecryptedData)
    }

    private func fairwayFizzIsResponseValid() -> Bool {
        guard let fairwayFizzResponse = fairwayFizzInitUtils.fairwayFizzApiCallResponse else {
            return false
        }

        print(fairwayFizzResponse)
        return (fairwayFizzResponse[FairwayFizzPayloadKey.fairwayFizzCode] as? String) == FairwayFizzInitConstants.fairwayFizzSuccessCode
    }

    private func fairwayFizzDecryptResult() -> [String: Any] {
        FairwayFizzPayloadDecoder.fairwayFizzDecodeEncryptedResult(
            from: fairwayFizzInitUtils.fairwayFizzApiCallResponse
        )
    }

    private func fairwayFizzRouteAfterDecision(_ fairwayFizzPayload: FairwayFizzDecisionPayload) async {
        let fairwayFizzHasLogin = fairwayFizzPayload.fairwayFizzLoginFlag == 1
            && TeeSparkAppStorage.teeSparkUserToken.isEmpty == false

        if fairwayFizzHasLogin {
            fairwayFizzNextRoute = await fairwayFizzBuildRedirectRoute()
            fairwayFizzUpdateStatus(.fairwayFizzB)
        } else {
            await fairwayFizzHandleLocationFlow(fairwayFizzPayload)
        }
    }

    private func fairwayFizzHandleLocationFlow(_ fairwayFizzPayload: FairwayFizzDecisionPayload) async {
        fairwayFizzInitUtils.fairwayFizzShouldFetchLocation = fairwayFizzPayload.fairwayFizzLocationFlag == 1

        if fairwayFizzInitUtils.fairwayFizzShouldFetchLocation {
            _ = await PutterPebbleLocationManager.shared.putterPebbleCheckAndRequestLocation()
        }

        fairwayFizzUpdateStatus(.fairwayFizzB)
    }

    private func fairwayFizzIsPastVerifyDate() -> Bool {
        guard let fairwayFizzTargetDate = Calendar.current.date(from: PutterPebbleInformationCreate.putterPebbleVerifyDate) else {
            return false
        }

        return Date() >= fairwayFizzTargetDate
    }

    private func fairwayFizzUpdateStatus(_ fairwayFizzNewStatus: FairwayFizzInitStatus) {
        fairwayFizzStatus = fairwayFizzNewStatus
    }
}
