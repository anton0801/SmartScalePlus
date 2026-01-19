import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Every Catch",
            description: "Record weight, length, and details of every fish you catch. Build your personal fishing journal.",
            imageName: "fish.scale",
            color: Color.primaryBlue
        ),
        OnboardingPage(
            title: "Analyze Your Success",
            description: "View statistics, track progress, and discover patterns in your fishing adventures.",
            imageName: "chart.growth",
            color: Color.seaGreen
        ),
        OnboardingPage(
            title: "Never Forget a Catch",
            description: "Store all your catches in the cloud. Access your fishing history anytime, anywhere.",
            imageName: "cloud.data",
            color: Color.sunriseYellow
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(pageIndex: currentPage)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        completeOnboarding()
                    }) {
                        Text("Skip")
                            .font(.bodyRegular(16))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding()
                .opacity(currentPage < pages.count - 1 ? 1 : 0)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            pageIndex: index,
                            currentPage: $currentPage
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Custom page indicator
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Action button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.displayMedium(18))
                            .foregroundColor(pages[currentPage].color)
                        
                        if currentPage < pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(pages[currentPage].color)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        hasSeenOnboarding = true
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @Binding var currentPage: Int
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -10
    @State private var titleOffset: CGFloat = 50
    @State private var descriptionOffset: CGFloat = 50
    @State private var opacityValue: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon
            ZStack {
                // Background circles for depth
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .blur(radius: 10)
                
                // Main icon
                AnimatedOnboardingIcon(imageName: page.imageName, color: page.color)
                    .frame(width: 120, height: 120)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }
            .frame(height: 250)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.displayBold(32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .offset(y: titleOffset)
                    .opacity(opacityValue)
                
                Text(page.description)
                    .font(.bodyRegular(18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .offset(y: descriptionOffset)
                    .opacity(opacityValue)
            }
            
            Spacer()
            Spacer()
        }
        .onChange(of: currentPage) { newPage in
            if newPage == pageIndex {
                animateIn()
            }
        }
        .onAppear {
            if currentPage == pageIndex {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        // Reset states
        iconScale = 0.5
        iconRotation = -10
        titleOffset = 50
        descriptionOffset = 50
        opacityValue = 0
        
        // Animate icon
        withAnimation(
            Animation.spring(response: 0.8, dampingFraction: 0.6)
                .delay(0.1)
        ) {
            iconScale = 1.0
            iconRotation = 0
        }
        
        // Animate title
        withAnimation(
            Animation.easeOut(duration: 0.6)
                .delay(0.3)
        ) {
            titleOffset = 0
            opacityValue = 1
        }
        
        // Animate description
        withAnimation(
            Animation.easeOut(duration: 0.6)
                .delay(0.5)
        ) {
            descriptionOffset = 0
        }
    }
}

// MARK: - Animated Onboarding Icon
struct AnimatedOnboardingIcon: View {
    let imageName: String
    let color: Color
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            
            if imageName == "fish.scale" {
                FishScaleAnimatedIcon()
                    .foregroundColor(color)
                    .scaleEffect(0.5)
            } else if imageName == "chart.growth" {
                ChartGrowthIcon()
                    .foregroundColor(color)
                    .scaleEffect(0.5)
            } else if imageName == "cloud.data" {
                CloudDataIcon()
                    .foregroundColor(color)
                    .scaleEffect(0.5)
            }
        }
    }
}

// MARK: - Custom Icons
struct FishScaleAnimatedIcon: View {
    @State private var animateWaves = false
    
    var body: some View {
        ZStack {
            // Fish outline
            Image(systemName: "figure.fishing")
                .font(.system(size: 80, weight: .light))
            
            // Animated waves
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 2)
                    .frame(width: 30 + CGFloat(index) * 20, height: 30 + CGFloat(index) * 20)
                    .scaleEffect(animateWaves ? 2 : 1)
                    .opacity(animateWaves ? 0 : 0.5)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                        value: animateWaves
                    )
            }
        }
        .onAppear {
            animateWaves = true
        }
    }
}

struct ChartGrowthIcon: View {
    @State private var animateBars = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.seaGreen)
                    .frame(width: 20, height: animateBars ? CGFloat(40 + index * 20) : 20)
                    .animation(
                        Animation.spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                        value: animateBars
                    )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateBars = true
            }
        }
    }
}

struct CloudDataIcon: View {
    @State private var animateCloud = false
    
    var body: some View {
        ZStack {
            Image(systemName: "icloud.fill")
                .font(.system(size: 80, weight: .light))
                .offset(y: animateCloud ? -5 : 5)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: animateCloud
                )
            
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 30, weight: .medium))
                .offset(y: 5)
        }
        .onAppear {
            animateCloud = true
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    let pageIndex: Int
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 0.8), value: pageIndex)
    }
    
    var gradientColors: [Color] {
        switch pageIndex {
        case 0:
            return [Color.primaryBlue, Color.primaryBlue.opacity(0.7)]
        case 1:
            return [Color.seaGreen, Color.seaGreen.opacity(0.7)]
        case 2:
            return [Color.sunriseYellow, Color.coralOrange]
        default:
            return [Color.primaryBlue, Color.primaryBlue.opacity(0.7)]
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
            .environmentObject(AuthenticationManager())
    }
}
