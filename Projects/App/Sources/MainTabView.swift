import ComposableArchitecture
import FeatureQuiz
import FeatureStudy
import SwiftUI
import UIComponents

public struct MainTabView: View {
    @Bindable
    var store: StoreOf<RootFeature>

    public init(
        store: StoreOf<RootFeature>
    ) {
        self.store = store
        // UITabBar.appearance().backgroundColor = .black
        // UITabBar.appearance().scrollEdgeAppearance = .init()
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.routing.path, action: \.routing.path)) {
            TabView {
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
                .tag(1)

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
                .tag(2)

                FeatureStudyMainView(
                    store: store.scope(
                        state: \.featureStudyMain,
                        action: \.featureStudyMain
                    )
                )
                .tabItem {
                    Image(uiImage: UIComponentsAsset.bookmark.image)
                        .renderingMode(.template)
                        .foregroundStyle(Color.Grayscale._400)
                    Text("북마크")
                }
                .tag(3)
            }
            .tint(Color.Grayscale._800)
            .font(.headline)
        } destination: { store in
            switch store.case {
            case .featureQuizMain(let store):
                FeatureQuizMainView(store: store)

            case .featureQuizSubject(let store):
                FeatureQuizSubjectView(store: store)

            case .featureQuizPlay(let store):
                FeatureQuizPlayView(store: store)

            case .featureStudyMain(let store):
                FeatureStudyMainView(store: store)
            }
        }
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
// }
