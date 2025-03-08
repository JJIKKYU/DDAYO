//
//  RootFeature.swift
//  DDAYO
//
//  Created by JJIKKYU on 12/31/24.
//

import ComposableArchitecture
import FeatureQuiz
import FeatureStudy

@Reducer
public struct RootFeature {
    @ObservableState
    public struct State {
        var routing = RootRoutingReducer.State()

        /// FeatureQuiz
        var featureQuiz = FeatureQuiz.State()
        var featureQuizMain = FeatureQuizMainReducer.State()
        var featureQuizSubject = FeatureQuizSubjectReducer.State()
        var featureQuizPlay = FeatureQuizPlayReducer.State()

        /// FeatureStudy
        var featureStudyMain = FeatureStudyMainReducer.State()
    }

    public enum Action {
        case routing(RootRoutingReducer.Action)
        case clickFeatureQuiz
        case path(StackActionOf<Path>)

        /// FeatureQuiz
        case featureQuiz(FeatureQuiz.Action)
        case featureQuizMain(FeatureQuizMainReducer.Action)
        case featureQuizSubject(FeatureQuizSubjectReducer.Action)
        case featureQuizPlay(FeatureQuizPlayReducer.Action)

        /// FeatureStudy
        case featureStudyMain(FeatureStudyMainReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce { state, action in
                switch action {
                case .featureQuiz(.navigateToSecondFeatureQuiz):
                    state.routing.path.append(.secondFeatureQuiz(SecondFeatureQuiz.State()))
                    return .none

                case .featureQuiz(let action):
                    switch action {
                    case .navigateToQuizSubject:
                        return .none

                    case .decrementButtonTapped, .incrementButtonTapped, .navigateToSecondFeatureQuiz, .navigateToQuizMain:
                        return .none
                    }

                case .featureQuizMain(let action):
                    switch action {
                    case .navigateToQuizSubject(let quizTab):
                        state.routing.path.append(.featureQuizSubject(FeatureQuizSubjectReducer.State(selectedSujbect: quizTab)))
                        return .none

                    default:
                        return .none
                    }

                case .featureQuiz(.navigateToQuizMain):
                    return .none

                default:
                    return .none
                }
            }

            // ✅ 내비게이션 관련 로직을 제거하고, RoutingReducer로 위임
            Scope(state: \.routing, action: \.routing) { RootRoutingReducer() }

            /// FeatureQuiz
            Scope(state: \.featureQuiz, action: \.featureQuiz) { FeatureQuiz() }
            Scope(state: \.featureQuizMain, action: \.featureQuizMain) { FeatureQuizMainReducer() }
            Scope(state: \.featureQuizSubject, action: \.featureQuizSubject) { FeatureQuizSubjectReducer() }
            Scope(state: \.featureQuizPlay, action: \.featureQuizPlay) { FeatureQuizPlayReducer() }

            /// FeatureStudy
            Scope(state: \.featureStudyMain,action: \.featureStudyMain) { FeatureStudyMainReducer() }
        }
    }

    @Reducer
    public enum Path {
        case featureQuiz(FeatureQuiz)
    }
}
