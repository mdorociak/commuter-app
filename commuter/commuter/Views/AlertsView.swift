
import SwiftUI

struct AlertsView: View {
    var body: some View {
        ContentUnavailableView(
            "Alerts",
            systemImage: "bell",
            description: Text("Delay and disruption alerts.")
        )
        .navigationTitle("Alerts")
    }
}
