
import Foundation
import Testing
@testable import commuter

struct DepartureMappingTests {

    @Test func mapsValidApiModelToDomain() async throws {
        let api = DepartureApiModel(
            line: "D5",
            destination: "Wrocław Główny",
            departureTime: Date(timeIntervalSinceReferenceDate: 1000),
            platform: "II"
        )
        let domain = api.domainModel
        #expect(domain?.line == "D5")
        #expect(domain?.destination == "Wrocław Główny")
        #expect(domain?.platform == "II")
    }
    
    @Test func returnsNilWhenLineMissing() {
        let api = DepartureApiModel(
            line: nil,
            destination: "Wrocław Główny",
            departureTime: Date(),
            platform: "II"
        )
        #expect(api.domainModel == nil)
    }
    
    @Test func keepsNilDestinationAndPlatform() {
        let api = DepartureApiModel(
            line: "D7",
            destination: nil,
            departureTime: Date(timeIntervalSinceReferenceDate: 0),
            platform: nil
        )
        let domain = api.domainModel
        #expect(domain != nil)
        #expect(domain?.destination == nil)
        #expect(domain?.platform == nil)
    }
}
