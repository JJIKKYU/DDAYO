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
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?UML에서 활용되는 다이어그램 중, 시스템의 동작을 표현하는 행위(Behavioral) 다이어그램에 해당하지 않는 것은?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.Grayscale._800)
                                .lineSpacing(3.0)
                                .multilineTextAlignment(.leading)

                            Text("1과목 소프트웨어 설계   2022년 2회 기출문제")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.Grayscale._500)

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
                    onConfirmAnswer: {
                        viewStore.send(.confirmAnswer)
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
