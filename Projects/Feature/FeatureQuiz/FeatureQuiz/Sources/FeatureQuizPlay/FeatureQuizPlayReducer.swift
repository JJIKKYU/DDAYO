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
        var sourceType: QuizSourceType
        var currentQuestion: QuestionItem? = nil
        var questionIndex: Int = 0
        var loadedQuestions: [QuestionItem] = []

        var isSheetPresented: Bool = false
        var isPopupPresented: Bool = false // quiz 종료 뷰 표시 여부
        var answers: [QuizAnswer] = []
        var selectedIndex: Int? = nil
        var step: FeatureQuizPlayStep = .showAnswers
        var isCorrect: Bool? = nil
        var isBookmarked: Bool = false // New property for bookmark status

        public init(
            sourceType: QuizSourceType
        ) {
            self.sourceType = sourceType
        }
    }

    public enum Action {
        case onAppear
        // bottomSheet에서 선택지를 눌렀을때 (0번, 1번..)
        case selectedAnswer(Int?)
        // bottomSheet이 열렸는지 여부
        // bottomSheet에서 선택지를 누르고 "정답확인"을 눌렀을 경우
        case toggleSheet(Bool)
        case confirmAnswer
        // bottomSheet에서 마지막에 "다음문제"를 눌렀을 경우
        case nextQuiz
        case setCurrentQuestion(QuestionItem, all: [QuestionItem])
        case changeStep(FeatureQuizPlayStep)
        // 다음 문제 로드
        case loadNextQuestion

        case pressedBackBtn
        case pressedCloseBtn

        // 팝업 표시
        case showPopup
        // 팝업 숨기기
        case hidePopup

        // 북마크 버튼을 눌렀을 경우
        case toggleBookmarkTapped
        // 북마크 상태 업데이트가 필요할 경우
        case updateBookmarkStatus(Bool)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                switch state.sourceType {
                case .subject(let selectedSubject):
                    return .run { send in
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

                case .searchResult(let items, let index):
                    guard !items.isEmpty else { return .none }
                    return .run { send in
                        await send(.setCurrentQuestion(items[index], all: items))
                    }
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
                    do {
                        if let selectedIndex = state.selectedIndex,
                           let question = state.currentQuestion {
                            state.isCorrect = (selectedIndex == question.answer - 1)
                            try saveWrongAnswer(for: question, selectedIndex: selectedIndex, context: modelContext)
                            state.step = .confirmAnswers
                        } else {
                            print("정답이 선택되지 않았거나 문제가 없습니다.")
                        }
                    } catch {
                        print("오답 저장 중 오류 발생: \(error)")
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

                return .run { [questionIndex = state.questionIndex, loadedQuestions = state.loadedQuestions, sourceType = state.sourceType] send in
                    var questions: [QuestionItem] = loadedQuestions

                    if questions.isEmpty {
                        var descriptor = FetchDescriptor<QuestionItem>()
                        if case let .subject(subject) = sourceType, let subject {
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


// MARK: - extension

extension FeatureQuizPlayReducer {
    private func saveWrongAnswer(for question: QuestionItem, selectedIndex: Int, context: ModelContext) throws {
        let questionId: UUID = question.id
        let predicate = #Predicate<WrongAnswerItem> {
            $0.questionID == questionId
        }

        if let existing = try context.fetch(FetchDescriptor(predicate: predicate)).first {
            existing.selectedAnswerIndex = selectedIndex
            existing.date = .now
        } else {
            let wrongItem = WrongAnswerItem(
                questionID: question.id,
                selectedAnswerIndex: selectedIndex,
                date: .now
            )
            context.insert(wrongItem)
        }

        try context.save()
    }
}
