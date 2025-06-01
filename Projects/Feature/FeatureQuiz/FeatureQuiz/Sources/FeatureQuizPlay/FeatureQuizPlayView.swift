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
import HighlightSwift

public struct FeatureQuizPlayView: View {
    @State private var isFloatingButtonVisible = false
    @State var result: HighlightResult?
    public let store: StoreOf<FeatureQuizPlayReducer>

    public init(store: StoreOf<FeatureQuizPlayReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { (viewStore: ViewStore<FeatureQuizPlayReducer.State, FeatureQuizPlayReducer.Action>) in
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
                        let visibleQuestions = Array(viewStore.loadedQuestions.prefix(viewStore.visibleQuestionCount))
                        ForEach(visibleQuestions.indices, id: \.self) { (index: Int) in
                            let question: QuestionItem = viewStore.loadedQuestions[index]

                            let metaText: String = {
                                var parts: [String] = []
                                parts.append(question.subject.displayName)
                                if let date = question.date, !date.isEmpty {
                                    parts.append(date)
                                }
                                parts.append(question.questionType.displayName)
                                return parts.joined(separator: " · ")
                            }()

                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text(question.title)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.Grayscale._800)
                                            .lineSpacing(4.5)
                                            .multilineTextAlignment(.leading)
                                            .padding(.top, 16)

                                        Spacer()
                                    }

                                    HStack {
                                        Text(metaText)
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundColor(.Grayscale._500)

                                        Spacer()
                                    }

                                    if question.desc.text.isEmpty == false {
                                        Text(question.desc.text)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundStyle(Color.Grayscale._700)
                                            .lineSpacing(6.5)
                                            .multilineTextAlignment(.leading)
                                            .padding(.all, 0)
                                    }

                                    if let imageName = question.desc.images?.first?.filename,
                                       imageName.isEmpty == false {
                                        Image(uiImage: UIImage(resource: .init(name: "QuestionImages/\(imageName)", bundle: .main)))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .onTapGesture {
                                                print("onTapGesture!")
                                                viewStore.send(.presentImageDetail(imageName: "QuestionImages/\(imageName)"))
                                            }
                                            .sheet(
                                                isPresented: viewStore.binding(
                                                    get: \.isImageDetailPresented,
                                                    send: { _ in FeatureQuizPlayReducer.Action.dismissImageDetail }
                                                ),
                                                content: {
                                                    ZoomableImageView(image: UIImage(named: "QuestionImages/\(imageName)") ?? UIImage())
                                                }
                                            )
                                            .background(.red)
                                    }

                                    if question.code.isEmpty == false {
                                        ZStack(alignment: .center) {
                                            Rectangle()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.Grayscale._50)
                                                .cornerRadius(12)

                                            HStack {
                                                CodeText(question.code, result: result)
//                                                    .onHighlightSuccess { result in
//                                                        self.result = result
//                                                    }
                                                    .id(question.id)
                                                    .font(.caption2)
                                                    .lineSpacing(10)
                                                    .background(.clear)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 10)

                                                Spacer()
                                            }
                                            .background(Color.Grayscale._50)
                                            .cornerRadius(12)
                                        }
                                        .background(Color.Grayscale._50)
                                        .cornerRadius(12)
                                    }
                                }
                                // .padding(16)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100)
                            }
                            .frame(maxWidth: .infinity)
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
                        viewStore.send(.toggleBookmarkTapped(isWrong: false, isForced: true))
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
                    quizSubject: viewStore.quizSubject,
                    quizSourceType: viewStore.sourceType,
                    onAction: { action in
                        viewStore.send(.hidePopup(popupAction: action))
                    }
                )
                .transition(.opacity)
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
    FeatureQuizPlayView(store: .init(initialState: FeatureQuizPlayReducer.State(sourceType: .subject(.applicationTesting, .past)), reducer: {
        FeatureQuizPlayReducer()
    }))
}
