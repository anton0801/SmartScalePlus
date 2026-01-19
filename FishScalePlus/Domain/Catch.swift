import Foundation
import SwiftUI

// MARK: - Fish Catch Model
struct FishCatch: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fishType: FishSpecies
    var weight: Double // in kilograms
    var length: Double? // in centimeters
    var date: Date
    var notes: String
    var location: String?
    var bait: String?
    var weather: String?
    var userId: String
    
    var formattedWeight: String {
        return String(format: "%.2f kg", weight)
    }
    
    var formattedLength: String {
        guard let length = length else { return "N/A" }
        return String(format: "%.1f cm", length)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, fishType, weight, length, date, notes, location, bait, weather, userId
    }
    
    init(id: String = UUID().uuidString,
         fishType: FishSpecies,
         weight: Double,
         length: Double? = nil,
         date: Date = Date(),
         notes: String = "",
         location: String? = nil,
         bait: String? = nil,
         weather: String? = nil,
         userId: String) {
        self.id = id
        self.fishType = fishType
        self.weight = weight
        self.length = length
        self.date = date
        self.notes = notes
        self.location = location
        self.bait = bait
        self.weather = weather
        self.userId = userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fishType = try container.decode(FishSpecies.self, forKey: .fishType)
        weight = try container.decode(Double.self, forKey: .weight)
        length = try container.decodeIfPresent(Double.self, forKey: .length)
        
        // Handle date decoding
        if let timestamp = try? container.decode(Double.self, forKey: .date) {
            date = Date(timeIntervalSince1970: timestamp)
        } else {
            date = try container.decode(Date.self, forKey: .date)
        }
        
        notes = try container.decode(String.self, forKey: .notes)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        bait = try container.decodeIfPresent(String.self, forKey: .bait)
        weather = try container.decodeIfPresent(String.self, forKey: .weather)
        userId = try container.decode(String.self, forKey: .userId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fishType, forKey: .fishType)
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(length, forKey: .length)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(bait, forKey: .bait)
        try container.encodeIfPresent(weather, forKey: .weather)
        try container.encode(userId, forKey: .userId)
    }
}

// MARK: - Fish Species
enum FishSpecies: String, Identifiable, CaseIterable, Codable {
    
    case bass = "Bass"
    case trout = "Trout"
    case salmon = "Salmon"
    case pike = "Pike"
    case carp = "Carp"
    case catfish = "Catfish"
    case perch = "Perch"
    case walleye = "Walleye"
    case bluegill = "Bluegill"
    case crappie = "Crappie"
    case muskie = "Muskie"
    case striperBass = "Striper Bass"
    case redfish = "Redfish"
    case snapper = "Snapper"
    case grouper = "Grouper"
    case tuna = "Tuna"
    case marlin = "Marlin"
    case swordfish = "Swordfish"
    case other = "Other"
    
    var icon: String {
        return "🐟"
    }
    
    public var id: UUID { UUID() }
    
    var color: Color {
        switch self {
        case .bass, .striperBass: return Color(hex: "4CAF50")
        case .trout: return Color(hex: "FF9800")
        case .salmon: return Color(hex: "FF5722")
        case .pike: return Color(hex: "8BC34A")
        case .carp: return Color(hex: "FFC107")
        case .catfish: return Color(hex: "795548")
        case .perch: return Color(hex: "FFEB3B")
        case .walleye: return Color(hex: "9E9E9E")
        case .bluegill: return Color(hex: "2196F3")
        case .crappie: return Color(hex: "E91E63")
        case .muskie: return Color(hex: "009688")
        case .redfish: return Color(hex: "F44336")
        case .snapper: return Color(hex: "FF6F00")
        case .grouper: return Color(hex: "5D4037")
        case .tuna: return Color(hex: "1976D2")
        case .marlin: return Color(hex: "00BCD4")
        case .swordfish: return Color(hex: "607D8B")
        case .other: return Color.gray
        }
    }
}

// MARK: - Fish Species Statistics
struct FishSpeciesStats: Identifiable {
    let id = UUID()
    let species: FishSpecies
    let catchCount: Int
    let averageWeight: Double
    let maxWeight: Double
    let maxLength: Double?
    
