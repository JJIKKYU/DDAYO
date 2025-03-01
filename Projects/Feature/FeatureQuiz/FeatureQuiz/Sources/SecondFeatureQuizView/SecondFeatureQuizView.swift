//
//  SecondFeatureQuizView.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 12/31/24.
//

import SwiftUI
import ComposableArchitecture

public struct SecondFeatureQuizView: View {

    var store: StoreOf<SecondFeatureQuiz>

    public init (store: StoreOf<SecondFeatureQuiz>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text("SecondView")
        }
    }
}
