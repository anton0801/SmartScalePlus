import Foundation

class CatchManager: ObservableObject {
    @Published var catches: [Catch] = []
    
    init() {
        load()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(catches) {
            UserDefaults.standard.set(data, forKey: "catches")
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "catches") {
            if let decoded = try? JSONDecoder().decode([Catch].self, from: data) {
                catches = decoded
            }
        }
    }
    
    func reset() {
        catches = []
        save()
    }
    
    func exportCSV() -> String {
        var csv = "ID,Fish Type,Weight (kg),Length (cm),Date,Notes\n"
        for catchItem in catches {
            let lengthStr = catchItem.length != nil ? String(catchItem.length!) : ""
            let dateStr = DateFormatter.localizedString(from: catchItem.date, dateStyle: .short, timeStyle: .short)
            let notesStr = catchItem.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(catchItem.id),\(catchItem.fishType),\(catchItem.weight),\(lengthStr),\(dateStr),\(notesStr)\n"
        }
        return csv
    }
}
