import SwiftUI

import SwiftUI

public struct FeatureBookmarkContentView: View {
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
            FeatureBookmarkContentView()
        }
    }
}
