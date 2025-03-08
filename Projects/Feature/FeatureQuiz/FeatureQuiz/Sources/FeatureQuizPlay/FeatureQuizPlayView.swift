//
//  FeatureQuizPlayView.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import SwiftUI

struct FeatureQuizPlayView: View {
    public let store: StoreOf<FeatureQuizPlayReducer>

    public init(store: StoreOf<FeatureQuizPlayReducer>) {
        self.store = store
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    FeatureQuizPlayView(store: .init(initialState: FeatureQuizPlayReducer.State(), reducer: {
        FeatureQuizPlayReducer()
    }))
}
