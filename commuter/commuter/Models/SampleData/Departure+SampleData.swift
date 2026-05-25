
import Foundation

extension Departure {
    static let sampleData: [Departure] = [
        Departure(id: "sample-1", line: "D5", destination: "Wrocław Głównt",
                  departureTime: Date().addingTimeInterval(8 * 60), platform: "II"),
        Departure(id: "sample-2", line: "D7", destination: "Sędzisław",
                  departureTime: Date().addingTimeInterval(23 * 60), platform: "II"),
        Departure(id: "sample-3", line: "D5/D62", destination: "Gryfów Śląski",
                  departureTime: Date().addingTimeInterval(41 * 60), platform: "II")
    ]
}
