
import SwiftUI

struct ExploreView: View {
    var body: some View {
        ContentUnavailableView(
            "Explore",
            systemImage: "map",
            description: Text("Browse lines and stops on a map. Coming Soon.")
        )
        .navigationTitle("Explore")
    }
}
