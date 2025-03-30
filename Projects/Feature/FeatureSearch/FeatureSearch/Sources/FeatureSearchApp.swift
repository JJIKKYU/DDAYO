import SwiftUI

public struct FeatureSearchContentView: View {
    public init() {}

    public var body: some View {
        Text("FeatureBookmarkContentView")
            .padding()
    }
}

@main
struct FeatureBookmarkApp: App {
    var body: some Scene {
        WindowGroup {
            FeatureSearchContentView()
        }
    }
}
