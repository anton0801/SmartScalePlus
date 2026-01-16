import SwiftUI

struct CatchDetailsView: View {
    let catchItem: Catch
    @ObservedObject var catchManager: CatchManager
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Details").foregroundColor(.blue)) {
                HStack {
                    Text("Fish Type")
                    Spacer()
                    Text(catchItem.fishType)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Weight")
                    Spacer()
                    Text(String(format: "%.2f kg", catchItem.weight))
                        .foregroundColor(.gray)
                }
                if let length = catchItem.length {
                    HStack {
                        Text("Length")
                        Spacer()
                        Text(String(format: "%.0f cm", length))
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Date")
                    Spacer()
                    Text(DateFormatter.localizedString(from: catchItem.date, dateStyle: .medium, timeStyle: .short))
                        .foregroundColor(.gray)
                }
                if let notes = catchItem.notes {
                    HStack {
                        Text("Notes")
                        Spacer()
                        Text(notes)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .navigationTitle("Catch Details")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
                .foregroundColor(.blue)
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddCatchView(catchManager: catchManager, existingCatch: catchItem)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Catch"),
                message: Text("Are you sure?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = catchManager.catches.firstIndex(where: { $0.id == catchItem.id }) {
                        catchManager.catches.remove(at: index)
                        catchManager.save()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .background(Color.white)
    }
}
