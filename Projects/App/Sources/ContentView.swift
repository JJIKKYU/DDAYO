import SwiftUI
import FeatureQuiz

public struct ContentView: View {
    public init() {
        UITabBar.appearance().backgroundColor = .black
        UITabBar.appearance().scrollEdgeAppearance = .init()
    }

    public var body: some View {
        TabView {
            Text("The First Tab")
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("학습하기")
                }
                .tag(1)

            FeatureQuizContentView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("문제풀기")
                }
                .tag(2)

            Text("The Last Tab")
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("북마크")
                }
                .tag(3)
        }
        .font(.headline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
