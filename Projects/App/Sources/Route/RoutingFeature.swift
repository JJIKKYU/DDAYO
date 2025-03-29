//
//  RoutingFeature.swift
//  DDAYO
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import FeatureQuiz
import FeatureStudy

@Reducer
public struct RootRoutingReducer: Reducer {
    public struct State {
        var path = StackState<Path.State>()  // 스택 상태 관리
        @PresentationState var modal: Modal.State?
    }

    public enum Action {
        case push(Path.State) // 특정 경로로 이동
        case pop // 뒤로 가기
        case popToRoot // 루트로 이동
        case path(StackActionOf<Path>) // 내비게이션 StackAction

        case present(PresentationAction<Modal.Action>) // 모달 액션
        case showModal(Modal.State) // 모달 보여주기
        case dismissModal
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .push(let route):
                state.path.append(route)
                return .none

            case .pop:
                if !state.path.isEmpty {
                    state.path.removeLast()
                }
                return .none

            case .popToRoot:
                state.path.removeAll()
                return .none

            case .path:
                return .none

            case .showModal(let modal):
                state.modal = modal
                return .none

            case .present:
                return .none

            case .dismissModal:
                state.modal = nil
                return .none
            }
        }
        .forEach(\.path, action: \.path)  // StackState 처리
        .ifLet(\.$modal, action: \.present) {
            Modal()
        }
    }

    @Reducer
    public enum Path {
        /// FeatureQuiz
        case featureQuizMain(FeatureQuizMainReducer)
        case featureQuizSubject(FeatureQuizSubjectReducer)
        case featureQuizPlay(FeatureQuizPlayReducer)

        /// FeatureStudy
        case featureStudyMain(FeatureStudyMainReducer)
    }
}

@Reducer
public struct Modal {
    public enum State: Equatable {
        case featureStudyDetail(FeatureStudyDetailReducer.State)
    }

    public enum Action: Equatable {
        case featureStudyDetail(FeatureStudyDetailReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: /State.featureStudyDetail, action: /Action.featureStudyDetail) {
            FeatureStudyDetailReducer()
        }
    }
}
