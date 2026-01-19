import SwiftUI
import Firebase

struct Config {
    static let appsFlyerId = "6757919278"
    static let appsFlyerKey = "tkZGsUECSKvakuv5JpinhP"
    static let appsFlyerBundle = "com.saclingappplus.FishScalePlus"
    static let end = "https://smartscalepluss.com/config.php"
}

struct RootView: View {
    
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var catchManager = CatchManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    init() {
        configureAppearance()
    }
    
    var body: some View {
        ZStack {
            if !authManager.isAuthenticated {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    AuthenticationView()
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            } else {
                MainTabView()
                    .environmentObject(authManager)
                    .environmentObject(catchManager)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasSeenOnboarding)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: authManager.isAuthenticated)
        .onChange(of: authManager.isAuthenticated) { isAuth in
            if isAuth, let userId = authManager.currentUserId {
                catchManager.startListening(userId: userId)
            }
        }
    }
    
    private func configureAppearance() {
        // Custom navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.background)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryBlue),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryBlue),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Custom tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
}

@main
struct SmartScalePlusApp: App {
    
    @UIApplicationDelegateAdaptor(LifecycleAdapter.self) var s
    
    var body: some Scene {
        WindowGroup {
            ScaleApplicationView()
        }
    }
    
}

// MARK: - Color Extensions
extension Color {
    static let primaryBlue = Color(hex: "1E88E5")
    static let sunriseYellow = Color(hex: "FFA726")
    static let coralOrange = Color(hex: "FF7043")
    static let background = Color(hex: "F8FAFB")
    static let seaGreen = Color(hex: "26A69A")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "757575")
    static let divider = Color(hex: "E0E0E0")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Font Extensions
extension Font {
    static func displayBold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func displayMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func bodyRegular(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func monoMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}
