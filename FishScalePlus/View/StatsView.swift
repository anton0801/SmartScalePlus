import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var catchManager: CatchManager
    @State private var selectedTimeFrame: TimeFrame = .month
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    var statistics: CatchStatistics {
        catchManager.getStatistics()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if catchManager.catches.isEmpty {
                    EmptyStatsView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Overview Cards
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatsCard(
                                    title: "Total Catches",
                                    value: "\(statistics.totalCatches)",
                                    icon: "fish.fill",
                                    color: .primaryBlue
                                )
                                
                                StatsCard(
                                    title: "Avg Weight",
                                    value: statistics.formattedAverageWeight,
                                    icon: "scalemass.fill",
                                    color: .seaGreen
                                )
                                
                                StatsCard(
                                    title: "Heaviest",
                                    value: statistics.formattedHeaviestWeight,
                                    icon: "trophy.fill",
                                    color: .sunriseYellow
                                )
                                
                                StatsCard(
                                    title: "Species",
                                    value: "\(statistics.differentSpecies)",
                                    icon: "list.bullet",
                                    color: .coralOrange
                                )
                            }
                            
                            // Best Catches Section
                            if let heaviest = statistics.heaviestCatch {
                                BestCatchCard(
                                    title: "Heaviest Catch",
                                    catchItem: heaviest,
                                    icon: "trophy.fill",
                                    color: .sunriseYellow
                                )
                            }
                            
                            if let longest = statistics.longestCatch {
                                BestCatchCard(
                                    title: "Longest Catch",
                                    catchItem: longest,
                                    icon: "ruler.fill",
                                    color: .seaGreen
                                )
                            }
                            
                            // Best Day
                            if let bestDay = statistics.bestDay {
                                BestDayCard(date: bestDay.date, count: bestDay.count)
                            }
                            
                            // Weight Trend Chart
                            if !catchManager.catches.isEmpty {
                                WeightTrendChart(catches: catchManager.catches)
                            }
                            
                            // Monthly Catches Chart
                            if !statistics.catchesByMonth.isEmpty {
                                MonthlyCatchesChart(data: statistics.catchesByMonth)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.monoMedium(24))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.bodyRegular(13))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Best Catch Card
struct BestCatchCard: View {
    let title: String
    let catchItem: FishCatch
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.displayBold(18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Text(catchItem.fishType.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(catchItem.fishType.rawValue)
                        .font(.displayMedium(18))
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 12) {
                        Text(catchItem.formattedWeight)
                            .font(.monoMedium(16))
                            .foregroundColor(.primaryBlue)
                        
                        if let length = catchItem.length {
                            Text(String(format: "%.1f cm", length))
                                .font(.monoMedium(16))
                                .foregroundColor(.seaGreen)
                        }
                    }
                    
                    Text(catchItem.shortDate)
                        .font(.bodyRegular(13))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Best Day Card
struct BestDayCard: View {
    let date: Date
    let count: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.sunriseYellow)
                
                Text("Best Fishing Day")
                    .font(.displayBold(18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.displayMedium(16))
                        .foregroundColor(.textPrimary)
                    
                    Text("\(count) catches")
                        .font(.bodyRegular(14))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.sunriseYellow.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text("\(count)")
                        .font(.displayBold(28))
                        .foregroundColor(.sunriseYellow)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Weight Trend Chart
struct WeightTrendChart: View {
    let catches: [FishCatch]
    
    var sortedCatches: [FishCatch] {
        catches.sorted { $0.date < $1.date }.suffix(10)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18))
                    .foregroundColor(.primaryBlue)
                
                Text("Weight Trend")
                    .font(.displayBold(18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            if #available(iOS 16.0, *) {
                Chart(sortedCatches) { catchItem in
                    LineMark(
                        x: .value("Date", catchItem.date, unit: .day),
                        y: .value("Weight", catchItem.weight)
                    )
                    .foregroundStyle(Color.primaryBlue)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", catchItem.date, unit: .day),
                        y: .value("Weight", catchItem.weight)
                    )
                    .foregroundStyle(Color.primaryBlue)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                SimpleLineChart(catches: Array(sortedCatches))
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Simple Line Chart (iOS 14-15 fallback)
struct SimpleLineChart: View {
    let catches: [FishCatch]
    
    var body: some View {
        GeometryReader { geometry in
            let maxWeight = catches.map { $0.weight }.max() ?? 1
            let minWeight = catches.map { $0.weight }.min() ?? 0
            let range = maxWeight - minWeight
            
            Path { path in
                for (index, catchItem) in catches.enumerated() {
                    let x = geometry.size.width * CGFloat(index) / CGFloat(max(catches.count - 1, 1))
                    let normalizedWeight = (catchItem.weight - minWeight) / max(range, 0.1)
                    let y = geometry.size.height * (1 - CGFloat(normalizedWeight))
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.primaryBlue, lineWidth: 3)
            
            ForEach(Array(catches.enumerated()), id: \.offset) { index, catchItem in
                let x = geometry.size.width * CGFloat(index) / CGFloat(max(catches.count - 1, 1))
                let normalizedWeight = (catchItem.weight - minWeight) / max(range, 0.1)
                let y = geometry.size.height * (1 - CGFloat(normalizedWeight))
                
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        .padding()
    }
}

// MARK: - Monthly Catches Chart
struct MonthlyCatchesChart: View {
    let data: [String: Int]
    
    var sortedData: [(String, Int)] {
        data.sorted { $0.key < $1.key }.suffix(6)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.seaGreen)
                
                Text("Monthly Catches")
                    .font(.displayBold(18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(sortedData, id: \.0) { month, count in
                    VStack(spacing: 8) {
                        Text("\(count)")
                            .font(.monoMedium(12))
                            .foregroundColor(.textSecondary)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.seaGreen)
                            .frame(width: 40, height: CGFloat(count) * 10)
                        
                        Text(month.prefix(3))
                            .font(.bodyRegular(10))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 180)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Empty Stats View
struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.primaryBlue)
            }
            
            Text("No Statistics Yet")
                .font(.displayBold(24))
                .foregroundColor(.textPrimary)
            
            Text("Start adding catches to see\nyour fishing statistics")
                .font(.bodyRegular(16))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(CatchManager())
    }
}
