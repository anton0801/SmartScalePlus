import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var catchManager: CatchManager
    @State private var selectedTab = 0
    @State private var showAddCatch = false
    @State private var tabBarOffset: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                LogView()
                    .tag(0)
                    .environmentObject(catchManager)
                
                CalendarView()
                    .tag(1)
                    .environmentObject(catchManager)
                
                FishSpeciesView()
                    .tag(2)
                    .environmentObject(catchManager)
                
                StatsView()
                    .tag(3)
                    .environmentObject(catchManager)
                
                SettingsView()
                    .tag(4)
                    .environmentObject(authManager)
                    .environmentObject(catchManager)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                showAddCatch: $showAddCatch
            )
            .offset(y: tabBarOffset)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: tabBarOffset)
        }
        .sheet(isPresented: $showAddCatch) {
            AddCatchView(isPresented: $showAddCatch)
                .environmentObject(catchManager)
                .environmentObject(authManager)
        }
        .onAppear {
            tabBarOffset = 0
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showAddCatch: Bool
    
    let tabs = [
        TabItem(icon: "list.bullet.rectangle", title: "Log"),
        TabItem(icon: "calendar", title: "Calendar"),
        TabItem(icon: "fish", title: "Fish"),
        TabItem(icon: "chart.bar.fill", title: "Stats"),
        TabItem(icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
                .frame(maxWidth: .infinity)
                
                // Add catch button after Calendar (index 1)
                if index == 1 {
                    AddCatchButton(action: { showAddCatch = true })
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            ZStack {
                // White background
                Color.white
                
                // Subtle wave effect at top
                WaveShape()
                    .fill(Color.primaryBlue.opacity(0.05))
                    .frame(height: 8)
                    .offset(y: -4)
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Tab Item Model
struct TabItem {
    let icon: String
    let title: String
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.primaryBlue : Color.textSecondary)
                    .frame(height: 24)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.primaryBlue : Color.textSecondary)
            }
            .scaleEffect(scale)
        }
    }
}

// MARK: - Add Catch Button
struct AddCatchButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.primaryBlue.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .blur(radius: 8)
                    .offset(y: 2)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primaryBlue,
                                Color.seaGreen
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .offset(y: -20)
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4)
            let y = height / 2 + sine * height / 4
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthenticationManager())
            .environmentObject(CatchManager())
    }
}
