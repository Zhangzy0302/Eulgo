
import AdjustSdk
import Alamofire
import Foundation
import StoreKit

final class BirdieBeaconApiCall {

    private lazy var birdieBeaconSession: Session = {
        let birdieBeaconConfiguration = URLSessionConfiguration.default
        birdieBeaconConfiguration.headers = .default
        return Session(configuration: birdieBeaconConfiguration)
    }()
}

// MARK: - Public API

extension BirdieBeaconApiCall {

    func birdieBeaconPayCall(
        purchaseID: String,
        serverVerificationData: String,
        orderCode: String
    ) async throws -> Bool {
        let birdieBeaconBody = try birdieBeaconPayBody(
            purchaseID: purchaseID,
            serverVerificationData: serverVerificationData,
            orderCode: orderCode
        )
        print("payload: \(birdieBeaconBody)")

        let birdieBeaconData = try await birdieBeaconRequest(
            path: BirdieBeaconEndpoint.birdieBeaconPay.path,
            body: birdieBeaconBody
        )
        print("pay code: \(birdieBeaconData?["code"] ?? "null")")

        return birdieBeaconData?["code"] as? String == "0000"
    }

    func birdieBeaconGetDecision() async throws -> [String: Any]? {
        try await birdieBeaconRequest(
            path: BirdieBeaconEndpoint.birdieBeaconDecision.path,
            body: birdieBeaconDecisionBody()
        )
    }

    func birdieBeaconQuickLogin() async throws -> [String: Any]? {
        let birdieBeaconAdjustID = await Adjust.adid()

        return try await birdieBeaconRequest(
            path: BirdieBeaconEndpoint.birdieBeaconQuickLogin.path,
            body: birdieBeaconQuickLoginBody(adjustID: birdieBeaconAdjustID)
        )
    }

    func birdieBeaconLoadingTimeRecord(_ loadingTime: Int) async throws -> [String: Any]? {
        try await birdieBeaconRequest(
            path: BirdieBeaconEndpoint.birdieBeaconLoadingTime.path,
            body: birdieBeaconLoadingTimeBody(loadingTime)
        )
    }
}

// MARK: - Request Payloads

extension BirdieBeaconApiCall {

    private func birdieBeaconPayBody(
        purchaseID: String,
        serverVerificationData: String,
        orderCode: String
    ) throws -> [String: Any] {
        [
            "bxuakxslUkegt": purchaseID,
            "braKJAhxkuabp": serverVerificationData,
            "nrwKUhckujarc": try birdieBeaconJSONString(["orderCode": orderCode])
        ]
    }

    private func birdieBeaconDecisionBody() -> [String: Any] {
        let birdieBeaconPhoneInfo = PutterPebblePhoneInfo.shared

        return [
            "bgdKJhhdhakbrad": 1,
            "ukdkhKJhvsn": birdieBeaconPhoneInfo.putterPebbleIsVpnActive,
            "fawyqtTfatse": birdieBeaconPhoneInfo.putterPebbleLanguages,
            "dalkKJAhhhbjs": birdieBeaconPhoneInfo.putterPebbleCoverAppList,
            "hjLKjljifsdt": birdieBeaconPhoneInfo.putterPebbleTimezone,
            "sliiauhcrqsk": birdieBeaconPhoneInfo.putterPebbleKeyboards,
            "debug": 1
        ]
    }

    private func birdieBeaconQuickLoginBody(adjustID birdieBeaconAdjustID: String?) -> [String: Any] {
        let birdieBeaconPhoneInfo = PutterPebblePhoneInfo.shared
        let birdieBeaconPassword = TeeSparkBInfoStore.shared.teeSparkPassword

        var birdieBeaconBody: [String: Any] = [
            "pobhLKjhjwaa": birdieBeaconAdjustID ?? "",
            "njhJLAjhuecd": birdieBeaconPassword,
            "htKJAbxuwan": TeeSparkBInfoStore.shared.teeSparkDeviceId,
            "sdaxawuqwav": [
                "countryCode": birdieBeaconPhoneInfo.putterPebbleCountryCode,
                "latitude": birdieBeaconPhoneInfo.putterPebbleLatitude,
                "longitude": birdieBeaconPhoneInfo.putterPebbleLongitude
            ]
        ]

        if birdieBeaconPassword.isEmpty == false {
            birdieBeaconBody["hbtSCVsdsd"] = birdieBeaconPassword
        }

        return birdieBeaconBody
    }

