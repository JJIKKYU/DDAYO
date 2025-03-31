//
//  FeatureQuizPlayReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 3/8/25.
//

import ComposableArchitecture
import DI
import Model
import SwiftData
import Foundation

@Reducer
public struct FeatureQuizPlayReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var currentQuestion: QuestionItem? = nil
        var questionIndex: Int = 0
        var loadedQuestions: [QuestionItem] = []

        var isSheetPresented: Bool = false
        var isPopupPresented: Bool = false // quiz 종료 뷰 표시 여부
        var answers: [QuizAnswer] = []
        var selectedIndex: Int? = nil
        var step: FeatureQuizPlayStep = .showAnswers
        var isCorrect: Bool? = nil
        let selectedSubject: QuizSubject?
        var isBookmarked: Bool = false // New property for bookmark status

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
        case setCurrentQuestion(QuestionItem, all: [QuestionItem])
        case changeStep(FeatureQuizPlayStep)
        case loadNextQuestion     // 다음 문제 로드

        case pressedBackBtn
        case pressedCloseBtn

        case showPopup            // 팝업 표시
        case hidePopup            // 팝업 숨기기

        case toggleBookmarkTapped  // New action for bookmark button tap
        case updateBookmarkStatus(Bool) // New action for bookmark status update
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [selectedSubject = state.selectedSubject] send in
                    var descriptor = FetchDescriptor<QuestionItem>()
                    if let subject = selectedSubject {
                        descriptor.predicate = #Predicate<QuestionItem> {
                            $0.subjectRawValue == subject.rawValue
                        }
                    }
                    let questions = try modelContext.fetch(descriptor)
                    guard !questions.isEmpty else {
                        print("FeatureQuizPlayReducer :: 저장된 문제가 없습니다.")
                        return
                    }
                    let firstQuestion = questions[0]
                    await send(.setCurrentQuestion(firstQuestion, all: questions))
                }

            case .selectedAnswer(let index):
                state.selectedIndex = index
                return .none

            case .toggleSheet(let isPresented):
                state.isSheetPresented = isPresented
                return .none

            case .confirmAnswer:
                print("Play :: confirm!")
                switch state.step {
                case .showAnswers:
                    if let selectedIndex = state.selectedIndex,
                       let question = state.currentQuestion {
                        // ✅ 정답 여부 판단 (SwiftData에서 로드된 정답 기준)
                        state.isCorrect = (selectedIndex == question.answer - 1)
                        state.step = .confirmAnswers
                    } else {
                        print("정답이 선택되지 않았거나 문제가 없습니다.")
                    }

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
                print("FeatureQuizPlayReducer :: loaddNextQuestion")

                return .run { [questionIndex = state.questionIndex, loadedQuestions = state.loadedQuestions, selectedSubject = state.selectedSubject] send in
                    var questions: [QuestionItem] = loadedQuestions

                    if questions.isEmpty {
                        var descriptor = FetchDescriptor<QuestionItem>()
                        if let subject = selectedSubject {
                            descriptor.predicate = #Predicate { $0.subject == subject }
                        }
                        questions = try modelContext.fetch(descriptor)
                        if questions.isEmpty {
                            print("FeatureQuizPlayReducer :: 여전히 값이 비어있습니다.")
                            return
                        }
                    }

                    guard questionIndex < questions.count else {
                        print("FeatureQuizPlayReducer :: 모든 문제를 다 띄웠어요")
                        return
                    }

                    let nextQuestion = questions[questionIndex]

                    await send(.setCurrentQuestion(nextQuestion, all: questions))
                }

            case let .setCurrentQuestion(question, all):
                state.currentQuestion = question
                state.loadedQuestions = all
                state.questionIndex += 1

                state.answers = [
                    .init(number: 0, title: question.choice1.text),
                    .init(number: 1, title: question.choice2.text),
                    .init(number: 2, title: question.choice3.text),
                    .init(number: 3, title: question.choice4.text)
                ]

                let questionID = question.id
                return .run { send in
                    let bookmarkPredicate = #Predicate<BookmarkItem> {
                        $0.questionID == questionID
                    }
                    let isBookmarked = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate)).isEmpty == false
                    await send(.updateBookmarkStatus(isBookmarked))
                }

            case .changeStep(let newStep):
                state.step = newStep
                return .none

            case .pressedBackBtn:
                print("FeatureQuizPlayReducer :: pressedBackBtn!")
                return .none

            case .pressedCloseBtn:
                print("FeatureQuizPlayReducer :: pressedCloseBtn!")
                state.isSheetPresented = false
                state.isPopupPresented = true
                return .none

            case .showPopup:
                state.isPopupPresented = true
                return .none

            case .hidePopup:
                state.isPopupPresented = false
                return .none

            case .toggleBookmarkTapped:
                guard let question = state.currentQuestion else {
                    print("FeatureQuizPlayReducer :: currentQuestion is nil")
                    return .none
                }

                return .run { send in
                    let questionID = question.id

                    let predicate = #Predicate<BookmarkItem> {
                        $0.questionID == questionID
                    }

                    let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first

                    if let existing {
                        modelContext.delete(existing)
                        try modelContext.save()
                        await send(.updateBookmarkStatus(false))
                    } else {
                        let newBookmark = BookmarkItem(questionID: questionID)
                        modelContext.insert(newBookmark)
                        try modelContext.save()
                        await send(.updateBookmarkStatus(true))
                    }
                }

            case let .updateBookmarkStatus(bookmarked):
                state.isBookmarked = bookmarked
                return .none
            }
        }
    }
}
