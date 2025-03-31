//
//  FeatureQuizPlayView.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import Model

public struct FeatureQuizPlayView: View {
    @State private var isFloatingButtonVisible = false
    public let store: StoreOf<FeatureQuizPlayReducer>

    public init(store: StoreOf<FeatureQuizPlayReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // ✅ 네비게이션 바
                    NaviBar(
                        type: .quizPlay,
                        title: "1번 문제",
                        leading1: {
                            viewStore.send(.pressedBackBtn)
                        },
                        trailing1: {
                            viewStore.send(.pressedCloseBtn)
                        }
                    )

                    // ✅ 문제 내용 및 이미지 (ScrollView)
                    if let question = viewStore.currentQuestion {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(question.title.text)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.Grayscale._800)
                                    .lineSpacing(3.0)
                                    .multilineTextAlignment(.leading)

                                Text("\(question.subject.rawValue) · \(question.date ?? "") · \(question.questionType.displayName)")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.Grayscale._500)

                                if let firstImage = question.title.images.first,
                                   let uiImage = UIImage(data: firstImage.data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.Grayscale._50)
                                        .frame(height: 200)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundStyle(Color.Grayscale._400)

                                                Text("이미지 영역입니다")
                                                    .font(.system(size: 13, weight: .regular))
                                                    .foregroundStyle(Color.Grayscale._400)
                                            }
                                        )
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 100)
                        }
                    } else {
                        ProgressView("문제를 불러오는 중입니다...")
                            .padding(.top, 100)
                    }
                }

                // ✅ ScrollView 위에 항상 떠 있는 버튼
                QuizBottomBtnView(
                    isSheetPresented: viewStore
                        .binding(
                            get: \.isSheetPresented,
                            send: FeatureQuizPlayReducer.Action.toggleSheet
                        ),
                    answers: viewStore.answers,
                    selectedIndex: viewStore.binding(
                        get: \.selectedIndex,
                        send: FeatureQuizPlayReducer.Action.selectedAnswer
                    ),
                    step: viewStore.binding(
                        get: \.step,
                        send: FeatureQuizPlayReducer.Action.changeStep
                    ),
                    isCorrect: viewStore.isCorrect,
                    question: viewStore.currentQuestion,
                    isBookmarked: viewStore.binding(
                        get: \.isBookmarked,
                        send: FeatureQuizPlayReducer.Action.updateBookmarkStatus
                    ),
                    onConfirmAnswer: {
                        viewStore.send(.confirmAnswer)
                    },
                    onSelectBookmark: {
                        viewStore.send(.toggleBookmarkTapped)
                    }
                )

                // ✅ 팝업 뷰 바인딩 추가
                QuizPopupView(isPresented: viewStore.binding(
                    get: \ .isPopupPresented,
                    send: { $0 ? .showPopup : .hidePopup }
                ),solvedQuizCnt: 20, allQuizCnt: 30, correctQuizCnt: 7)
                .opacity(viewStore.isPopupPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: viewStore.isPopupPresented)
            }
            .background(Color.Background._1)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    FeatureQuizPlayView(store: .init(initialState: FeatureQuizPlayReducer.State(), reducer: {
        FeatureQuizPlayReducer()
    }))
}
