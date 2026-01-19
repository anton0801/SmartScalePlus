
import AppsFlyerLib
import Foundation
import WebKit
import Firebase

final class RemoteNetworkFacade: NetworkFacade {
    
    private let session: URLSession
    
    private var user: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAttribution(deviceID: String) async throws -> [String: Any] {
        let url = try buildAttributionURL(deviceID: deviceID)
        let request = URLRequest(url: url, timeoutInterval: 30)
        
        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
    
    func resolveURL(attribution: [String: Any]) async throws -> String {
        let endpoint = URL(string: "https://birrdheallth.com/config.php")!
        let payload = buildPayload(from: attribution)
        let request = try buildRequest(url: endpoint, payload: payload)
        
        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        guard let success = json["ok"] as? Bool, success,
              let url = json["url"] as? String else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    // MARK: - Private Helpers
    
    private func buildAttributionURL(deviceID: String) throws -> URL {
        let base = "https://gcdsdk.appsflyer.com/install_data/v4.0/"
        let appID = "id\(Config.appsFlyerId)"
        
        guard var components = URLComponents(string: base + appID) else {
            throw NetworkError.malformed
        }
        
        components.queryItems = [
            URLQueryItem(name: "devkey", value: Config.appsFlyerKey),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        
        guard let url = components.url else {
            throw NetworkError.malformed
        }
        
        return url
    }
    
    private func buildPayload(from data: [String: Any]) -> [String: Any] {
        var payload = data
        
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = PlatformInfo.bundleID
        payload["firebase_project_id"] = PlatformInfo.firebaseProject
        payload["store_id"] = PlatformInfo.storeID
        payload["push_token"] = PlatformInfo.pushToken
        payload["locale"] = PlatformInfo.localeCode
        
        return payload
    }
    
    private func buildRequest(url: URL, payload: [String: Any]) throws -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        return request
    }
    
    private func checkResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError
        }
    }
}
