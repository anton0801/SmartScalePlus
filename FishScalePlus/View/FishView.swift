import SwiftUI

struct FishView: View {
    @ObservedObject var catchManager: CatchManager
    
    var groupedCatches: [String: [Catch]] {
        Dictionary(grouping: catchManager.catches) { $0.fishType }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedCatches.keys.sorted(), id: \.self) { fishType in
                    NavigationLink(destination: FishTypeDetailView(fishType: fishType, catches: groupedCatches[fishType] ?? [], catchManager: catchManager)) {
                        HStack {
                            Image(systemName: "fish.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text(fishType)
                                    .font(.headline)
                                Text("Catches: \(groupedCatches[fishType]?.count ?? 0)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if let catches = groupedCatches[fishType], !catches.isEmpty {
                                let avg = catches.map { $0.weight }.reduce(0, +) / Double(catches.count)
                                let maxWeight = catches.max { $0.weight < $1.weight }?.weight ?? 0
                                VStack(alignment: .trailing) {
                                    Text("Avg: \(String(format: "%.2f", avg)) kg")
                                        .font(.subheadline)
                                    Text("Max: \(String(format: "%.2f", maxWeight)) kg")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fish Types")
            .background(Color.white)
        }
    }
}
