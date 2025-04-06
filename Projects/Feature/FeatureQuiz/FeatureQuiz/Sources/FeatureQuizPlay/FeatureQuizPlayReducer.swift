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
        var quizStartOption: QuizStartOption
        var currentQuestion: QuestionItem? = nil
        var questionIndex: Int = 0
        var loadedQuestions: [QuestionItem] = []
        var solvedCount: Int = 0
        var correctCount: Int = 0

        var isSheetPresented: Bool = false
        var isPopupPresented: Bool = false // quiz 종료 뷰 표시 여부
        var answers: [QuizAnswer] = []
        var selectedIndex: Int? = nil
        var step: FeatureQuizPlayStep = .showAnswers
        var isCorrect: Bool? = nil
        var isBookmarked: Bool = false

        public init(
            sourceType: QuizSourceType
        ) {
            self.sourceType = sourceType

            switch sourceType {
            case .subject:
                self.quizStartOption = .startSubjectQuiz

            case .random(_, let questionType):
                self.quizStartOption = .startRandomQuiz

            case .searchResult:
                self.quizStartOption = .startRandomQuiz

            case .fromBookmark:
                self.quizStartOption = .startRandomQuiz
            }
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
        case hidePopup(isContinueStudy: Bool)

        // 북마크 버튼을 눌렀을 경우
        case toggleBookmarkTapped(isWrong: Bool)
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
                        let (questions): ([QuestionItem]) = try await MainActor.run {
                            var descriptor = FetchDescriptor<QuestionItem>()
                            if let subject = selectedSubject {
                                descriptor.predicate = #Predicate<QuestionItem> {
                                    $0.subjectRawValue == subject.rawValue
                                }
                            }
                            return try modelContext.fetch(descriptor)
                        }

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

                case .fromBookmark(let items, let index):
                    guard !items.isEmpty else { return .none }
                    return .run { send in
                        await send(.setCurrentQuestion(items[index], all: items))
                    }

                case .random(let quizTab, let questionType):
                    return .run { send in
                        var descriptor = FetchDescriptor<QuestionItem>()

                        switch quizTab {
                        case .필기:
                            let writtenRawSubjects = Set(QuizSubject.writtenCases.map { $0.rawValue })
                            descriptor.predicate = #Predicate {
                                writtenRawSubjects.contains($0.subjectRawValue)
                            }

                        case .실기:
                            let practicalRawSubjects = Set(QuizSubject.practicalCases.map { $0.rawValue })
                            descriptor.predicate = #Predicate {
                                practicalRawSubjects.contains($0.subjectRawValue)
                            }
                        }

                        var questions = try modelContext.fetch(descriptor)

                        // 추가 필터링: questionType이 all이 아니면 그에 맞는 타입만 필터링
                        if questionType != .all {
                            questions = questions
                                .filter { $0.questionType == questionType }
                        }

                        guard !questions.isEmpty else {
                            print("FeatureQuizPlayReducer :: 랜덤으로 가져온 문제 없음")
                            return
                        }

                        let randomQuestion = questions.randomElement()!
                        await send(.setCurrentQuestion(randomQuestion, all: questions))
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
                    guard let selectedIndex = state.selectedIndex,
                          let question = state.currentQuestion else {
                        return .none
                    }
                    let isCorrect: Bool = (selectedIndex == question.answer - 1)
                    state.isCorrect = isCorrect
                    state.step = .confirmAnswers

                    state.solvedCount += 1
                    if isCorrect {
                        state.correctCount += 1
                        return .none
                    }

                    return .run { send in
                        await send(.toggleBookmarkTapped(isWrong: true))
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
                    let isBookmarked: Bool = try await MainActor.run {
                        let bookmarkPredicate = #Predicate<BookmarkItem> {
                            $0.questionID == questionID
                        }
                        return try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: bookmarkPredicate)).isEmpty == false
                    }
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

            case .hidePopup(let isContinueStudy):
                if isContinueStudy {
                    state.isPopupPresented = false
                    return .none
                } else {
                    return .run { send in
                        await send(.pressedBackBtn)
                    }
                }

            case .toggleBookmarkTapped(let isWrong):
                guard let question = state.currentQuestion else {
                    print("FeatureQuizPlayReducer :: currentQuestion is nil")
                    return .none
                }

                return .run { send in
                    let questionID = question.id

                    let isBookmarked = try await MainActor.run {
                        let predicate = #Predicate<BookmarkItem> {
                            $0.questionID == questionID
                        }
                        let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first

                        if let existing {
                            modelContext.delete(existing)
                            try modelContext.save()
                            return false
                        } else {
                            let newBookmark = BookmarkItem(
                                questionID: questionID,
                                type: .문제,
                                reason: isWrong ? .wrong : .manual
                            )
                            modelContext.insert(newBookmark)
                            try modelContext.save()
                            return true
                        }
                    }
                    await send(.updateBookmarkStatus(isBookmarked))
                }

            case let .updateBookmarkStatus(bookmarked):
                state.isBookmarked = bookmarked
                return .none
            }
        }
    }
}
