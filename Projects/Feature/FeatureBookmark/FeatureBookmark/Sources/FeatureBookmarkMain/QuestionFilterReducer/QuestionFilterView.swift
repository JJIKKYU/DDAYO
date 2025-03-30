//
//  QuestionFilterView.swift
//  FeatureBookmark
//
//  Created by 정진균 on 3/29/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Model

struct QuestionFilterView: View {
    let store: StoreOf<QuestionFilterReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                // Exam Type
                VStack(alignment: .leading, spacing: 14) {
                    Text("시험 선택")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.Grayscale._900)

                    HStack(spacing: 12) {
                        ForEach(ExamType.allCases, id: \.self) { type in
                            BookmarkFilterChipView(
                                text: type.displayName,
                                isSelected: viewStore.examType == type
                            ) {
                                viewStore.send(.selectExamType(type))
                            }
                        }
                    }
                }

                // Question Type
                VStack(alignment: .leading, spacing: 20) {
                    Text("문제 유형 선택")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.Grayscale._900)

                    HStack(spacing: 12) {
                        ForEach(QuestionType.allCases, id: \.self) { type in
                            BookmarkFilterChipView(
                                text: type.displayName,
                                isSelected: viewStore.questionType == type
                            ) {
                                viewStore.send(.selectQuestionType(type))
                            }
                        }
                    }
                }

                Spacer()

                Button(action: { viewStore.send(.dismiss) }) {
                    Text("필터 적용")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.Grayscale.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16.5)
                        .background(Color.Green._500)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    QuestionFilterView(
        store: Store(
            initialState: QuestionFilterReducer.State(),
            reducer: { QuestionFilterReducer() }
        )
    )
}
