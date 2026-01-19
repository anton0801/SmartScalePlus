import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var rippleScale1: CGFloat = 0
    @State private var rippleScale2: CGFloat = 0
    @State private var rippleScale3: CGFloat = 0
    @State private var rippleOpacity1: Double = 0.6
    @State private var rippleOpacity2: Double = 0.4
    @State private var rippleOpacity3: Double = 0.2
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var textOpacity: Double = 0
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryBlue.opacity(0.1),
                        Color.background.opacity(0.3),
                        Color.sunriseYellow.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Image(g.size.width > g.size.height ? "main_land" : "main")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                // Water ripple effects
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.8), lineWidth: 2)
                    .scaleEffect(rippleScale1)
                    .opacity(rippleOpacity1)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.seaGreen.opacity(0.8), lineWidth: 2)
                    .scaleEffect(rippleScale2)
                    .opacity(rippleOpacity2)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.sunriseYellow.opacity(0.8), lineWidth: 2)
                    .scaleEffect(rippleScale3)
                    .opacity(rippleOpacity3)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 20) {
                    
                    VStack(spacing: 4) {
                        
                        Text("Smart Scale")
                            .font(.custom("LilitaOne", size: 24))
                            .foregroundColor(.white)
                        
                        Text("Plus")
                            .font(.custom("LilitaOne", size: 22))
                            .foregroundColor(.sunriseYellow)
                        
                        Text("Loading....")
                            .font(.custom("LilitaOne", size: 42))
                            .foregroundColor(.white)
                            .padding(.top, 12)
                    }
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                }
            }
            .onAppear {
                // Ripple animations
                withAnimation(
                    Animation.easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    rippleScale1 = 3
                    rippleOpacity1 = 0
                }
                
                withAnimation(
                    Animation.easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(0.5)
                ) {
                    rippleScale2 = 3
                    rippleOpacity2 = 0
                }
                
                withAnimation(
                    Animation.easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(1.0)
                ) {
                    rippleScale3 = 3
                    rippleOpacity3 = 0
                }
                
                // Logo animation
                withAnimation(
                    Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)
                        .delay(0.3)
                ) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                // Text animation
                withAnimation(
                    Animation.easeOut(duration: 0.8)
                        .delay(0.8)
                ) {
                    textOffset = 0
                    textOpacity = 1.0
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

// MARK: - Fish Scale Icon
struct FishScaleIcon: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Draw stylized fish scale/weight scale
                // Center vertical line
                path.move(to: CGPoint(x: width / 2, y: height * 0.1))
                path.addLine(to: CGPoint(x: width / 2, y: height * 0.9))
                
                // Horizontal balance beam
                path.move(to: CGPoint(x: width * 0.1, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.3))
                
                // Scale pans
                path.addArc(
                    center: CGPoint(x: width * 0.2, y: height * 0.3),
                    radius: width * 0.15,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false
                )
                
                path.addArc(
                    center: CGPoint(x: width * 0.8, y: height * 0.3),
                    radius: width * 0.15,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false
                )
                
                // Fish silhouette
                path.move(to: CGPoint(x: width * 0.3, y: height * 0.6))
                path.addCurve(
                    to: CGPoint(x: width * 0.7, y: height * 0.6),
                    control1: CGPoint(x: width * 0.4, y: height * 0.5),
                    control2: CGPoint(x: width * 0.6, y: height * 0.5)
                )
                path.addCurve(
                    to: CGPoint(x: width * 0.3, y: height * 0.6),
                    control1: CGPoint(x: width * 0.6, y: height * 0.7),
                    control2: CGPoint(x: width * 0.4, y: height * 0.7)
                )
                
                // Tail
                path.move(to: CGPoint(x: width * 0.7, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.5))
                path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.7))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.6))
            }
            .stroke(Color.white, lineWidth: 3)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
    }
}

#Preview {
    PermissionSheet()
}

struct ScaleApplicationView: View {
    
    @StateObject private var facade = ApplicationFacade()
    @State private var subscriptions: Set<AnyCancellable> = []
    
    var body: some View {
        ZStack {
            contentView
            
            if facade.showingPermissionSheet {
                PermissionSheet()
                    .environmentObject(facade)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            subscribeToEvents()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch facade.viewMode {
        case .loading:
            SplashScreenView()
            
        case .running:
            if facade.destination != nil {
                ScaleContentView()
            } else {
                RootView()
            }
            
        case .standby:
            RootView()
            
        case .offline:
            OfflineScreen()
        }
    }
    
    private func subscribeToEvents() {
        NotificationCenter.default
            .publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { data in
                facade.processAttribution(data)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { data in
                facade.processDeeplink(data)
            }
            .store(in: &subscriptions)
    }
}

struct PermissionSheet: View {
    
    @EnvironmentObject var facade: ApplicationFacade
    @State private var animating = false
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(g.size.width > g.size.height ? "threel" : "three")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                if g.size.width > g.size.height {
                    horizontalContent
                } else {
                    verticalContent
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 145, height: 145)
                .scaleEffect(animating ? 1.25 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                    value: animating
                )
            
            Image(systemName: "scale.3d")
                .font(.system(size: 66))
                .foregroundColor(.blue)
        }
        .onAppear { animating = true }
    }
    
    private var textSection: some View {
        VStack(spacing: 20) {
            Text("Stay Connected")
                .font(.largeTitle.bold())
            
            Text("Get real-time updates about your weight tracking progress and goals")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
        }
    }
    
    private var verticalContent: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                .font(.custom("LilitaOne", size: 24))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                .font(.custom("LilitaOne", size: 16))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            buttonSection
        }
        .padding(.bottom, 24)
    }
    
    private var horizontalContent: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                        .font(.custom("LilitaOne", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                    
                    Text("STAY TUNED WITH BEST OFFERS FROM OUR CASINO")
                        .font(.custom("LilitaOne", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                buttonSection
                Spacer()
            }
        }
        .padding(.bottom, 24)
    }
    
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button {
                facade.acceptPermission()
            } label: {
                Image("threel_btn")
                    .resizable()
                    .frame(width: 320, height: 60)
            }
            
            Button {
                facade.declinePermission()
            } label: {
                Text("SKIP")
                    .font(.custom("LilitaOne", size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 48)
    }
}

struct OfflineScreen: View {
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(g.size.width > g.size.height ? "inet_l" : "inet")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                
                Image("inet_pla")
                    .resizable()
                    .frame(width: 250, height: 200)
            }
        }
        .ignoresSafeArea()
    }
}

