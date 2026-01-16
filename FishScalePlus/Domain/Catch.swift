import Foundation

struct Catch: Codable, Identifiable {
    var id: UUID
    var fishType: String
    var weight: Double // in kg
    var length: Double? // in cm
    var date: Date
    var notes: String?
    
    init(id: UUID = UUID(), fishType: String, weight: Double, length: Double?, date: Date, notes: String?) {
        self.id = id
        self.fishType = fishType
        self.weight = weight
        self.length = length
        self.date = date
        self.notes = notes
    }
}
