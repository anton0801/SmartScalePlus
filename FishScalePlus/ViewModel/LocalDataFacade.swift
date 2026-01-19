import Foundation
import FirebaseMessaging
import Firebase

final class LocalDataFacade: DataFacade {
    
    private let storage = UserDefaults.standard
    private var attributionCache: [String: Any] = [:]
    private var deeplinkCache: [String: Any] = [:]
    
    private enum Key {
        static let url = "cached_endpoint"
        static let mode = "app_status"
        static let firstRun = "launchedBefore"
        static let permissionRequest = "permission_request_time"
        static let permissionGranted = "permissions_accepted"
        static let permissionDenied = "permissions_denied"
    }
    
    func persistAttribution(_ data: [String: Any]) {
        attributionCache = data
    }
    
    func persistDeeplink(_ data: [String: Any]) {
        deeplinkCache = data
    }
    
    func retrieveAttribution() -> [String: Any] {
        return attributionCache
    }
    
    func retrieveDeeplink() -> [String: Any] {
        return deeplinkCache
    }
    
    func cacheURL(_ url: String) {
        storage.set(url, forKey: Key.url)
    }
    
    func retrieveCachedURL() -> String? {
        return storage.string(forKey: Key.url)
    }
    
    func setMode(_ mode: String) {
        storage.set(mode, forKey: Key.mode)
    }
    
    func retrieveMode() -> String? {
        return storage.string(forKey: Key.mode)
    }
    
    func isFirstRun() -> Bool {
        return !storage.bool(forKey: Key.firstRun)
    }
    
    func markFirstRunComplete() {
        storage.set(true, forKey: Key.firstRun)
    }
    
    func recordPermissionDismissal(_ date: Date) {
        storage.set(date, forKey: Key.permissionRequest)
    }
    
    func retrieveLastPermissionRequest() -> Date? {
        return storage.object(forKey: Key.permissionRequest) as? Date
    }
    
    func savePermissionResult(granted: Bool, denied: Bool) {
        storage.set(granted, forKey: Key.permissionGranted)
        storage.set(denied, forKey: Key.permissionDenied)
    }
    
    func wasPermissionGranted() -> Bool {
        return storage.bool(forKey: Key.permissionGranted)
    }
    
    func wasPermissionDenied() -> Bool {
        return storage.bool(forKey: Key.permissionDenied)
    }
}

// MARK: - Remote Network Facade

// MARK: - Network Error
enum NetworkError: Error {
    case malformed
    case serverError
    case invalidURL
}

// MARK: - Platform Info
struct PlatformInfo {
    
    static var bundleID: String {
        return Config.appsFlyerBundle
    }
    
    static var firebaseProject: String? {
        return FirebaseApp.app()?.options.gcmSenderID
    }
    
    static var storeID: String {
        return "id\(Config.appsFlyerId)"
    }
    
    static var pushToken: String? {
        if let saved = UserDefaults.standard.string(forKey: "push_token") {
            return saved
        }
        return Messaging.messaging().fcmToken
    }
    
    static var localeCode: String {
        return Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
    }
}
