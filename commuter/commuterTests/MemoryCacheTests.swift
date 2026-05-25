
import Testing
import Foundation
@testable import commuter

struct MemoryCacheTests {

    private struct TestItem: Cacheable {
        let id: String
        let payload: Int
        var cacheID: String { id }
        static var cacheIdentifier: String { "test-items" }
    }

    @Test func setThenGetRoundTrips() async {
        let cache = MemoryCache()
        await cache.set(TestItem(id: "a", payload: 1), expiresIn: nil)

        let value = await cache.getValue(TestItem.self, id: "a")
        #expect(value?.payload == 1)
    }

    @Test func missingKeyReturnsNil() async {
        let cache = MemoryCache()
        let value = await cache.getValue(TestItem.self, id: "missing")
        #expect(value == nil)
    }

    @Test func expiredEntryIsTreatedAsMiss() async {
        let cache = MemoryCache()
        await cache.set(TestItem(id: "a", payload: 1), expiresIn: -1)

        let value = await cache.getValue(TestItem.self, id: "a")
        #expect(value == nil)
    }

    @Test func evictsLeastRecentlyUsedWhenOverCapacity() async {
        let cache = MemoryCache(maxItemsPerType: 2)
        await cache.set(TestItem(id: "a", payload: 1), expiresIn: nil)
        await cache.set(TestItem(id: "b", payload: 2), expiresIn: nil)
        await cache.set(TestItem(id: "c", payload: 3), expiresIn: nil)

        #expect(await cache.getValue(TestItem.self, id: "a") == nil)
        #expect(await cache.getValue(TestItem.self, id: "b") != nil)
        #expect(await cache.getValue(TestItem.self, id: "c") != nil)
    }

    @Test func accessingAnItemSavesItFromEviction() async {
        let cache = MemoryCache(maxItemsPerType: 2)
        await cache.set(TestItem(id: "a", payload: 1), expiresIn: nil)
        await cache.set(TestItem(id: "b", payload: 2), expiresIn: nil)

        _ = await cache.getValue(TestItem.self, id: "a")

        await cache.set(TestItem(id: "c", payload: 3), expiresIn: nil)

        #expect(await cache.getValue(TestItem.self, id: "a") != nil)
        #expect(await cache.getValue(TestItem.self, id: "b") == nil)
        #expect(await cache.getValue(TestItem.self, id: "c") != nil)
    }

    @Test func clearRemovesEverything() async {
        let cache = MemoryCache()
        await cache.set(TestItem(id: "a", payload: 1), expiresIn: nil)
        await cache.clear()
        #expect(await cache.getValue(TestItem.self, id: "a") == nil)
    }
}
