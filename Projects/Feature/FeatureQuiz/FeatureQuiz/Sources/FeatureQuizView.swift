//
//  FeatureQuizView.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 12/31/24.
//

import SwiftUI
import ComposableArchitecture

public struct FeatureQuizView: View {
    let store: StoreOf<FeatureQuiz>

    public init(store: StoreOf<FeatureQuiz>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text("\(store.count)")

            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }

                Button("+") {
                    store.send(.incrementButtonTapped)
                }

                Button("Next") {
                    store.send(.navigateToSecondFeatureQuiz)
                }
//                NavigationLink(state: RootFe, label: <#T##() -> View#>)
            }
        }
    }
}

//#Preview {
//    FeatureQuizView(store: Store(initialState: FeatureQuiz.State()) {
//        FeatureQuiz()
//    })
//}
