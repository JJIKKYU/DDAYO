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
import SwiftUIIntrospect

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
                        title: viewStore.quizPlayTitle,
                        trailing1: {
                            viewStore.send(.pressedCloseBtn)
                        }
                    )

                    // ✅ 문제 내용 및 이미지 (ScrollView)
                    TabView(selection: viewStore.binding(
                        get: \.questionIndex,
                        send: { .setQuestionIndex($0) })
                    ) {
                        ForEach(viewStore.loadedQuestions.prefix(viewStore.visibleQuestionCount).indices, id: \.self) { index in
                            let question: QuestionItem = viewStore.loadedQuestions[index]

                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(question.title)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.Grayscale._800)
                                        .lineSpacing(3.0)
                                        .multilineTextAlignment(.leading)

                                    Text("\(question.subject.rawValue) · \(question.date ?? "") · \(question.questionType.displayName)")
                                        .font(.custom("Pretendard-Regular", size: 11))
                                        .foregroundColor(.Grayscale._500)

                                    Text(question.desc.text)

                                    Image(uiImage: UIImage(resource: .init(name: "image_1", bundle: .main)))
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 20)

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
                                .padding(16)
                                .padding(.bottom, 100)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if viewStore.loadedQuestions.isEmpty {
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
                        viewStore.send(.toggleBookmarkTapped(isWrong: false))
                    }
                )

                QuizPopupView(
                    visible: Binding(
                        get: { viewStore.isPopupPresented },
                        set: { _ in } // 변경은 내부 onAction에서 처리
                    ),
                    solvedQuizCnt: viewStore.solvedCount,
                    allQuizCnt: viewStore.loadedQuestions.count,
                    correctQuizCnt: viewStore.correctCount,
                    quizOption: viewStore.quizStartOption,
                    onAction: { isContinue in
                        viewStore.send(.hidePopup(isContinueStudy: isContinue))
                    }
                )
                .transition(.opacity)
                .opacity(viewStore.isPopupPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: viewStore.isPopupPresented)
                .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { entity in
                    entity.interactivePopGestureRecognizer?.isEnabled = false
                }
            }
            .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { entity in
                entity.interactivePopGestureRecognizer?.isEnabled = false
            }
            .background(Color.Background._1)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .accessibilityIdentifier("FeatureQuizPlayView")
        .introspect(.navigationView(style: .stack), on: .iOS(.v18)) { entity in
            entity.interactivePopGestureRecognizer?.isEnabled = false
        }
        .introspect(.navigationStack, on: .iOS(.v18)) { entity in
            entity.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}

#Preview {
    FeatureQuizPlayView(store: .init(initialState: FeatureQuizPlayReducer.State(sourceType: .subject(.applicationTesting)), reducer: {
        FeatureQuizPlayReducer()
    }))
}