    private func birdieBeaconLoadingTimeBody(_ birdieBeaconLoadingTime: Int) -> [String: Any] {
        [
            "mkanhljieo": "\(birdieBeaconLoadingTime)"
        ]
    }
}

// MARK: - Network

extension BirdieBeaconApiCall {

    private var birdieBeaconHeaders: HTTPHeaders {
        [
            "Content-Type": "application/json",
            "appVersion": PutterPebbleInformationCreate.putterPebbleAppVersion,
            "deviceNo": TeeSparkBInfoStore.shared.teeSparkDeviceId,
            "pushToken": TeeSparkAppStorage.teeSparkPushToken,
            "loginToken": TeeSparkAppStorage.teeSparkUserToken,
            "appId": PutterPebbleInformationCreate.putterPebbleAppId
        ]
    }

    fileprivate func birdieBeaconRequest(
        path: String,
        body: [String: Any]
    ) async throws -> [String: Any]? {
        guard let birdieBeaconJSONString = try birdieBeaconJSONString(body).nilIfEmpty else {
            return nil
        }

        let birdieBeaconEncryptedString = birdieBeaconJSONString.putterPebbleBEncode()
        let birdieBeaconResponse = try await birdieBeaconSession.request(
            PutterPebbleInformationCreate.putterPebbleBaseURL + path,
            method: .post,
            parameters: nil,
            encoding: BirdieBeaconRawStringEncoding(string: birdieBeaconEncryptedString),
            headers: birdieBeaconHeaders
        )
        .serializingData()
        .value

        return try birdieBeaconParseResponse(birdieBeaconResponse)
    }

    fileprivate func birdieBeaconParseResponse(_ data: Data) throws -> [String: Any]? {
        let birdieBeaconObject = try JSONSerialization.jsonObject(with: data)

        if let birdieBeaconDict = birdieBeaconObject as? [String: Any] {
            return birdieBeaconDict
        }

        guard
            let birdieBeaconString = birdieBeaconObject as? String,
            let birdieBeaconData = birdieBeaconString.data(using: .utf8)
        else {
            return nil
        }

        return try JSONSerialization.jsonObject(with: birdieBeaconData) as? [String: Any]
    }

    fileprivate func birdieBeaconJSONString(_ dict: [String: Any]) throws -> String {
        let birdieBeaconData = try JSONSerialization.data(withJSONObject: dict)
        return String(data: birdieBeaconData, encoding: .utf8) ?? ""
    }
}

// MARK: - Endpoint

private enum BirdieBeaconEndpoint {
    case birdieBeaconPay
    case birdieBeaconDecision
    case birdieBeaconQuickLogin
    case birdieBeaconLoadingTime

    var path: String {
        switch self {
        case .birdieBeaconPay:
            return "/opi/v1/sxshjklvs/ejahhp"
        case .birdieBeaconDecision:
            return "/opi/v1/adsfaAhjbxw/awsio"
        case .birdieBeaconQuickLogin:
            return "/opi/v1/hgrav/ajhkykuAsl"
        case .birdieBeaconLoadingTime:
            return "/opi/v1/sdacWjhg/KUHwwat"
        }
    }
}

// MARK: - Raw Body Encoding

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

struct BirdieBeaconRawStringEncoding: ParameterEncoding {

    let string: String

    func encode(
        _ urlRequest: URLRequestConvertible,
        with parameters: Parameters?
    ) throws -> URLRequest {

        var birdieBeaconRequest = try urlRequest.asURLRequest()
        birdieBeaconRequest.httpBody = string.data(using: .utf8)
        return birdieBeaconRequest
    }
}
