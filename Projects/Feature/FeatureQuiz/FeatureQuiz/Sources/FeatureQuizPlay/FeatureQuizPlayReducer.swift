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
import Service

@Reducer
public struct FeatureQuizPlayReducer {
    @Dependency(\.modelContext) var modelContext
    @Dependency(\.firebaseLogger) var firebaseLogger
    @Dependency(\.mixpanelLogger) var mixpanelLogger

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var sourceType: QuizSourceType
        var quizSubject: QuizSubject? {
            switch sourceType {
            case .subject(let quizSubject, let QuestionType):
                return quizSubject

            default:
                return nil
            }
        }
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
        // 푼 문제까지 보이는 카운트
        var visibleQuestionCount: Int = 1

        // imageDetail
        var isImageDetailPresented: Bool = false

        // 문제를 푸는데 걸리는 시간
        var startTime: Date? = nil

        var quizPlayTitle: String {
            switch sourceType {
            case .subject:
                return "\(self.questionIndex + 1)번 문제"

            case .random:
                return "\(self.questionIndex + 1)번 문제"

            case .searchResult:
                return "검색 결과"

            case .fromBookmark:
                return "북마크"
            }
        }

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

    public enum Action: Equatable, Hashable {
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
        case hidePopup(popupAction: QuizPopupAction)

        // 북마크 버튼을 눌렀을 경우
        case toggleBookmarkTapped(isWrong: Bool, isForced: Bool = false)
        // 틀린 문제를 맞췄을 경우 북마크 상태 변경
        case updateBookmarkReasonIfNeeded(QuestionItem)
        // 북마크 상태 업데이트가 필요할 경우
        case updateBookmarkStatus(Bool)
        case setQuestionIndex(Int)

        case presentImageDetail(imageName: String)
        case dismissImageDetail

        // 다음 과목으로 이동
        case requestNextSubject
        case restartRandomQuiz(quizTab: QuizTab, questionType: QuestionType)
        case restartReviewFromBookmark
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                switch state.sourceType {
                case .subject(let selectedSubject, let questionType):
                    let questionTypeRawValue: String = questionType?.rawValue ?? ""
                    return .run { send in
                        let questions: [QuestionItem] = try await MainActor.run {
                            var descriptor = FetchDescriptor<QuestionItem>()
                            if let subject = selectedSubject {
                                descriptor.predicate = #Predicate<QuestionItem> {
                                    $0.subjectRawValue == subject.rawValue &&
                                    $0.questionTypeRawValue == questionTypeRawValue
                                }
                            }
                            descriptor.sortBy = [SortDescriptor(\QuestionItem.id)]
                            return try modelContext.fetch(descriptor)
                        }

                        guard !questions.isEmpty else {
                            print("FeatureQuizPlayReducer :: 저장된 문제가 없습니다.")
                            return
                        }

                        questions.forEach {
                            $0.isCorrect = nil
                            $0.selectedIndex = nil
                        }
                        guard let firstQuestion: QuestionItem = questions[safe: 0] else {
                            return
                        }
                        await send(.setCurrentQuestion(firstQuestion, all: questions))
                    }

                case .searchResult(let items, let index):
                    guard !items.isEmpty else { return .none }
                    items.forEach {
                        $0.isCorrect = nil
                        $0.selectedIndex = nil
                    }
                    // 검색 결과는 전체 내용을 오갈 수 있도록 카운트 제공
                    state.visibleQuestionCount = items.count
                    return .run { send in
                        await send(.setCurrentQuestion(items[index], all: items))
                    }

                case .fromBookmark(let items, let index):
                    guard !items.isEmpty else { return .none }
                    items.forEach {
                        $0.isCorrect = nil
                        $0.selectedIndex = nil
                    }
                    // 북마크는 전체 내용을 오갈 수 있도록 카운트제공
                    state.visibleQuestionCount = items.count
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
                        questions.shuffle()
                        questions.forEach {
                            $0.isCorrect = nil
                            $0.selectedIndex = nil
                        }

                        // 추가 필터링: questionType이 all이 아니면 그에 맞는 타입만 필터링
                        if questionType != .all {
                            questions = questions
                                .filter { $0.questionType == questionType }
                        }

                        guard !questions.isEmpty else {
                            print("FeatureQuizPlayReducer :: 랜덤으로 가져온 문제 없음")
                            return
                        }

