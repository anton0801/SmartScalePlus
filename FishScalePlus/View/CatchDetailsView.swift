import SwiftUI

struct CatchDetailView: View {
    let catchItem: FishCatch
    @EnvironmentObject var catchManager: CatchManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var headerOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with fish illustration
                    ZStack(alignment: .bottom) {
                        // Background gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                catchItem.fishType.color,
                                catchItem.fishType.color.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 220)
                        
                        // Fish icon
                        VStack(spacing: 12) {
                            Text(catchItem.fishType.icon)
                                .font(.system(size: 80))
                            
                            Text(catchItem.fishType.rawValue)
                                .font(.displayBold(28))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 30)
                    }
                    .offset(y: headerOffset)
                    
                    // Details card
                    VStack(spacing: 24) {
                        // Weight and Length
                        HStack(spacing: 20) {
                            DetailMetricCard(
                                icon: "scalemass.fill",
                                title: "Weight",
                                value: catchItem.formattedWeight,
                                color: .primaryBlue
                            )
                            
                            if catchItem.length != nil {
                                DetailMetricCard(
                                    icon: "ruler.fill",
                                    title: "Length",
                                    value: catchItem.formattedLength,
                                    color: .seaGreen
                                )
                            }
                        }
                        
                        Divider()
                        
                        // Date and time
                        DetailRow(
                            icon: "calendar",
                            title: "Date & Time",
                            value: catchItem.formattedDate,
                            color: .sunriseYellow
                        )
                        
                        // Location
                        if let location = catchItem.location, !location.isEmpty {
                            DetailRow(
                                icon: "location.fill",
                                title: "Location",
                                value: location,
                                color: .coralOrange
                            )
                        }
                        
                        // Bait
                        if let bait = catchItem.bait, !bait.isEmpty {
                            DetailRow(
                                icon: "circle.hexagongrid.fill",
                                title: "Bait Used",
                                value: bait,
                                color: .primaryBlue
                            )
                        }
                        
                        // Weather
                        if let weather = catchItem.weather, !weather.isEmpty {
                            DetailRow(
                                icon: "cloud.sun.fill",
                                title: "Weather",
                                value: weather,
                                color: .seaGreen
                            )
                        }
                        
                        // Notes
                        if !catchItem.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "note.text")
                                        .font(.system(size: 16))
                                        .foregroundColor(.textSecondary)
                                    
                                    Text("Notes")
                                        .font(.displayMedium(16))
                                        .foregroundColor(.textPrimary)
                                }
                                
                                Text(catchItem.notes)
                                    .font(.bodyRegular(15))
                                    .foregroundColor(.textSecondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.background)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: { showEditSheet = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit")
                                }
                                .font(.displayMedium(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryBlue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { showDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                .font(.displayMedium(16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.coralOrange)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .offset(y: -20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditCatchView(catchItem: catchItem)
                    .environmentObject(catchManager)
            }
            .alert("Delete Catch", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    catchManager.deleteCatch(catchItem)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this catch? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Detail Metric Card
struct DetailMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.bodyRegular(14))
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.monoMedium(20))
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.background)
        .cornerRadius(16)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodyRegular(14))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.displayMedium(16))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Edit Catch View
struct EditCatchView: View {
    let catchItem: FishCatch
    @EnvironmentObject var catchManager: CatchManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFishType: FishSpecies
    @State private var weight: String
    @State private var length: String
    @State private var selectedDate: Date
    @State private var location: String
    @State private var bait: String
    @State private var weather: String
    @State private var notes: String
    
    init(catchItem: FishCatch) {
        self.catchItem = catchItem
        _selectedFishType = State(initialValue: catchItem.fishType)
        _weight = State(initialValue: String(format: "%.2f", catchItem.weight))
        _length = State(initialValue: catchItem.length != nil ? String(format: "%.1f", catchItem.length!) : "")
        _selectedDate = State(initialValue: catchItem.date)
        _location = State(initialValue: catchItem.location ?? "")
        _bait = State(initialValue: catchItem.bait ?? "")
        _weather = State(initialValue: catchItem.weather ?? "")
        _notes = State(initialValue: catchItem.notes)
    }
    
    var isValid: Bool {
        !weight.isEmpty && Double(weight) != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Same form as AddCatchView but with pre-filled data
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Fish Type", icon: "fish")
                        FishTypePicker(selectedFishType: $selectedFishType)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Weight (kg)", icon: "scalemass", required: true)
                        HStack {
                            TextField("0.00", text: $weight)
                                .keyboardType(.decimalPad)
                                .font(.monoMedium(20))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            Text("kg")
                                .font(.displayMedium(18))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Length (cm)", icon: "ruler")
                        HStack {
                            TextField("Optional", text: $length)
                                .keyboardType(.decimalPad)
                                .font(.monoMedium(20))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            Text("cm")
                                .font(.displayMedium(18))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Date & Time", icon: "calendar")
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Location", icon: "location")
                        TextField("e.g., Lake Michigan", text: $location)
                            .font(.bodyRegular(16))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Bait Used", icon: "circle.hexagongrid")
                        TextField("e.g., Worm, Lure", text: $bait)
                            .font(.bodyRegular(16))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Weather", icon: "cloud.sun")
                        TextField("e.g., Sunny, 75°F", text: $weather)
                            .font(.bodyRegular(16))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Notes", icon: "note.text")
                        TextEditor(text: $notes)
                            .font(.bodyRegular(16))
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.divider, lineWidth: 1))
                    }
                    
                    Button(action: updateCatch) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Update Catch")
                        }
                        .font(.displayMedium(18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.primaryBlue)
                        .cornerRadius(16)
                        .opacity(isValid ? 1 : 0.5)
                    }
                    .disabled(!isValid)
                }
                .padding()
            }
            .background(Color.background)
            .navigationTitle("Edit Catch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func updateCatch() {
        guard let weightValue = Double(weight) else { return }
        
        let lengthValue = Double(length)
        
        let updatedCatch = FishCatch(
            id: catchItem.id,
            fishType: selectedFishType,
            weight: weightValue,
            length: lengthValue,
            date: selectedDate,
            notes: notes,
            location: location.isEmpty ? nil : location,
            bait: bait.isEmpty ? nil : bait,
            weather: weather.isEmpty ? nil : weather,
            userId: catchItem.userId
        )
        
        catchManager.updateCatch(updatedCatch)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct CatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CatchDetailView(catchItem: FishCatch(
            fishType: .bass,
            weight: 5.2,
            length: 45.0,
            date: Date(),
            notes: "Great catch at sunset!",
            location: "Lake Michigan",
            bait: "Worm",
            weather: "Sunny, 75°F",
            userId: "test-user"
        ))
        .environmentObject(CatchManager())
    }
}
