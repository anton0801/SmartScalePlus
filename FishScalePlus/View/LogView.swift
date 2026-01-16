
import SwiftUI

struct LogView: View {
    @ObservedObject var catchManager: CatchManager
    @State private var showingAdd = false
    @State private var filterDate: Date? = nil
    @State private var filterType: String = ""
    
    var filteredCatches: [Catch] {
        catchManager.catches.sorted(by: { $0.date > $1.date }).filter { catchItem in
            let dateMatch = filterDate == nil || Calendar.current.isDate(catchItem.date, inSameDayAs: filterDate!)
            let typeMatch = filterType.isEmpty || catchItem.fishType.lowercased().contains(filterType.lowercased())
            return dateMatch && typeMatch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Filter by type", text: $filterType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Filter by date", selection: Binding(get: { filterDate ?? Date() }, set: { filterDate = $0 }), displayedComponents: .date)
                        .labelsHidden()
                    Button("Clear") {
                        filterType = ""
                        filterDate = nil
                    }
                }
                .padding()
                
                List {
                    ForEach(filteredCatches) { catchItem in
                        NavigationLink(destination: CatchDetailsView(catchItem: catchItem, catchManager: catchManager)) {
                            HStack {
                                Image(systemName: "fish.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text(catchItem.fishType)
                                        .font(.headline)
                                    Text(DateFormatter.localizedString(from: catchItem.date, dateStyle: .short, timeStyle: .short))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(String(format: "%.2f kg", catchItem.weight))
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            if let catchIndex = catchManager.catches.firstIndex(where: { $0.id == filteredCatches[index].id }) {
                                catchManager.catches.remove(at: catchIndex)
                            }
                        }
                        catchManager.save()
                    }
                }
            }
            .navigationTitle("Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddCatchView(catchManager: catchManager)
            }
            .background(Color.white)
        }
    }
}

