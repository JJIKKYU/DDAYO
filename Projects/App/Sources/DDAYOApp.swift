import ComposableArchitecture
import DI
import FirebaseCore
import FirebaseAnalytics
import Model
import Service
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Analytics.logEvent("test_event", parameters: ["dummy": "value"])
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
            QuestionVersion.self,
            RecentConceptItem.self,
            ConceptVersion.self,
            RecentSearchItem.self
        )
    }()

    @State private var firebaseLogger: FirebaseLoggerProtocol = FirebaseLogger()

    var body: some Scene {
        WindowGroup {
            withDependencies {
                $0.modelContext = modelContainer.mainContext
                $0.conceptService = ConceptService()
                $0.firebaseLogger = firebaseLogger
            } operation: {
                MainTabView(
                    store: Store(initialState: RootFeature.State()) {
                        RootFeature()
                    }
                )
            }
        }
    }
}
