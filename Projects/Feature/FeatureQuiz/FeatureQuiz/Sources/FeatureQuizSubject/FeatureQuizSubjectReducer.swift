//
//  FeatureQuizSubjectReducer.swift
//  FeatureQuiz
//
//  Created by 정진균 on 2/22/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureQuizSubjectReducer {
    public init() {}

    public struct State: Equatable {
        public init(
            selectedSujbect: QuizTab = .필기,
            selectedQuestionType: QuestionType = .past,
            selectedStartOption: QuizStartOption = .startRandomQuiz
        ) {
            self.selectedSujbect = selectedSujbect
            self.selectedQuestionType = selectedQuestionType
            self.selectedStartOption = selectedStartOption
        }

        public var selectedSujbect: QuizTab = .필기
        public var selectedQuestionType: QuestionType = .past
        public var selectedStartOption: QuizStartOption = .startLanguageQuiz

        public var subjectList: [QuizTab: [QuizSubject]] = [
            .필기: [
                .softwareDesign,
                .softwareDevelopment,
                .databaseConstruction,
                .programmingLanguage,
                .informationSystemManagement
            ],
            .실기: [
                .requirementsAnalysis,
                .dataInputOutput,
                .integrationImplementation,
                .serverProgramming,
                .interfaceImplementation,
                .screenDesign,
                .applicationTesting,
                .sqlApplication,
                .softwareSecurity,
                .basicApplicationTech,
                .softwarePackaging
            ]
        ]

        public var navigationTitle: String {
            switch selectedStartOption {
            case .startRandomQuiz:
                return "\(selectedSujbect.getName()) 랜덤 문제 풀기"
            case .startSubjectQuiz:
                return "\(selectedSujbect.getName()) 과목별로 풀기"
            case .startLanguageQuiz:
                return "\(selectedSujbect.getName()) 언어별로 풀기"
            }
        }
    }

    public enum Action: Equatable {
        case onAppear

        case pressedBackBtn
        case navigateToQuizPlay(QuizSubject)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .pressedBackBtn:
                return .none

            case .navigateToQuizPlay:
                return .none
            }
        }
    }
}
