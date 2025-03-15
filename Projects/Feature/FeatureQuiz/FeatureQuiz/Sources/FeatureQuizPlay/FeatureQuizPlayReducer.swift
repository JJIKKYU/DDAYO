//
//  FeatureQuizPlayReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureQuizPlayReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var isSheetPresented: Bool = false
        var answers: [QuizAnswer] = [
            .init(number: 0, title: "선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1선택지 내용 1"),
            .init(number: 1, title: "선택지 내용 2"),
            .init(number: 2, title: "선택지 내용 3"),
            .init(number: 3, title: "선택지 내용 4"),
        ]
        var selectedIndex: Int? = nil
        var step: FeatureQuizPlayStep = .showAnswers
        var isCorrect: Bool? = nil
        private let selectedSubject: QuizSubject?

        public init(selectedSubject: QuizSubject? = nil) {
            self.selectedSubject = selectedSubject
        }
    }

    public enum Action {
        case onAppear
        case selectedAnswer(Int?) // bottomSheet에서 선택지를 눌렀을때 (0번, 1번..)
        case toggleSheet(Bool)    // bottomSheet이 열렸는지 여부
        case confirmAnswer        // bottomSheet에서 선택지를 누르고 "정답확인"을 눌렀을 경우
        case nextQuiz             // bottomSheet에서 마지막에 "다음문제"를 눌렀을 경우
        case changeStep(FeatureQuizPlayStep)
        case loadNextQuestion     // 다음 문제 로드

        case pressedBackBtn
        case pressedCloseBtn
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .selectedAnswer(let index):
                state.selectedIndex = index
                return .none

            case .toggleSheet(let isPresented):
                state.isSheetPresented = isPresented
                return .none

            case .confirmAnswer:
                print("Play :: confirm!")
                switch state.step {
                // 정답 리스트를 보여주는 상태에서 정답확인을 누를 경우
                case .showAnswers:
                    if let selectedIndex = state.selectedIndex {
                        // ✅ 정답 여부 판단 (여기서는 임의로 1번이 정답이라고 가정)
                        state.isCorrect = (selectedIndex == 1)
                        state.step = .confirmAnswers // ✅ View 상태 변경
                    } else {
                        print("정답이 선택되지 않았습니다.")
                    }

                // 정답 확인을 완료했을 경우 버튼을 누를 경우에는 nextQuiz로 이동
                case .confirmAnswers:
                    return .run { send in
                        await send(.nextQuiz)
                    }
                }
                return .none

            case .nextQuiz:
                print("FeatureQuizPlayReducer :: nextQuiz!!")
                // 현재 열려 있는 bottomSheet을 닫고, 문제 다시 세팅
                state.isSheetPresented = false
                state.selectedIndex = nil
                state.isCorrect = nil
                state.step = .showAnswers

                return .run { send in
                    await send(.loadNextQuestion) // ✅ 다음 문제를 불러오는 액션 호출
                }

            case .loadNextQuestion:
                print("FeatureQuizPlayReducer :: loadNextQuestion")
                return .none

            case .changeStep(let newStep):
                state.step = newStep
                return .none

            case .pressedBackBtn:
                print("FeatureQuizPlayReducer :: pressedBackBtn!")
                return .none

            case .pressedCloseBtn:
                print("FeatureQuizPlayReducer :: pressedCloseBtn!")
                return .none
            }
        }
    }
}
