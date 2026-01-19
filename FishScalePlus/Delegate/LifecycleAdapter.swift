import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import Combine

final class LifecycleAdapter: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    private let eventAdapter = EventAdapter()
    private let messageAdapter = MessageAdapter()
    private let trackingAdapter = TrackingAdapter()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initializeCore()
        configureDelegates()
        enableNotifications()
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            messageAdapter.process(notification)
        }
        
        trackingAdapter.setup(
            onConversionSuccess: { [weak self] data in
                self?.eventAdapter.emitConversion(data)
            },
            onDeeplinkSuccess: { [weak self] data in
                self?.eventAdapter.emitDeeplink(data)
            },
            onFailure: { [weak self] in
                self?.eventAdapter.emitConversion([:])
            }
        )
        
        observeLifecycle()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Setup
    
    private func initializeCore() {
        FirebaseApp.configure()
    }
    
    private func configureDelegates() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func enableNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func observeLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleBecameActive() {
        trackingAdapter.start()
    }
    
    // MARK: - MessagingDelegate
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            TokenRepository.shared.save(token)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        messageAdapter.process(notification.request.content.userInfo)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        messageAdapter.process(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        messageAdapter.process(userInfo)
        completionHandler(.newData)
    }
}

// MARK: - Event Adapter
final class EventAdapter {
    
    private var conversionData: [AnyHashable: Any] = [:]
    private var deeplinkData: [AnyHashable: Any] = [:]
    private var consolidationTimer: Timer?
    private let sentFlag = "trackingDataSent"
    
    func emitConversion(_ data: [AnyHashable: Any]) {
        conversionData = data
        
        // FIXED: Короткий таймаут (2 секунды) для ожидания deeplink
        scheduleConsolidation()
        
        // Если deeplink уже есть - отправляем сразу
        if !deeplinkData.isEmpty {
            consolidate()
        }
    }
    
    func emitDeeplink(_ data: [AnyHashable: Any]) {
        guard !wasSent() else { return }
        
        deeplinkData = data
        
        // Публикуем deeplink отдельно
        publishDeeplink(data)
        
        // Отменяем таймер и отправляем объединенные данные
        cancelConsolidation()
        
        if !conversionData.isEmpty {
            consolidate()
        }
    }
    
    // MARK: - Private Methods
    
    private func scheduleConsolidation() {
        consolidationTimer?.invalidate()
        
        // FIXED: 2 секунды вместо 10
        consolidationTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: false
        ) { [weak self] _ in
            self?.consolidate()
        }
    }
    
    private func cancelConsolidation() {
        consolidationTimer?.invalidate()
    }
    
    private func consolidate() {
        var consolidated = conversionData
        
        deeplinkData.forEach { key, value in
            if consolidated[key] == nil {
                consolidated[key] = value
            }
        }
        
        publishConversion(consolidated)
        markSent()
    }
    
    private func publishConversion(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("ConversionDataReceived"),
            object: nil,
            userInfo: ["conversionData": data]
        )
    }
    
    private func publishDeeplink(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("deeplink_values"),
            object: nil,
            userInfo: ["deeplinksData": data]
        )
    }
    
    private func wasSent() -> Bool {
        return UserDefaults.standard.bool(forKey: sentFlag)
    }
    
    private func markSent() {
        UserDefaults.standard.set(true, forKey: sentFlag)
    }
}

// MARK: - Tracking Adapter
final class TrackingAdapter: NSObject {
    
    private var onConversionSuccess: (([AnyHashable: Any]) -> Void)?
    private var onDeeplinkSuccess: (([AnyHashable: Any]) -> Void)?
    private var onFailure: (() -> Void)?
    
    func setup(
        onConversionSuccess: @escaping ([AnyHashable: Any]) -> Void,
        onDeeplinkSuccess: @escaping ([AnyHashable: Any]) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onConversionSuccess = onConversionSuccess
        self.onDeeplinkSuccess = onDeeplinkSuccess
        self.onFailure = onFailure
        
        configureSDK()
    }
    
    private func configureSDK() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = Config.appsFlyerKey
        sdk.appleAppID = Config.appsFlyerId
        sdk.delegate = self
        sdk.deepLinkDelegate = self
    }
    
    func start() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
}

// MARK: - AppsFlyerLibDelegate
extension TrackingAdapter: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        onConversionSuccess?(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        onFailure?()
    }
}

// MARK: - DeepLinkDelegate
extension TrackingAdapter: DeepLinkDelegate {
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let deeplink = result.deepLink else {
            return
        }
        
        onDeeplinkSuccess?(deeplink.clickEvent)
    }
}

// MARK: - Message Adapter
final class MessageAdapter {
    
    func process(_ payload: [AnyHashable: Any]) {
        guard let url = extract(from: payload) else {
            return
        }
        
        UserDefaults.standard.set(url, forKey: "temp_url")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(
                name: Notification.Name("LoadTempURL"),
                object: nil,
                userInfo: ["temp_url": url]
            )
        }
    }
    
    private func extract(from payload: [AnyHashable: Any]) -> String? {
        // Direct
        if let url = payload["url"] as? String {
            return url
        }
        
        // Nested
        if let nested = payload["data"] as? [String: Any],
           let url = nested["url"] as? String {
            return url
        }
        
        return nil
    }
}

// MARK: - Token Repository
final class TokenRepository {
    
    static let shared = TokenRepository()
    
    private init() {}
    
    func save(_ token: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "fcm_token")
        defaults.set(token, forKey: "push_token")
    }
    
    func retrieve() -> String? {
        return UserDefaults.standard.string(forKey: "push_token")
    }
}
