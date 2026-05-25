
import Foundation
import Testing
@testable import commuter

struct StationMappingTests {

    @Test func mapsValidStation() {
        let domain = StationApiModel(id: "2246799", name: "Brzeg", code: "11")
            .domainModel
        #expect(domain?.id == "2246799")
        #expect(domain?.name == "Brzeg")
        #expect(domain?.code == "11")
    }
    
    @Test func returnsNilWhenIdMissing() {
        #expect(StationApiModel(id: nil, name: "Brzeg", code: "11").domainModel == nil)
    }
    
    @Test func returnsNilWhenNameMissing() {
        #expect(StationApiModel(id: "2246799", name: nil, code: "11").domainModel == nil)
    }

    @Test func keepsNilCode() {
        let domain = StationApiModel(id: "x", name: "Something", code: nil).domainModel
        #expect(domain != nil)
        #expect(domain?.code == nil)
    }
}
