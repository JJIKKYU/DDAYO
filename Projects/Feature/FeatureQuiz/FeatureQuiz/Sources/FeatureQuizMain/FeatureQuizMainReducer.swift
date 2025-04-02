//
//  FeatureQuizMainReducer.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import Model

// MARK: - Reducer

@Reducer
public struct FeatureQuizMainReducer {
    @Dependency(\.modelContext) var modelContext

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public init() {}

        var selectedTab: QuizTab = .필기
        var examSections: [QuizTab: [ExamSectionData]] = [
            .필기 : [
                .init(
                    title: "기출 문제",
                    subtitle: "역대 시험에 출제된 문제들을 모았어요.",
                    questionType: .past,
                    buttons: [
                        .init(title: "랜덤 문제 풀기", option: .startRandomQuiz),
                        .init(title: "과목별로 풀기", option: .startSubjectQuiz)
                    ]
                ),
                .init(
                    title: "AI 예상 문제",
                    subtitle: "시험 트렌드를 학습한 AI의 예상 문제를 풀어보세요!",
                    questionType: .ai,
                    buttons: [
                        .init(title: "랜덤 문제 풀기", option: .startRandomQuiz),
                        .init(title: "과목별로 풀기", option: .startSubjectQuiz)
                    ]
                ),
            ],
            .실기 : [
                .init(
                    title: "기출 문제",
                    subtitle: "역대 시험에 출제된 문제들을 모았어요.",
                    questionType: .past,
                    buttons: [
                        .init(title: "랜덤 문제 풀기", option: .startRandomQuiz),
                        .init(title: "언어별로 풀기", option: .startLanguageQuiz),
                        .init(title: "과목별로 풀기", option: .startSubjectQuiz)
                    ]
                ),
                .init(
                    title: "AI 예상 문제",
                    subtitle: "시험 트렌드를 학습한 AI의 예상 문제를 풀어보세요!",
                    questionType: .ai,
                    buttons: [
                        .init(
                            title: "랜덤 문제 풀기",
                            option: .startRandomQuiz
                        ),
                        .init(
                            title: "언어별로 풀기",
                            option: .startLanguageQuiz
                        ),
                        .init(
                            title: "과목별로 풀기",
                            option: .startSubjectQuiz
                        )
                    ]
                ),
            ]
        ]
    }

    public enum Action {
        case selectTab(QuizTab)
        case swipeTab(QuizTab)

        case navigateToQuizSubject(QuizTab, QuestionType, QuizStartOption)
        case navigateToSearch
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                print("FeatureQuizMainReducer :: selectedTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .swipeTab(let tab):
                print("FeatureQuizMainReducer :: swipeTab = \(tab)")
                state.selectedTab = tab
                return .none

            case .navigateToQuizSubject:
                return .none

            case .navigateToSearch:
                return .none
            }
        }
    }
}

public struct ExamSectionData: Equatable, Hashable {
    var title: String
    var subtitle: String
    var questionType: QuestionType
    var buttons: [ExamSectionButton]
}

public struct ExamSectionButton: Equatable, Hashable {
    var title: String
    var option: QuizStartOption
}

public enum QuizStartOption: Equatable {
    case startRandomQuiz
    case startSubjectQuiz
    case startLanguageQuiz
}
