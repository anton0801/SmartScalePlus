import Foundation
import Combine
import Network
import UIKit
import AppsFlyerLib
import UserNotifications

@MainActor
final class ApplicationFacade: ObservableObject {
    
    @Published private(set) var viewMode: ViewMode = .loading
    @Published private(set) var destination: String?
    @Published private(set) var showingPermissionSheet = false
    
    private let stateEngine: StateEngine
    private let dataFacade: DataFacade
    private let networkFacade: NetworkFacade
    private var connectivityMonitor: ConnectivityMonitor
    
    private var observers = Set<AnyCancellable>()
    private var timeoutCancellable: AnyCancellable?
    private var locked = false
    
    init(
        stateEngine: StateEngine = StateEngine(),
        dataFacade: DataFacade = LocalDataFacade(),
        networkFacade: NetworkFacade = RemoteNetworkFacade(),
        connectivityMonitor: ConnectivityMonitor = ReachabilityMonitor()
    ) {
        self.stateEngine = stateEngine
        self.dataFacade = dataFacade
        self.networkFacade = networkFacade
        self.connectivityMonitor = connectivityMonitor
        
        setupStateObservation()
        setupConnectivityMonitoring()
        initiateStartup()
    }
    
    // MARK: - Public Interface
    
    func processAttribution(_ data: [String: Any]) {
        dataFacade.persistAttribution(data)
        stateEngine.trigger(.dataArrived)
        
        Task {
            await executeValidationSequence()
        }
    }
    
    func processDeeplink(_ data: [String: Any]) {
        dataFacade.persistDeeplink(data)
    }
    
    func declinePermission() {
        dataFacade.recordPermissionDismissal(Date())
        showingPermissionSheet = false
        completeActivation()
    }
    
