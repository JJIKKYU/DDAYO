//
//  FeatureQuizSubjectView.swift
//  FeatureQuiz
//
//  Created by 정진균 on 2/22/25.
//

import ComposableArchitecture
import Foundation
import Model
import SwiftUI
import SwiftUIIntrospect
import UIComponents

public struct FeatureQuizSubjectView: View {
    public let store: StoreOf<FeatureQuizSubjectReducer>

    public init(store: StoreOf<FeatureQuizSubjectReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                NaviBar(
                    type: .quiz,
                    title: viewStore.navigationTitle,
                    leadingTitleImage: viewStore.selectedQuestionType == .ai ? UIComponentsAsset.ai : nil,
                    leading1: {
                        viewStore.send(.pressedBackBtn)
                })

                ScrollView {
                    ForEach(viewStore.displayedSubjects, id: \.self) { subject in
                        QuizButton(title: subject.displayName) {
                            viewStore.send(.navigateToQuizPlay(subject, viewStore.selectedQuestionType))
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
            .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { entity in
                entity.interactivePopGestureRecognizer?.isEnabled = true
            }
            .background(Color.Background._2)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
