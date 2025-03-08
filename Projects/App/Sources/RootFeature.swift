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
                case .routing(.path(let stackAction)):
                    guard case .element(_, let action) = stackAction else {
                        return .none
                    }

                    switch action {
                    case .featureQuizPlay(let playAction):
                        switch playAction {
                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    case .featureQuizSubject(let subjectAction):
                        switch subjectAction {
                        case .navigateToQuizPlay(let subject):
                            state.routing.path.append(.featureQuizPlay(FeatureQuizPlayReducer.State(selectedSubject: subject)))

                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    default:
                        break
                    }

                    print("stackAction = \(stackAction)")

                case .featureQuizSubject(let action):
                    print("action = \(action)")
                    if case .navigateToQuizPlay(let subject) = action {
                        state.routing.path.append(.featureQuizPlay(FeatureQuizPlayReducer.State(selectedSubject: subject)))
                    }
                    return .none

                case .featureQuizMain(let action):
                    switch action {
                    case .navigateToQuizSubject(let quizTab):
                        state.routing.path.append(.featureQuizSubject(FeatureQuizSubjectReducer.State(selectedSujbect: quizTab)))
                        return .none

                    default:
                        return .none
                    }

                case .featureQuizPlay(let action):
                    switch action {
                    case .pressedBackBtn:
                        return .send(.routing(.pop))

                    default:
                        return .none
                    }

                default:
                    return .none
                }

                return .none
            }

            // ✅ 내비게이션 관련 로직을 제거하고, RoutingReducer로 위임
            Scope(state: \.routing, action: \.routing) { RootRoutingReducer() }

            /// FeatureQuiz
            Scope(state: \.featureQuizMain, action: \.featureQuizMain) { FeatureQuizMainReducer() }
            Scope(state: \.featureQuizSubject, action: \.featureQuizSubject) { FeatureQuizSubjectReducer() }
            Scope(state: \.featureQuizPlay, action: \.featureQuizPlay) { FeatureQuizPlayReducer() }

            /// FeatureStudy
            Scope(state: \.featureStudyMain,action: \.featureStudyMain) { FeatureStudyMainReducer() }
        }
    }

    @Reducer
    public enum Path { }
}
