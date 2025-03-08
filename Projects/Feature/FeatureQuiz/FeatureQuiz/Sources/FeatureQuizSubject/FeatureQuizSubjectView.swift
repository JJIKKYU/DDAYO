//
//  FeatureQuizSubjectView.swift
//  FeatureQuiz
//
//  Created by 정진균 on 2/22/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents

public struct FeatureQuizSubjectView: View {
    public let store: StoreOf<FeatureQuizSubjectReducer>

    public init(store: StoreOf<FeatureQuizSubjectReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                NaviBar(type: .quiz, title: "실기 과목별로 풀기", leading1: {
                    viewStore.send(.pressedBackBtn)
                })

                ScrollView {
                    if let sections = viewStore.subjectList[viewStore.selectedSujbect] {
                        ForEach(sections.indices, id: \.self) { index in
                            let section = sections[index]
                            QuizButton(title: sections[index].rawValue) {
                                print("button 터치!")
                                viewStore.send(.navigateToQuizPlay(sections[index]))
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer()
            }
            .background(Color(uiColor: .lightGray.withAlphaComponent(0.2)))
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
