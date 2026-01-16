import SwiftUI

struct AddCatchView: View {
    @ObservedObject var catchManager: CatchManager
    var existingCatch: Catch?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fishType: String
    @State private var weight: String
    @State private var length: String
    @State private var date: Date
    @State private var notes: String
    
    init(catchManager: CatchManager, existingCatch: Catch? = nil) {
        self.catchManager = catchManager
        self.existingCatch = existingCatch
        _fishType = State(initialValue: existingCatch?.fishType ?? "")
        _weight = State(initialValue: existingCatch != nil ? String(existingCatch!.weight) : "")
        _length = State(initialValue: existingCatch?.length != nil ? String(existingCatch!.length!) : "")
        _date = State(initialValue: existingCatch?.date ?? Date())
        _notes = State(initialValue: existingCatch?.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Catch Details").foregroundColor(.blue)) {
                    TextField("Fish Type", text: $fishType)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Length (cm, optional)", text: $length)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }
            }
            .navigationTitle(existingCatch == nil ? "Add Catch" : "Edit Catch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: { presentationMode.wrappedValue.dismiss() })
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !fishType.isEmpty, let weightDouble = Double(weight) else { return }
                        let lengthDouble = Double(length)
                        let newCatch = Catch(id: existingCatch?.id ?? UUID(), fishType: fishType, weight: weightDouble, length: lengthDouble, date: date, notes: notes)
                        if let existing = existingCatch, let index = catchManager.catches.firstIndex(where: { $0.id == existing.id }) {
                            catchManager.catches[index] = newCatch
                        } else {
                            catchManager.catches.append(newCatch)
                        }
                        catchManager.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
            }
            .background(Color.white)
        }
    }
}