    var formattedAverageWeight: String {
        String(format: "%.2f kg", averageWeight)
    }
    
    var formattedMaxWeight: String {
        String(format: "%.2f kg", maxWeight)
    }
    
    var formattedMaxLength: String {
        guard let length = maxLength else { return "N/A" }
        return String(format: "%.1f cm", length)
    }
}

struct CatchStatistics {
    var totalCatches: Int = 0
    var averageWeight: Double = 0.0
    var heaviestCatch: FishCatch?
    var longestCatch: FishCatch?
    var differentSpecies: Int = 0
    var bestDay: (date: Date, count: Int)?
    var catchesByMonth: [String: Int] = [:]
    var weightsByMonth: [String: Double] = [:]
    
    var formattedAverageWeight: String {
        String(format: "%.2f kg", averageWeight)
    }
    
    var formattedHeaviestWeight: String {
        guard let catchItem = heaviestCatch else { return "0 kg" }
        return String(format: "%.2f kg", catchItem.weight)
    }
    
    var formattedLongestLength: String {
        guard let catchItem = longestCatch, let length = catchItem.length else { return "N/A" }
        return String(format: "%.1f cm", length)
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var weightUnit: WeightUnit = .metric
    var lengthUnit: LengthUnit = .metric
    var dateFormat: DateFormatStyle = .standard
    
    enum WeightUnit: String, CaseIterable, Codable {
        case metric = "kg"
        case imperial = "lb"
        
        var displayName: String {
            switch self {
            case .metric: return "Kilograms (kg)"
            case .imperial: return "Pounds (lb)"
            }
        }
        
        func convert(from kg: Double) -> Double {
            switch self {
            case .metric: return kg
            case .imperial: return kg * 2.20462
            }
        }
        
        func convertToKg(from value: Double) -> Double {
            switch self {
            case .metric: return value
            case .imperial: return value / 2.20462
            }
        }
    }
    
    enum LengthUnit: String, CaseIterable, Codable {
        case metric = "cm"
        case imperial = "in"
        
        var displayName: String {
            switch self {
            case .metric: return "Centimeters (cm)"
            case .imperial: return "Inches (in)"
            }
        }
        
        func convert(from cm: Double) -> Double {
            switch self {
            case .metric: return cm
            case .imperial: return cm * 0.393701
            }
        }
        
        func convertToCm(from value: Double) -> Double {
            switch self {
            case .metric: return value
            case .imperial: return value / 0.393701
            }
        }
    }
    
    enum DateFormatStyle: String, CaseIterable, Codable {
        case standard = "MMM d, yyyy"
        case full = "MMMM d, yyyy"
        case short = "M/d/yy"
        
        var displayName: String {
            switch self {
            case .standard: return "Jan 1, 2024"
            case .full: return "January 1, 2024"
            case .short: return "1/1/24"
            }
        }
    }
}

// MARK: - Export Data
struct ExportData {
    let startDate: Date
    let endDate: Date
    let catches: [FishCatch]
    
    func generateCSV() -> String {
        var csv = "Date,Fish Type,Weight (kg),Length (cm),Location,Bait,Weather,Notes\n"
        
        for catchItem in catches {
            let dateStr = catchItem.shortDate
            let fishType = catchItem.fishType.rawValue
            let weight = String(format: "%.2f", catchItem.weight)
            let length = catchItem.length != nil ? String(format: "%.1f", catchItem.length!) : ""
            let location = catchItem.location?.replacingOccurrences(of: ",", with: ";") ?? ""
            let bait = catchItem.bait?.replacingOccurrences(of: ",", with: ";") ?? ""
            let weather = catchItem.weather?.replacingOccurrences(of: ",", with: ";") ?? ""
            let notes = catchItem.notes.replacingOccurrences(of: ",", with: ";")
            
            csv += "\(dateStr),\(fishType),\(weight),\(length),\(location),\(bait),\(weather),\(notes)\n"
        }
        
        return csv
    }
}