                        guard let question: QuestionItem = questions[safe: 0] else { return }
                        await send(.setCurrentQuestion(question, all: questions))
                    }
                }

            case .selectedAnswer(let index):
                state.selectedIndex = index

                // Log
                guard let question: QuestionItem = state.currentQuestion else { return .none }
                mixpanelLogger.log(
                    "click_ques_checking_btn",
                    parameters: LogParamBuilder()
                        .add(.quesID, value: question.id)
                        .add(.quesIndex, value: state.questionIndex)
                        .add(.ai, value: question.questionType == .ai)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .build()
                )

                return .none

            case .toggleSheet(let isPresented):
                state.isSheetPresented = isPresented
                // 버튼을 누를때 로깅
                guard let question: QuestionItem = state.currentQuestion else { return .none }
                mixpanelLogger.log(
                    "click_ques_answering_btn",
                    parameters: LogParamBuilder()
                        .add(.quesID, value: question.id)
                        .add(.quesIndex, value: state.questionIndex)
                        .add(.ai, value: question.questionType == .ai)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .build()
                )

                // bottomSheet이 뜰때 로깅
                if isPresented {
                    guard let question: QuestionItem = state.currentQuestion else { return .none }
                    // Log
                    let duration: TimeInterval = state.startTime.map { Date().timeIntervalSince($0) } ?? 0
                    mixpanelLogger.log(
                        "imp_ques_answering",
                        parameters: LogParamBuilder()
                            .add(.ai, value: question.questionType == .ai)
                            .add(.quesIndex, value: state.questionIndex)
                            .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                            .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                            .add(.duration, value: String(format: "%.2f", duration))
                            .build()
                    )
                }
                return .none

            case .confirmAnswer:
                print("Play :: confirm!")
                switch state.step {
                case .showAnswers:
                    guard let selectedIndex = state.selectedIndex,
                          let question = state.currentQuestion else {
                        return .none
                    }
                    print("Play :: 실기여부 = \(question.subject.isPracticalCase)")

                    // 실기 문제의 경우에는 정답만 노출한다.
                    var isCorrect: Bool = false
                    if question.subject.isPracticalCase || question.subject.isPracticalLanguageCase {
                        isCorrect = true
                        state.selectedIndex = 0
                    }
                    // 필기 문제의 경우에는 사용자 답변을 받는다.
                    else {
                        isCorrect = (selectedIndex == question.answer - 1)
                    }
                    state.isCorrect = isCorrect

                    // 검색 결과로 보고 있는 화면이라면 바로 step 조절
                    if case .searchResult = state.sourceType {
                        state.step = .solvedQuestion(isCorrect: isCorrect)
                    } else {
                        state.step = .confirmAnswers
                    }

                    state.solvedCount += 1
                    question.selectedIndex = selectedIndex

                    // Log
                    mixpanelLogger.log(
                        "click_ques_answering_option",
                        parameters: LogParamBuilder()
                            .add(.quesID, value: question.id)
                            .add(.ai, value: question.questionType == .ai)
                            .add(.quesIndex, value: state.questionIndex)
                            .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                            .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                            .build()
                    )

                    let duration: TimeInterval = state.startTime.map { Date().timeIntervalSince($0) } ?? 0
                    mixpanelLogger.log(
                        "imp_ques_result",
                        parameters: LogParamBuilder()
                            .add(.ai, value: question.questionType == .ai)
                            .add(.quesIndex, value: state.questionIndex)
                            .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                            .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                            .add(.answer, value: isCorrect ? "correct" : "wrong")
                            .add(.duration, value: String(format: "%.2f", duration))
                            .build()
                    )

                    if isCorrect {
                        question.isCorrect = true
                        state.correctCount += 1
                        return .send(.updateBookmarkReasonIfNeeded(question))
                    }
                    question.isCorrect = false

                    return .send(.toggleBookmarkTapped(isWrong: true, isForced: false))

                case .confirmAnswers:
                    guard let question: QuestionItem = state.currentQuestion else { return .none }

                    // 실기 문제의 경우 답안 선택이 없으므로
                    // 맞춘 문제 +1
                    if question.subject.isPracticalLanguageCase || question.subject.isPracticalCase {
                        state.correctCount += 1
                        state.solvedCount += 1
                    }

                    // Log
                    mixpanelLogger.log(
                        "click_ques_next_btn",
                        parameters: LogParamBuilder()
                            .add(.quesID, value: question.id)
                            .add(.ai, value: question.questionType == .ai)
                            .add(.quesIndex, value: state.questionIndex)
                            .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                            .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                            .build()
                    )

                    return .send(.nextQuiz)

                case .solvedQuestion:
                    state.isSheetPresented = false
                    return .none
                }

            // 다음 문제
            case .nextQuiz:
                print("FeatureQuizPlayReducer :: nextQuiz!!")
                guard state.questionIndex + 1 < state.loadedQuestions.count else {
                    print("마지막 문제입니다.")

                    // Search의 경우에는 다음 문제를 로드하지 않는다.
                    // 하나만 보는 것이 스펙
                    if case .searchResult = state.sourceType {
                        return .none
                    }

                    state.isSheetPresented = false
                    state.isPopupPresented = true
                    return .none
                }
                state.visibleQuestionCount = min(state.loadedQuestions.count, state.visibleQuestionCount + 1)
                let nextIndex = state.questionIndex + 1
                return .send(.setQuestionIndex(nextIndex))

            case .loadNextQuestion:
                print("FeatureQuizPlayReducer :: loaddNextQuestion")

                return .run { [questionIndex = state.questionIndex, loadedQuestions = state.loadedQuestions, sourceType = state.sourceType] send in
                    var questions: [QuestionItem] = loadedQuestions

                    if questions.isEmpty {
                        var descriptor = FetchDescriptor<QuestionItem>()
                        if case let .subject(subjectOpt, _) = sourceType, let subject = subjectOpt {
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
                // 문제 설정
                state.currentQuestion = question
                state.loadedQuestions = all
                state.questionIndex = all.firstIndex(of: question) ?? 0
                state.isSheetPresented = false
                state.selectedIndex = nil
                state.isCorrect = nil

                if let isCorrect: Bool = question.isCorrect {
                    state.step = .solvedQuestion(isCorrect: isCorrect)
                    state.selectedIndex = question.selectedIndex
                    state.isCorrect = isCorrect
                } else {
                    state.step = .showAnswers
                    state.isCorrect = false
                }

                if question.subject.isPracticalCase || question.subject.isPracticalLanguageCase {
                    state.step = .confirmAnswers
                    state.selectedIndex = 0
                    state.isCorrect = true
                }

                state.answers = [
                    .init(number: 0, title: question.choice1.text),
                    .init(number: 1, title: question.choice2.text),
                    .init(number: 2, title: question.choice3.text),
                    .init(number: 3, title: question.choice4.text)
                ]

                // Log
                let eventName: String = question.isCorrect != nil ? "imp_ques_prev" : "imp_ques"
                let duration: TimeInterval = state.startTime.map { Date().timeIntervalSince($0) } ?? 0
                mixpanelLogger.log(
                    eventName,
                    parameters: LogParamBuilder()
                        .add(.ai, value: question.questionType == .ai)
                        .add(.quesIndex, value: state.questionIndex)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .add(.duration, value: "0")
                        .build()
                )

                // 문제 푸는 시간 초기화
                state.startTime = Date()

                let questionID: String = question.id
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
                state.isPopupPresented = false
                return .none

            case .pressedCloseBtn:
                print("FeatureQuizPlayReducer :: pressedCloseBtn!")

                switch state.sourceType {
                case .fromBookmark, .searchResult:
                    return .send(.pressedBackBtn)
                default:
                    break
                }

                // 문제를 하나도 풀지 않았을 경우에는 바로 뒤로가기
                if state.solvedCount == 0 {
                    return .send(.pressedBackBtn)
                }

                // 문제를 하나 이상 풀었을 경우에만
                state.isSheetPresented = false
                state.isPopupPresented = true
                return .none

            case .showPopup:
                state.isPopupPresented = true
                // Log
                guard let question = state.currentQuestion else { return .none }
                mixpanelLogger.log(
                    "imp_ques_popup_exit",
                    parameters: LogParamBuilder()
                        .add(.ai, value: question.questionType == .ai)
                        .add(.quesIndex, value: state.questionIndex)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .build()
                )
                return .none

            case .hidePopup(let action):
                var eventName = ""
                var nextAction: Action?

                switch action {
                case .dismiss:
                    eventName = "click_ques_popup_btn_quit"
                    nextAction = .pressedBackBtn

                case .keepStudying:
                    eventName = "click_ques_popup_btn_more"
                    state.isPopupPresented = false

                case .finishStudy:
                    eventName = "click_ques_popup_finish"
                    nextAction = .pressedBackBtn

                case .reviewRandom:
                    eventName = "click_ques_popup_btn_restudy_random"
                    guard let quizTab = state.quizSubject?.quizTab,
                          case let .subject(_, questionType) = state.sourceType,
                          let questionType = questionType else {
                        return .none
                    }
                    nextAction = .restartRandomQuiz(quizTab: quizTab, questionType: questionType)

                case .reviewRandomFromBookmark:
                    eventName = "click_ques_popup_review_random_bookmark"
                    nextAction = .restartReviewFromBookmark

                case .nextLanguage:
                    eventName = "click_ques_popup_btn_restudy_language"
                    nextAction = .requestNextSubject

                case .nextSubject:
                    eventName = "click_ques_popup_btn_restudy_subject"
                    nextAction = .requestNextSubject
                }

                guard let question = state.currentQuestion else { return .none }
                mixpanelLogger.log(
                    eventName,
                    parameters: LogParamBuilder()
                        .add(.quesID, value: question.id)
                        .add(.ai, value: question.questionType == .ai)
                        .add(.quesIndex, value: state.questionIndex)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .build()
                )

                if let next = nextAction {
                    return .send(next)
                }

                return .none

            case .toggleBookmarkTapped(let isWrong, let isForced):
                guard let question = state.currentQuestion else {
                    print("FeatureQuizPlayReducer :: currentQuestion is nil")
                    return .none
                }

                // Log
                let page: String = question.isCorrect != nil ? "ques_result_prev" : "ques_result"
                mixpanelLogger.log(
                    "click_bookmark_btn",
                    parameters: LogParamBuilder()
                        .add(.page, value: page)
                        .add(.quesID, value: question.id)
                        .add(.ai, value: question.questionType == .ai)
                        .add(.quesIndex, value: state.questionIndex)
                        .addIf(question.subject.isWrittenCase || question.subject.isPracticalCase, .subjectDetail, value: question.subject.logSubjectDetail)
                        .addIf(question.subject.isPracticalLanguageCase, .languageDetail, value: question.subject.logSubjectDetail)
                        .build()
                )

                return .run { send in
                    let questionID: String = question.id

                    let isBookmarked = try await MainActor.run {
                        let predicate = #Predicate<BookmarkItem> {
                            $0.questionID == questionID
                        }
                        let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first

                        if let existing {
                            // 유저가 터치해서 강제로 변경하고자 할 때
                            if isForced {
                                modelContext.delete(existing)
                                try modelContext.save()
                                return false
                            }

                            // 이미 북마크가 되어있고 문제를 맞췄다면
                            // manual로 bookmark 성격 변경
                            if existing.reason == .wrong && !isWrong {
                                // 유저가 선택하지 않고, 틀린문제를 잘 풀어 자동으로 북마크의 형태가 바뀌지 않을때
                                existing.reason = .manual
                                try modelContext.save()
                                return true
                            }
                            // 이미 북마크가 되어있고 문제를 또 틀렸다면
                            // 아무것도 하지 않는다.
                            else if existing.reason == .wrong && isWrong {
                                return true
                            }
                            else {
                                modelContext.delete(existing)
                                try modelContext.save()
                                return false
                            }
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

            case let .setQuestionIndex(index):
                guard index < state.loadedQuestions.count else { return .none }
                state.questionIndex = index

                let question = state.loadedQuestions[index]
                return .send(.setCurrentQuestion(question, all: state.loadedQuestions))

            case .presentImageDetail(let imageName):
                state.isImageDetailPresented = true
                // state.imageZoom = .init(imageName: imageName)
                return .none

            case .dismissImageDetail:
                state.isImageDetailPresented = false
                return .none

            case let .restartRandomQuiz(quizTab, questionType):
                state.questionIndex = 0
                state.solvedCount = 0
                state.correctCount = 0
                state.visibleQuestionCount = 1
                state.sourceType = .random(quizTab, questionType)
                state.isPopupPresented = false
                return .send(.onAppear)

            case .requestNextSubject:
                guard case let .subject(currentSubjectOpt, questionType) = state.sourceType,
                      let current = currentSubjectOpt else {
                    return .none
                }

                let group: [QuizSubject] = current.group
                guard !group.isEmpty else { return .none }

                guard let index = group.firstIndex(of: current),
                      let next = group[safe: index + 1] else {
                    return .none
                }

                state.sourceType = .subject(next, questionType)
                state.isPopupPresented = false
                state.solvedCount = 0
                state.correctCount = 0
                state.visibleQuestionCount = 1

                return .send(.onAppear)

            case .restartReviewFromBookmark:
                guard case let .fromBookmark(items, _) = state.sourceType else {
                    return .none
                }
                state.sourceType = .fromBookmark(items: items, index: 0)
                state.questionIndex = 0
                state.solvedCount = 0
                state.correctCount = 0
                state.visibleQuestionCount = items.count
                state.isPopupPresented = false
                return .send(.onAppear)

            case let .updateBookmarkReasonIfNeeded(question):
                return .run { send in
                    let questionID = question.id
                    try await MainActor.run {
                        let predicate = #Predicate<BookmarkItem> { $0.questionID == questionID }
                        guard let existing = try modelContext.fetch(FetchDescriptor<BookmarkItem>(predicate: predicate)).first else {
                            return
                        }
                        guard existing.reason == .wrong else {
                            return
                        }
                        existing.reason = .manual
                        try modelContext.save()
                    }
                }
            }
        }
    }
}
