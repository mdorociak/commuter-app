
import Foundation
import Testing
@testable import commuter

struct DiskCacheTests {

    private struct TestItem: Cacheable {
        let id: String
        let payload: Int
        var cacheID: String { id }
        static var cacheIdentifier: String { "test-items" }
    }
    
    private func freshDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("CacheTests-\(UUID().uuidString)", isDirectory: true)
    }
    
    @Test func setThenGetRoundTrips() async {
        let cache = DiskCache(directory: freshDirectory())
        await cache.set(TestItem(id: "a", payload: 7), expiresIn: nil)
        #expect(await cache.getValue((TestItem.self), id: "a")?.payload == 7)
    }
    
    @Test func dataPersistsAcrossInstances() async {
        let directory = freshDirectory()
        let writer = DiskCache(directory: directory)
        await writer.set(TestItem(id: "a", payload: 7), expiresIn: nil)
        
        let reader = DiskCache(directory: directory)
        #expect(await reader.getValue(TestItem.self, id: "a")?.payload == 7)
    }
    
    @Test func missingReturnsNil() async {
        let cache = DiskCache(directory: freshDirectory())
        #expect(await cache.getValue(TestItem.self, id: "nope") == nil)
    }
}
