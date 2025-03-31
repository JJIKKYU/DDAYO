import SwiftUI
import FirebaseCore
import ComposableArchitecture
import SwiftData
import Model

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct DDAYOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var modelContainer: ModelContainer = {
        try! ModelContainer(for: QuestionItem.self, RichContent.self, ImageItem.self, BookmarkItem.self)
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                } withDependencies: {
                    $0.modelContext = modelContainer.mainContext  // SwiftData 주입
                }
            )
            .modelContainer(modelContainer)  // SwiftUI에도 주입
        }
    }
}
