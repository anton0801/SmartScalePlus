import SwiftUI

struct StatsView: View {
    @ObservedObject var catchManager: CatchManager
    
    var totalCatches: Int { catchManager.catches.count }
    var averageWeight: Double {
        guard !catchManager.catches.isEmpty else { return 0 }
        return catchManager.catches.map { $0.weight }.reduce(0, +) / Double(totalCatches)
    }
    var heaviestCatch: Double { catchManager.catches.map { $0.weight }.max() ?? 0 }
    var differentTypes: Int { Set(catchManager.catches.map { $0.fishType }).count }
    var longestFish: Double { catchManager.catches.compactMap { $0.length }.max() ?? 0 }
    
    // Simple text-based "graphs" since iOS 14 has no built-in Charts
    var catchesByMonth: [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return Dictionary(grouping: catchManager.catches) { formatter.string(from: $0.date) }
            .mapValues { $0.count }
            .sorted(by: { formatter.date(from: $0.key)! > formatter.date(from: $1.key)! })
            .reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    StatCard(title: "Total Catches", value: "\(totalCatches)", icon: "list.bullet")
                    StatCard(title: "Average Weight", value: String(format: "%.2f kg", averageWeight), icon: "scalemass")
                    StatCard(title: "Heaviest Catch", value: String(format: "%.2f kg", heaviestCatch), icon: "trophy")
                    StatCard(title: "Different Fish Types", value: "\(differentTypes)", icon: "fish")
                    StatCard(title: "Longest Fish", value: String(format: "%.0f cm", longestFish), icon: "ruler")
                    
                    Section(header: Text("Catches by Month").font(.headline).foregroundColor(.blue)) {
                        ForEach(catchesByMonth.keys.sorted(by: >), id: \.self) { month in
                            HStack {
                                Text(month)
                                Spacer()
                                Text("\(catchesByMonth[month] ?? 0)")
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Stats")
            .background(Color.white)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
