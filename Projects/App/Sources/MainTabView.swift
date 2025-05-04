import ComposableArchitecture
import FeatureBookmark
import FeatureQuiz
import FeatureSearch
import FeatureStudy
import Model
import SwiftUI
import UIComponents
import Service
import FeatureAuth
import FeatureProfile

public struct MainTabView: View {
    @Bindable
    var store: StoreOf<RootFeature>
    @State private var selectedTab = "gnb_exercise"
    @State private var isSplashActive = true

    @Dependency(\.firebaseLogger) var firebaseLogger
    @Dependency(\.mixpanelLogger) var mixpanelLogger
    @Dependency(\.firebaseAuth) var firebaseAuth

    public init(
        store: StoreOf<RootFeature>
    ) {
        self.store = store
        // UITabBar.appearance().backgroundColor = .black
        // UITabBar.appearance().scrollEdgeAppearance = .init()
    }

    public var body: some View {
        ZStack {
            if isSplashActive {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1) // 스플래시가 위에 오도록
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isSplashActive = false
                            }
                            store.send(.task)
                        }
                    }
            }
            NavigationStack(path: $store.scope(state: \.routing.path, action: \.routing.path)) {
                switch store.appState {
                case .splash:
                    EmptyView()

                case .login:
                    AuthView(
                        store: store.scope(
                            state: \.featureAuth,
                            action: \.featureAuth
                        )
                    )

                case .main:
                    TabView(selection: $selectedTab) {
                        FeatureQuizMainView(
                            store: store.scope(
                                state: \.featureQuizMain,
                                action: \.featureQuizMain
                            )
                        )
                        .tabItem {
                            Image(uiImage: UIComponentsAsset.pen.image)
                                .renderingMode(.template)
                                .foregroundStyle(Color.Grayscale._400)
                            Text("문제풀기")
                        }
                        .tag("gnb_exercise")

                        FeatureStudyMainView(
                            store: store.scope(
                                state: \.featureStudyMain,
                                action: \.featureStudyMain
                            )
                        )
                        .tabItem {
                            Image(uiImage: UIComponentsAsset.bookOpen.image)
                                .renderingMode(.template)
                                .foregroundStyle(Color.Grayscale._400)
                            Text("개념학습")
                        }
                        .tag("gnb_study")

                        FeatureBookmarkMainView(
                            store: store.scope(
                                state: \.featureBookmarkMain,
                                action: \.featureBookmarkMain
                            )
                        )
                        .tabItem {
                            Image(uiImage: UIComponentsAsset.bookmark.image)
                                .renderingMode(.template)
                                .foregroundStyle(Color.Grayscale._400)
                            Text("북마크")
                        }
                        .tag("gnb_bookmark")
                    }
                    .tint(Color.Grayscale._800)
                    .font(.headline)
                }
            } destination: { store in
                switch store.case {
                case .featureAuthName(let store):
                    FeatureAuthNameView(store: store)

                case .featureQuizMain(let store):
                    FeatureQuizMainView(store: store)

                case .featureQuizSubject(let store):
                    FeatureQuizSubjectView(store: store)

                case .featureQuizPlay(let store):
                    FeatureQuizPlayView(store: store)

                case .featureStudyMain(let store):
                    FeatureStudyMainView(store: store)

                case .featureStudyDetail(let store):
                    FeatureStudyDetailView(store: store)

                case .featureBookmarkMain(let store):
                    FeatureBookmarkMainView(store: store)

                case .featureSearchMain(let store):
                    FeatureSearchMainView(store: store)

                case .featureProfileMain(let store):
                    FeatureProfileMainView(store: store)
                }
            }
            .onChange(of: selectedTab) { newValue in
                firebaseLogger
                    .logEvent(.click,
                        parameters: FBClickParam(
                            clickTarget: newValue,
                            sessionID: ""
                        ).parameters
                    )

                mixpanelLogger.log(
                    "Gnb_Click",
                    parameters: [
                        "clickTarget": newValue
                    ]
                )
                print("탭이 변경되었어: \(newValue)")
            }

        }
    }
}
