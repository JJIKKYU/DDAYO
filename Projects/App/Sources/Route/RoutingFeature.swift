//
//  RoutingFeature.swift
//  DDAYO
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import FeatureQuiz
import FeatureStudy
import FeatureBookmark
import FeatureSearch
import FeatureAuth
import FeatureProfile
import Foundation

public final class GlobalRouteObserver {
    static let shared = GlobalRouteObserver()

    @Published var currentRoute: RootRoutingReducer.Path.State?
}

@Reducer
public struct RootRoutingReducer: Reducer {
    public struct State {
        var path = StackState<Path.State>()  // 스택 상태 관리
    }

    public enum Action {
        case push(Path.State) // 특정 경로로 이동
        case pop // 뒤로 가기
        case popToRoot // 루트로 이동
        case path(StackActionOf<Path>) // 내비게이션 StackAction
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .push(let route):
                state.path.append(route)
                GlobalRouteObserver.shared.currentRoute = route
                return .none

            case .pop:
                if !state.path.isEmpty {
                    state.path.removeLast()
                }
                GlobalRouteObserver.shared.currentRoute = state.path.last
                return .none

            case .popToRoot:
                state.path.removeAll()
                GlobalRouteObserver.shared.currentRoute = state.path.last
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)  // StackState 처리
    }

    @Reducer
    public enum Path {
        /// FeatureAuth
        case featureAuthName(FeatureAuthNameReducer)
        case featureAuthAgreement(FeatureAuthAgreementReducer)

        /// FeatureQuiz
        case featureQuizMain(FeatureQuizMainReducer)
        case featureQuizSubject(FeatureQuizSubjectReducer)
        case featureQuizPlay(FeatureQuizPlayReducer)

        /// FeatureStudy
        case featureStudyMain(FeatureStudyMainReducer)
        case featureStudyDetail(FeatureStudyDetailReducer)

        /// Featurebookmark
        case featureBookmarkMain(FeatureBookmarkMainReducer)

        /// FeatureSearch
        case featureSearchMain(FeatureSearchMainReducer)

        /// FeatureProfileMain
        case featureProfileMain(FeatureProfileMainReducer)
    }
}
