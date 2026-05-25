
import SwiftUI
import SwiftData

struct SavedView: View {
    @Query(sort: \FavoriteStop.dateAdded, order: .reverse)
    private var favorites: [FavoriteStop]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "Saved Routes",
                    systemImage: "bookmark",
                    description: Text("Saved commutes and favorite stops will be here.")
                )
            } else {
                List {
                    ForEach(favorites) { favorite in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(favorite.name)
                            Text("Added \(favorite.dateAdded, format: .dateTime.day().month().year())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteFavorites)
                }
            }
        }
        .navigationTitle("Saved")
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
    }
}
