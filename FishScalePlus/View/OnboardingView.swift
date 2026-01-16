import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            VStack {
                Image(systemName: "fish.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                Text("Track fish weight and size")
                    .font(.title)
                    .padding()
            }
            .background(Color.white)
            
            VStack {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Save every catch easily")
                    .font(.title)
                    .padding()
            }
            .background(Color.white)
            
            VStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                Text("See your fishing progress")
                    .font(.title)
                    .padding()
            }
            .background(Color.white)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

#Preview {
    OnboardingView()
}
