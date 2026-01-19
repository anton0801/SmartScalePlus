
import Foundation
import Firebase
import FirebaseDatabase
import Combine

class CatchManager: ObservableObject {
    @Published var catches: [FishCatch] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var databaseRef: DatabaseReference?
    private var catchesRef: DatabaseReference?
    private var observerHandle: DatabaseHandle?
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Firebase Operations
    
    func startListening(userId: String) {
        catchesRef = databaseRef?.child("catches").child(userId)
        
        observerHandle = catchesRef?.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var fetchedCatches: [FishCatch] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let fishCatch = try? JSONDecoder().decode(FishCatch.self, from: jsonData) {
                    fetchedCatches.append(fishCatch)
                }
            }
            
            DispatchQueue.main.async {
                self.catches = fetchedCatches.sorted { $0.date > $1.date }
                self.isLoading = false
            }
        }
    }
    
    func stopListening() {
        if let handle = observerHandle, let ref = catchesRef {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    func addCatch(_ fishCatch: FishCatch) {
        guard let userId = fishCatch.userId as String?,
              let catchesRef = databaseRef?.child("catches").child(userId).child(fishCatch.id) else {
            self.error = "Unable to save catch"
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(fishCatch)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            catchesRef.setValue(json) { [weak self] error, _ in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func updateCatch(_ fishCatch: FishCatch) {
        guard let userId = fishCatch.userId as String?,
              let catchesRef = databaseRef?.child("catches").child(userId).child(fishCatch.id) else {
            self.error = "Unable to update catch"
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(fishCatch)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            catchesRef.setValue(json) { [weak self] error, _ in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.error = error.localizedDescription
                    }
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteCatch(_ fishCatch: FishCatch) {
        guard let userId = fishCatch.userId as String?,
              let catchesRef = databaseRef?.child("catches").child(userId).child(fishCatch.id) else {
            self.error = "Unable to delete catch"
            return
        }
        
        catchesRef.removeValue { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func deleteAllCatches(userId: String) {
        guard let catchesRef = databaseRef?.child("catches").child(userId) else {
            self.error = "Unable to delete catches"
            return
        }
        
        catchesRef.removeValue { [weak self] error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            } else {
                DispatchQueue.main.async {
                    self?.catches = []
                }
            }
        }
    }
    
    func getStatistics() -> CatchStatistics {
        var stats = CatchStatistics()
        
        stats.totalCatches = catches.count
        
        if !catches.isEmpty {
            let totalWeight = catches.reduce(0.0) { $0 + $1.weight }
            stats.averageWeight = totalWeight / Double(catches.count)
            
            stats.heaviestCatch = catches.max { $0.weight < $1.weight }
            
            let catchesWithLength = catches.filter { $0.length != nil }
            stats.longestCatch = catchesWithLength.max { ($0.length ?? 0) < ($1.length ?? 0) }
            
            let uniqueSpecies = Set(catches.map { $0.fishType })
            stats.differentSpecies = uniqueSpecies.count
            
            // Calculate best day
            let catchesByDay = Dictionary(grouping: catches) { catchItem in
                Calendar.current.startOfDay(for: catchItem.date)
            }
            if let bestDay = catchesByDay.max(by: { $0.value.count < $1.value.count }) {
                stats.bestDay = (bestDay.key, bestDay.value.count)
            }
            
            // Calculate catches and weights by month
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            
            for catchItem in catches {
                let monthKey = dateFormatter.string(from: catchItem.date)
                stats.catchesByMonth[monthKey, default: 0] += 1
                stats.weightsByMonth[monthKey, default: 0] += catchItem.weight
            }
        }
        
        return stats
    }
    
    func getSpeciesStatistics() -> [FishSpeciesStats] {
        let groupedCatches = Dictionary(grouping: catches) { $0.fishType }
        
        return groupedCatches.map { species, catches in
            let totalWeight = catches.reduce(0.0) { $0 + $1.weight }
            let averageWeight = totalWeight / Double(catches.count)
            let maxWeight = catches.map { $0.weight }.max() ?? 0
            let maxLength = catches.compactMap { $0.length }.max()
            
            return FishSpeciesStats(
                species: species,
                catchCount: catches.count,
                averageWeight: averageWeight,
                maxWeight: maxWeight,
                maxLength: maxLength
            )
        }.sorted { $0.catchCount > $1.catchCount }
    }
    
    func getCatchesBySpecies(_ species: FishSpecies) -> [FishCatch] {
        catches.filter { $0.fishType == species }.sorted { $0.date > $1.date }
    }
    
    func getCatchesForDate(_ date: Date) -> [FishCatch] {
        let calendar = Calendar.current
        return catches.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getCatchesForDateRange(start: Date, end: Date) -> [FishCatch] {
        catches.filter { $0.date >= start && $0.date <= end }
    }
}