    func acceptPermission() {
        requestNotificationPermission { [weak self] granted in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.dataFacade.savePermissionResult(granted: granted, denied: !granted)
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                self.showingPermissionSheet = false
                self.completeActivation()
            }
        }
    }
    
    // MARK: - Private Setup
    
    private func setupStateObservation() {
        stateEngine.$currentState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &observers)
    }
    
    private func handleStateChange(_ state: ApplicationState) {
        guard !locked else { return }
        
        switch state {
        case .initial, .preparing, .checking, .validated:
            viewMode = .loading
            
        case .active(let url):
            destination = url
            viewMode = .running
            locked = true
            
        case .idle:
            viewMode = .standby
            
        case .noConnection:
            viewMode = .offline
        }
    }
    
    private func setupConnectivityMonitoring() {
        connectivityMonitor.statusChanged = { [weak self] connected in
            guard let self = self, !self.locked else { return }
            
            if connected {
                self.stateEngine.trigger(.networkUp)
            } else {
                self.stateEngine.trigger(.networkDown)
            }
        }
        connectivityMonitor.begin()
    }
    
    private func initiateStartup() {
        stateEngine.trigger(.appLaunched)
        scheduleTimeout()
    }
    
    private func scheduleTimeout() {
        timeoutCancellable = Just(())
            .delay(for: .seconds(30), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, !self.locked else { return }
                self.stateEngine.trigger(.timedOut)
            }
    }
    
    // MARK: - Validation Sequence
    
    private func executeValidationSequence() async {
        do {
            try await stateEngine.performValidation()
            await continueSequence()
        } catch {
            stateEngine.trigger(.checkFailed)
        }
    }
    
    private func continueSequence() async {
        let attribution = dataFacade.retrieveAttribution()
        
        guard !attribution.isEmpty else {
            loadCachedURL()
            return
        }
        
        if dataFacade.retrieveMode() == "Inactive" {
            stateEngine.trigger(.timedOut)
            return
        }
        
        if shouldExecuteFirstRun() {
            await executeFirstRunSequence()
            return
        }
        
        if let temp = retrieveTemporaryURL() {
            activateWithURL(temp)
            return
        }
        
        await resolveURL()
    }
    
    private func shouldExecuteFirstRun() -> Bool {
        return dataFacade.isFirstRun() &&
               dataFacade.retrieveAttribution()["af_status"] as? String == "Organic"
    }
    
    private func executeFirstRunSequence() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            let deviceID = AppsFlyerLib.shared().getAppsFlyerUID()
            let attribution = try await networkFacade.fetchAttribution(deviceID: deviceID)
            
            var combined = attribution
            let deeplink = dataFacade.retrieveDeeplink()
            deeplink.forEach { key, value in
                if combined[key] == nil {
                    combined[key] = value
                }
            }
            
            dataFacade.persistAttribution(combined)
            await resolveURL()
        } catch {
            stateEngine.trigger(.timedOut)
        }
    }
    
    private func retrieveTemporaryURL() -> String? {
        return UserDefaults.standard.string(forKey: "temp_url")
    }
    
    private func resolveURL() async {
        do {
            let attribution = dataFacade.retrieveAttribution()
            let url = try await networkFacade.resolveURL(attribution: attribution)
            
            dataFacade.cacheURL(url)
            dataFacade.setMode("Active")
            dataFacade.markFirstRunComplete()
            
            activateWithURL(url)
        } catch {
            loadCachedURL()
        }
    }
    
    private func loadCachedURL() {
        if let cached = dataFacade.retrieveCachedURL() {
            activateWithURL(cached)
        } else {
            stateEngine.trigger(.timedOut)
        }
    }
    
    private func activateWithURL(_ url: String) {
        guard !locked else { return }
        
        stateEngine.trigger(.urlResolved(url))
        
        if shouldShowPermissionSheet() {
            showingPermissionSheet = true
        }
    }
    
    private func shouldShowPermissionSheet() -> Bool {
        if dataFacade.wasPermissionGranted() || dataFacade.wasPermissionDenied() {
            return false
        }
        
        if let lastRequest = dataFacade.retrieveLastPermissionRequest(),
           Date().timeIntervalSince(lastRequest) < 259200 {
            return false
        }
        
        return true
    }
    
    private func completeActivation() {
        // Already handled by state engine
    }
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            completion(granted)
        }
    }
}

// MARK: - View Mode
enum ViewMode {
    case loading
    case running
    case standby
    case offline
}

// MARK: - Data Facade Protocol
protocol DataFacade {
    func persistAttribution(_ data: [String: Any])
    func persistDeeplink(_ data: [String: Any])
    func retrieveAttribution() -> [String: Any]
    func retrieveDeeplink() -> [String: Any]
    func cacheURL(_ url: String)
    func retrieveCachedURL() -> String?
    func setMode(_ mode: String)
    func retrieveMode() -> String?
    func isFirstRun() -> Bool
    func markFirstRunComplete()
    func recordPermissionDismissal(_ date: Date)
    func retrieveLastPermissionRequest() -> Date?
    func savePermissionResult(granted: Bool, denied: Bool)
    func wasPermissionGranted() -> Bool
    func wasPermissionDenied() -> Bool
}

// MARK: - Network Facade Protocol
protocol NetworkFacade {
    func fetchAttribution(deviceID: String) async throws -> [String: Any]
    func resolveURL(attribution: [String: Any]) async throws -> String
}

// MARK: - Connectivity Monitor Protocol
protocol ConnectivityMonitor {
    var statusChanged: ((Bool) -> Void)? { get set }
    func begin()
    func end()
}

// MARK: - Reachability Monitor
final class ReachabilityMonitor: ConnectivityMonitor {
    
    private let monitor = NWPathMonitor()
    var statusChanged: ((Bool) -> Void)?
    
    func begin() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.statusChanged?(isConnected)
        }
        monitor.start(queue: .global(qos: .background))
    }
    
    func end() {
        monitor.cancel()
    }
}
