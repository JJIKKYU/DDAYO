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
        public init(selectedSujbect: QuizTab = .필기) {
            self.selectedSujbect = selectedSujbect
        }

        public var selectedSujbect: QuizTab = .필기
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
