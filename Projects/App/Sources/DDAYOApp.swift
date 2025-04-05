import ComposableArchitecture
import DI
import FirebaseCore
import Model
import Service
import SwiftData
import SwiftUI

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
        try! ModelContainer(
            for: QuestionItem.self,
            RichContent.self,
            ImageItem.self,
            BookmarkItem.self,
            ConceptItem.self,
            WrongAnswerItem.self,
            QuestionVersion.self,
            RecentConceptItem.self
        )
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                } withDependencies: {
                    $0.modelContext = modelContainer.mainContext
                    $0.conceptService = ConceptService()
                }
            )
            .modelContainer(modelContainer)  // SwiftUI에도 주입
        }
    }
}
