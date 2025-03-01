import ComposableArchitecture
import FeatureQuiz
import SwiftUI

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
                Text("The First Tab")
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("학습하기")
                    }
                    .tag(1)

                FeatureQuizView(
                    store: store.scope(
                        state: \.featureQuiz,
                        action: \.featureQuiz
                    )
                )
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("문제풀기")
                }
                .tag(1)

                FeatureQuizMainView(
                    store: store.scope(
                        state: \.featureQuizMain,
                        action: \.featureQuizMain
                    )
                )
                .tabItem {
                        Image(systemName: "3.square.fill")
                        Text("북마크")
                    }
                    .tag(3)
            }
            .font(.headline)
        } destination: { store in
            switch store.case {
            case .featureQuiz(let featureQuizStore):
                FeatureQuizView(store: featureQuizStore)

            case .secondFeatureQuiz(let secondFeatureQuizStore):
                SecondFeatureQuizView(store: secondFeatureQuizStore)

            case .featureQuizMain(let store):
                FeatureQuizMainView(store: store)

            case .featureQuizSubject(let store):
                FeatureQuizSubjectView(store: store)
            }
        }
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
// }
