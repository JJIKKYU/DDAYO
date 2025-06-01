import ComposableArchitecture
import DI
import FirebaseCore
import FirebaseAnalytics
import Model
import Service
import SwiftData
import SwiftUI
import Mixpanel
import FeatureAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // d1466888a5a3d7e109e760ecda62f46f
//        Mixpanel.initialize(token: "d1466888a5a3d7e109e760ecda62f46f", automaticPushTracking: true)
//        Mixpanel.mainInstance().flushInterval = 1
//        Mixpanel.mainInstance().track(event: "Sign Up", properties: [
//           "source": "Pat's affiliate site",
//           "Opted out of email": true
//        ])
        // MixpanelLogger().log("Logging Test!")

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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            withDependencies {
                $0.modelContext = modelContainer.mainContext
                $0.conceptService = ConceptService()
                $0.firebaseLogger = firebaseLogger
                $0.mixpanelLogger = MixpanelLogger()
                $0.authClient = AuthClient(signInWithApple: {
                    await AppleSignInManager.shared.signIn()
                })
                $0.firebaseAuth = FirebaseAuthImp()
                $0.remoteConfig = FirebaseRemoteConfigServiceImp()
                $0.dataVersionService = FirebaseDataVersionServiceImp()
            } operation: {
//                AuthView(store: .init(initialState: AuthFeatureReducer.State(), reducer: {
//                    AuthFeatureReducer()
//                }))
                MainTabView(
                    store: Store(initialState: RootFeature.State()) {
                        RootFeature()
                    }
                )
            }
        }
    }
}
