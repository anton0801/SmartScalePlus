import SwiftUI

//struct ContentView: View {
//    @StateObject var catchManager = CatchManager()
//    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
//    @State private var showOnboarding = false
//    
//    var body: some View {
//        TabView {
//            LogView(catchManager: catchManager)
//                .tabItem {
//                    Label("Log", systemImage: "list.bullet")
//                }
//            
//            CalendarView(catchManager: catchManager)
//                .tabItem {
//                    Label("Fish", systemImage: "fish")
//                }
//            
//            StatsView(catchManager: catchManager)
//                .tabItem {
//                    Label("Stats", systemImage: "chart.bar")
//                }
//            
//            SettingsView(catchManager: catchManager)
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
//        }
//        .accentColor(.blue)
//        .background(Color.white)
//        .onAppear {
//            if !hasOnboarded {
//                showOnboarding = true
//                hasOnboarded = true
//            }
//        }
//        .sheet(isPresented: $showOnboarding) {
//            OnboardingView(hasSeenOnboarding: $showOnboarding)
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
