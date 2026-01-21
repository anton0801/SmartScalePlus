import SwiftUI

struct FishSpeciesView: View {
    @EnvironmentObject var catchManager: CatchManager
    @State private var selectedSpecies: FishSpecies?
    
    var speciesStats: [FishSpeciesStats] {
        catchManager.getSpeciesStatistics()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if catchManager.catches.isEmpty {
                    EmptySpeciesView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(speciesStats) { stats in
                                SpeciesStatsCard(stats: stats)
                                    .onTapGesture {
                                        selectedSpecies = stats.species
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Fish Species")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSpecies) { species in
                SpeciesDetailView(species: species)
                    .environmentObject(catchManager)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Species Stats Card
struct SpeciesStatsCard: View {
    let stats: FishSpeciesStats
    
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Species icon and color
            ZStack {
                Circle()
                    .fill(stats.species.color.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                VStack(spacing: 4) {
                    Text(stats.species.icon)
                        .font(.system(size: 32))
                    
                    Text("\(stats.catchCount)")
                        .font(.monoMedium(14))
                        .foregroundColor(stats.species.color)
                }
            }
            
            // Stats information
            VStack(alignment: .leading, spacing: 8) {
                Text(stats.species.rawValue)
                    .font(.displayBold(20))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 16) {
                    StatPill(
                        icon: "scalemass",
                        label: "Avg",
                        value: stats.formattedAverageWeight,
                        color: .primaryBlue
                    )
                    
                    StatPill(
                        icon: "trophy",
                        label: "Best",
                        value: stats.formattedMaxWeight,
                        color: .sunriseYellow
                    )
                }
                
                if stats.maxLength != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "ruler")
                            .font(.system(size: 10))
                            .foregroundColor(.textSecondary)
                        Text("Longest: \(stats.formattedMaxLength)")
                            .font(.bodyRegular(12))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(stats.catchCount) * 0.05)) {
                appear = true
            }
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(.textSecondary)
                Text(value)
                    .font(.monoMedium(11))
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Empty Species View
struct EmptySpeciesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.seaGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "fish.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.seaGreen)
            }
            
            Text("No Species Data")
                .font(.displayBold(24))
                .foregroundColor(.textPrimary)
            
            Text("Add some catches to see\nspecies statistics")
                .font(.bodyRegular(16))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Species Detail View
struct SpeciesDetailView: View {
    let species: FishSpecies
    @EnvironmentObject var catchManager: CatchManager
    @Environment(\.presentationMode) var presentationMode
    
    var catches: [FishCatch] {
        catchManager.getCatchesBySpecies(species)
    }
    
    var totalWeight: Double {
        catches.reduce(0) { $0 + $1.weight }
    }
    
    var averageWeight: Double {
        guard !catches.isEmpty else { return 0 }
        return totalWeight / Double(catches.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                species.color,
                                                species.color.opacity(0.7)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Text(species.icon)
                                    .font(.system(size: 50))
                            }
                            
                            Text(species.rawValue)
                                .font(.displayBold(28))
                                .foregroundColor(.textPrimary)
                            
                            // Summary stats
                            HStack(spacing: 20) {
                                SummaryStatCard(
                                    title: "Total",
                                    value: "\(catches.count)",
                                    icon: "number",
                                    color: species.color
                                )
                                
                                SummaryStatCard(
                                    title: "Avg Weight",
                                    value: String(format: "%.2f kg", averageWeight),
                                    icon: "scalemass",
                                    color: .primaryBlue
                                )
                                
                                SummaryStatCard(
                                    title: "Total Weight",
                                    value: String(format: "%.2f kg", totalWeight),
                                    icon: "sum",
                                    color: .sunriseYellow
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        
                        // Catches list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Catches")
                                .font(.displayBold(20))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal)
                            
                            ForEach(catches) { catchItem in
                                SimpleCatchCard(catchItem: catchItem)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Summary Stat Card
struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.monoMedium(16))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.bodyRegular(11))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SimpleCatchCard: View {
    let catchItem: FishCatch
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(catchItem.formattedWeight)
                    .font(.monoMedium(18))
                    .foregroundColor(.textPrimary)
                
                if catchItem.length != nil {
                    Text(catchItem.formattedLength)
                        .font(.bodyRegular(14))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Text(catchItem.shortDate)
                .font(.bodyRegular(14))
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FishSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        FishSpeciesView()
            .environmentObject(CatchManager())
    }
}
