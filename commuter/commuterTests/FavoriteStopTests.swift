
import Foundation
import Testing
import SwiftData
@testable import commuter

@MainActor
struct FavoriteStopTests {

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteStop.self, configurations: config)
        return ModelContext(container)
    }
    
    @Test func insertingFavoriteMakesItFetchable()  throws {
        let context = try makeContext()
        context.insert(FavoriteStop(stopID: "2246799", name: "Brzeg"))
        
        let fetched = try context.fetch(FetchDescriptor<FavoriteStop>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.stopID == "2246799")
        #expect(fetched.first?.name == "Brzeg")
    }

    @Test func deletingFavoriteRemovesIt() throws {
        let context = try makeContext()
        let favorite = FavoriteStop(stopID: "2246799", name: "Brzeg")
        context.insert(favorite)
        context.delete(favorite)
        
        let fetched = try context.fetch(FetchDescriptor<FavoriteStop>())
        #expect(fetched.isEmpty)
    }
}
