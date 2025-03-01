//
//  GlobalRoute.swift
//  DDAYO
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import FeatureQuiz

///// 앱 내의 모든 내비게이션 경로를 정의
//public enum GlobalRoute: Equatable {
//    case featureQuiz(FeatureQuiz.State)
//    case secondFeatureQuiz(SecondFeatureQuiz.State)
//    case featureQuizMain(FeatureQuizMainReducer.State)
//}
//
//public struct GlobalRouteReducer: CaseReducer {
//    public typealias CaseScope = GlobalRoute
//
//    public var body: some ReducerOf<Self> {
//        EmptyReducer()
//            .ifCaseLet(/GlobalRoute.featureQuiz, then: FeatureQuiz())
//            .ifCaseLet(/GlobalRoute.secondFeatureQuiz, then: SecondFeatureQuiz())
//            .ifCaseLet(/GlobalRoute.featureQuizMain, then: FeatureQuizMainReducer())
//    }
//}
