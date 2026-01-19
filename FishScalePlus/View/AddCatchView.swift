import SwiftUI

struct AddCatchView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var catchManager: CatchManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var selectedFishType: FishSpecies = .bass
    @State private var weight: String = ""
    @State private var length: String = ""
    @State private var selectedDate = Date()
    @State private var location: String = ""
    @State private var bait: String = ""
    @State private var weather: String = ""
    @State private var notes: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var keyboardHeight: CGFloat = 0
    
    var isValid: Bool {
        !weight.isEmpty && Double(weight) != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
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
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "fish.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Record Your Catch")
                                .font(.displayBold(24))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.top)
                        
                        // Fish Type Picker
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Fish Type", icon: "fish")
                            
                            FishTypePicker(selectedFishType: $selectedFishType)
                        }
                        
                        // Weight Input
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
                        
                        // Length Input (Optional)
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
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Date & Time", icon: "calendar")
                            
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Location (Optional)
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Location", icon: "location")
                            
                            TextField("e.g., Lake Michigan", text: $location)
                                .font(.bodyRegular(16))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Bait (Optional)
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Bait Used", icon: "circle.hexagongrid")
                            
                            TextField("e.g., Worm, Lure", text: $bait)
                                .font(.bodyRegular(16))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Weather (Optional)
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Weather", icon: "cloud.sun")
                            
                            TextField("e.g., Sunny, 75°F", text: $weather)
                                .font(.bodyRegular(16))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Notes", icon: "note.text")
                            
                            TextEditor(text: $notes)
                                .font(.bodyRegular(16))
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.divider, lineWidth: 1)
                                )
                        }
                        
                        // Save Button
                        Button(action: saveCatch) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Save Catch")
                                    .font(.displayMedium(18))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.primaryBlue,
                                        Color.seaGreen
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            .opacity(isValid ? 1 : 0.5)
                        }
                        .disabled(!isValid)
                        .padding(.top)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                .padding(.bottom, keyboardHeight)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        keyboardHeight = keyboardFrame.height - 40
                    }
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation {
                    keyboardHeight = 0
                }
            }
        }
    }
    
    private func saveCatch() {
        guard let weightValue = Double(weight) else {
            errorMessage = "Please enter a valid weight"
            showError = true
            return
        }
        
        guard let userId = authManager.currentUserId else {
            errorMessage = "User not authenticated"
            showError = true
            return
        }
        
        let lengthValue = Double(length)
        
        let newCatch = FishCatch(
            fishType: selectedFishType,
            weight: weightValue,
            length: lengthValue,
            date: selectedDate,
            notes: notes,
            location: location.isEmpty ? nil : location,
            bait: bait.isEmpty ? nil : bait,
            weather: weather.isEmpty ? nil : weather,
            userId: userId
        )
        
        catchManager.addCatch(newCatch)
        isPresented = false
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    var required: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryBlue)
            
            Text(title)
                .font(.displayMedium(16))
                .foregroundColor(.textPrimary)
            
            if required {
                Text("*")
                    .foregroundColor(.coralOrange)
            }
            
            Spacer()
        }
    }
}

// MARK: - Fish Type Picker
struct FishTypePicker: View {
    @Binding var selectedFishType: FishSpecies
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(FishSpecies.allCases, id: \.self) { species in
                FishTypeButton(
                    species: species,
                    isSelected: selectedFishType == species,
                    action: { selectedFishType = species }
                )
            }
        }
    }
}

struct FishTypeButton: View {
    let species: FishSpecies
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(species.icon)
                    .font(.system(size: 32))
                
                Text(species.rawValue)
                    .font(.bodyRegular(12))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? species.color : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? species.color : Color.divider, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct AddCatchView_Previews: PreviewProvider {
    static var previews: some View {
        AddCatchView(isPresented: .constant(true))
            .environmentObject(CatchManager())
            .environmentObject(AuthenticationManager())
    }
}
