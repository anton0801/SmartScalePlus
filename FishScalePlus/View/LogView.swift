import SwiftUI

struct LogView: View {
    @EnvironmentObject var catchManager: CatchManager
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var showFilterMenu = false
    @State private var selectedCatch: FishCatch?
    
    enum FilterOption: String, CaseIterable {
        case all = "All Catches"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var filteredCatches: [FishCatch] {
        var catches = catchManager.catches
        
        // Apply time filter
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .today:
            catches = catches.filter { calendar.isDateInToday($0.date) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            catches = catches.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            catches = catches.filter { $0.date >= monthAgo }
        case .all:
            break
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            catches = catches.filter {
                $0.fishType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText) ||
                ($0.location?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return catches
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and filter bar
                    HStack(spacing: 12) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.textSecondary)
                            
                            TextField("Search catches...", text: $searchText)
                                .font(.bodyRegular(16))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Filter button
                        Button(action: { showFilterMenu.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.primaryBlue)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    if catchManager.isLoading {
                        LoadingView()
                    } else if filteredCatches.isEmpty {
                        EmptyCatchesView()
                    } else {
                        // Catches list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCatches) { catchItem in
                                    CatchCardView(catchItem: catchItem)
                                        .onTapGesture {
                                            selectedCatch = catchItem
                                        }
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                            }
                            .padding()
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: filteredCatches.count)
                    }
                }
            }
            .navigationTitle("Catch Log")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedCatch) { catchItem in
                CatchDetailView(catchItem: catchItem)
                    .environmentObject(catchManager)
            }
            .actionSheet(isPresented: $showFilterMenu) {
                ActionSheet(
                    title: Text("Filter Catches"),
                    buttons: FilterOption.allCases.map { option in
                        .default(Text(option.rawValue)) {
                            selectedFilter = option
                        }
                    } + [.cancel()]
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CatchCardView: View {
    let catchItem: FishCatch
    
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Fish icon with species color
            ZStack {
                Circle()
                    .fill(catchItem.fishType.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Text(catchItem.fishType.icon)
                    .font(.system(size: 28))
            }
            
            // Catch information
            VStack(alignment: .leading, spacing: 6) {
                Text(catchItem.fishType.rawValue)
                    .font(.displayMedium(18))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "scalemass")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text(catchItem.formattedWeight)
                            .font(.monoMedium(14))
                            .foregroundColor(.textSecondary)
                    }
                    
                    if catchItem.length != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                            Text(catchItem.formattedLength)
                                .font(.monoMedium(14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Text(catchItem.shortDate)
                    .font(.bodyRegular(12))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Chevron
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyCatchesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "fish")
                    .font(.system(size: 50))
                    .foregroundColor(.primaryBlue)
            }
            
            Text("No Catches Yet")
                .font(.displayBold(24))
                .foregroundColor(.textPrimary)
            
            Text("Start tracking your fishing adventures\nby adding your first catch!")
                .font(.bodyRegular(16))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .scaleEffect(isAnimating ? 1 : 0)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                        .offset(x: CGFloat(index - 1) * 30)
                }
            }
            
            Text("Loading catches...")
                .font(.bodyRegular(16))
                .foregroundColor(.textSecondary)
                .padding(.top)
            
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
            .environmentObject(CatchManager())
    }
}
