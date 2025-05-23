//
//  FeatureQuizSubjectReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 2/22/25.
//

import ComposableArchitecture
import Model
import Service

@Reducer
public struct FeatureQuizSubjectReducer {
    @Dependency(\.firebaseLogger) var firebaseLogger
    @Dependency(\.mixpanelLogger) var mixpanelLogger

    public init() {}

    public struct State: Equatable {
        public init(
            selectedQuizTab: QuizTab = .필기,
            selectedQuestionType: QuestionType = .past,
            selectedStartOption: QuizStartOption = .startRandomQuiz
        ) {
            self.selectedQuizTab = selectedQuizTab
            self.selectedQuestionType = selectedQuestionType
            self.selectedStartOption = selectedStartOption
        }

        public var selectedQuizTab: QuizTab = .필기
        public var selectedQuestionType: QuestionType = .past
        public var selectedStartOption: QuizStartOption = .startLanguageQuiz

        public var subjectList: [QuizTab: [QuizSubject]] = [
            .필기: QuizSubject.writtenCases,
            .실기: QuizSubject.practicalCases
        ]

        public var navigationTitle: String {
            switch selectedStartOption {
            case .startRandomQuiz:
                return "\(selectedQuizTab.getName()) 랜덤 문제 풀기"

            case .startSubjectQuiz:
                return "\(selectedQuizTab.getName()) 과목별로 풀기"

            case .startLanguageQuiz:
                return "\(selectedQuizTab.getName()) 언어별로 풀기"
            }
        }

        public var displayedSubjects: [QuizSubject] {
            switch selectedStartOption {
            case .startLanguageQuiz:
                return QuizSubject.practicalLanguageCases

            case .startSubjectQuiz:
                return subjectList[selectedQuizTab] ?? []

            // 랜덤일 경우에는 리스트를 안 보여줄 수도 있음
            case .startRandomQuiz:
                return []
            }
        }
    }

    public enum Action: Equatable {
        case onAppear

        case pressedBackBtn
        case navigateToQuizPlay(QuizSubject, QuestionType)

        // 다음 과목으로 자동 이동
        case autoNavigateToNextSubject
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .pressedBackBtn:
                return .none

            case .navigateToQuizPlay(let quizSubject, let questionType):
                var eventName: String
                var subjectDetail: String
                if QuizSubject.practicalLanguageCases.contains(quizSubject) {
                    eventName = "click_practical_language"
                    subjectDetail = quizSubject.displayName
                } else if quizSubject.quizTab == .실기 {
                    eventName = "click_practical_subject"
                    subjectDetail = "t\(quizSubject.index + 1)"
                } else {
                    eventName = "click_theory_subject"
                    subjectDetail = "t\(quizSubject.index + 1)"
                }

                mixpanelLogger.log(
                    eventName,
                    parameters: [
                        "ai": questionType == .ai,
                        "subject_detail": subjectDetail
                    ])
                /*
                firebaseLogger.logEvent(
                    .click,
                    parameters: FBClickParam(
                        clickTarget: clickTarget,
                        customParameters: [
                            "ai": questionType == .ai,
                            "subject_detail": "t\(quizSubject.index + 1)"
                        ]
                    ).parameters
                )
                */
                return .none

            case .autoNavigateToNextSubject:
                return .none
            }
        }
    }
}
