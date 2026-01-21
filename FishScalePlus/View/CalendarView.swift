import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var catchManager: CatchManager
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showCatchesForDate: Date?
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var datesWithCatches: Set<Date> {
        Set(catchManager.catches.map { calendar.startOfDay(for: $0.date) })
    }
    
    var catchesForSelectedDate: [FishCatch] {
        if let date = showCatchesForDate {
            return catchManager.getCatchesForDate(date)
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Month selector
                        MonthSelectorView(
                            currentMonth: $currentMonth,
                            onPrevious: previousMonth,
                            onNext: nextMonth
                        )
                        
                        // Calendar grid
                        VStack(spacing: 12) {
                            // Days of week header
                            HStack(spacing: 0) {
                                ForEach(daysOfWeek, id: \.self) { day in
                                    Text(day)
                                        .font(.bodyRegular(12))
                                        .foregroundColor(.textSecondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 8)
                            
                            // Calendar days
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                                ForEach(generateDatesForMonth(), id: \.self) { date in
                                    CalendarDayCell(
                                        date: date,
                                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                                        isToday: calendar.isDateInToday(date),
                                        hasCatches: datesWithCatches.contains(calendar.startOfDay(for: date)),
                                        catchCount: catchManager.getCatchesForDate(date).count,
                                        isSelected: showCatchesForDate != nil && calendar.isDate(date, inSameDayAs: showCatchesForDate!)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            if datesWithCatches.contains(calendar.startOfDay(for: date)) {
                                                showCatchesForDate = date
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        
                        // Statistics for current month
                        MonthStatisticsCard(
                            catches: catchesForCurrentMonth,
                            monthName: monthYearString(from: currentMonth)
                        )
                        
                        // Catches for selected date
                        if let date = showCatchesForDate, !catchesForSelectedDate.isEmpty {
                            DayCatchesCard(
                                date: date,
                                catches: catchesForSelectedDate,
                                onClose: {
                                    withAnimation {
                                        showCatchesForDate = nil
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var catchesForCurrentMonth: [FishCatch] {
        catchManager.catches.filter { catchItem in
            calendar.isDate(catchItem.date, equalTo: currentMonth, toGranularity: .month)
        }
    }
    
    private func generateDatesForMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = monthFirstWeek.start
        
        // Generate 6 weeks to cover all possible month layouts
        for _ in 0..<42 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Month Selector
struct MonthSelectorView: View {
    @Binding var currentMonth: Date
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            Spacer()
            
            Text(monthYearText)
                .font(.displayBold(20))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasCatches: Bool
    let catchCount: Int
    let isSelected: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.bodyRegular(16))
                .foregroundColor(textColor)
            
            if hasCatches {
                ZStack {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 6, height: 6)
                    
                    if catchCount > 1 {
                        Text("\(catchCount)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            } else {
                Spacer()
                    .frame(height: 6)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
        )
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .textSecondary.opacity(0.3)
        } else if isToday {
            return .white
        } else {
            return .textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return Color.primaryBlue
        } else if isSelected {
            return Color.primaryBlue.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        isSelected ? Color.primaryBlue : Color.clear
    }
    
    private var dotColor: Color {
        if isToday {
            return .sunriseYellow
        } else {
            return .seaGreen
        }
    }
}

// MARK: - Month Statistics Card
struct MonthStatisticsCard: View {
    let catches: [FishCatch]
    let monthName: String
    
    var totalWeight: Double {
        catches.reduce(0) { $0 + $1.weight }
    }
    
    var averageWeight: Double {
        guard !catches.isEmpty else { return 0 }
        return totalWeight / Double(catches.count)
    }
    
    var differentSpecies: Int {
        Set(catches.map { $0.fishType }).count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.primaryBlue)
                Text(monthName)
                    .font(.displayBold(18))
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            if catches.isEmpty {
                Text("No catches this month")
                    .font(.bodyRegular(14))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                HStack(spacing: 12) {
                    MonthStatItem(
                        title: "Catches",
                        value: "\(catches.count)",
                        icon: "fish.fill",
                        color: .primaryBlue
                    )
                    
                    MonthStatItem(
                        title: "Avg Weight",
                        value: String(format: "%.1f kg", averageWeight),
                        icon: "scalemass.fill",
                        color: .seaGreen
                    )
                    
                    MonthStatItem(
                        title: "Species",
                        value: "\(differentSpecies)",
                        icon: "list.bullet",
                        color: .sunriseYellow
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct MonthStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.monoMedium(16))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.bodyRegular(11))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Day Catches Card
struct DayCatchesCard: View {
    let date: Date
    let catches: [FishCatch]
    let onClose: () -> Void
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Catches")
                        .font(.displayBold(18))
                        .foregroundColor(.textPrimary)
                    
                    Text(dateString)
                        .font(.bodyRegular(14))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.textSecondary)
                }
            }
            
            ForEach(catches) { catchItem in
                CalendarCatchRow(catchItem: catchItem)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}

struct CalendarCatchRow: View {
    let catchItem: FishCatch
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: catchItem.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Species icon
            ZStack {
                Circle()
                    .fill(catchItem.fishType.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(catchItem.fishType.icon)
                    .font(.system(size: 24))
            }
            
            // Catch info
            VStack(alignment: .leading, spacing: 4) {
                Text(catchItem.fishType.rawValue)
                    .font(.displayMedium(16))
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 8) {
                    Text(catchItem.formattedWeight)
                        .font(.monoMedium(13))
                        .foregroundColor(.primaryBlue)
                    
                    if catchItem.length != nil {
                        Text("•")
                            .foregroundColor(.textSecondary)
                        Text(catchItem.formattedLength)
                            .font(.monoMedium(13))
                            .foregroundColor(.seaGreen)
                    }
                }
            }
            
            Spacer()
            
            Text(timeString)
                .font(.bodyRegular(12))
                .foregroundColor(.textSecondary)
        }
        .padding(12)
        .background(Color.background)
        .cornerRadius(12)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(CatchManager())
    }
}
