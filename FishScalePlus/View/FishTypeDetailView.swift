import SwiftUI

struct FishTypeDetailView: View {
    let fishType: String
    let catches: [Catch]
    @ObservedObject var catchManager: CatchManager
    
    var body: some View {
        List {
            ForEach(catches.sorted(by: { $0.date > $1.date })) { catchItem in
                NavigationLink(destination: CatchDetailsView(catchItem: catchItem, catchManager: catchManager)) {
                    HStack {
                        Image(systemName: "fish.fill")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text(DateFormatter.localizedString(from: catchItem.date, dateStyle: .short, timeStyle: .short))
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(String(format: "%.2f kg", catchItem.weight))
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
            .onDelete { indices in
                indices.forEach { index in
                    if let globalIndex = catchManager.catches.firstIndex(where: { $0.id == catches[index].id }) {
                        catchManager.catches.remove(at: globalIndex)
                    }
                }
                catchManager.save()
            }
        }
        .navigationTitle(fishType)
        .background(Color.white)
    }
}
