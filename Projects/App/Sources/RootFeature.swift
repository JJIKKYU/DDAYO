//
//  RootFeature.swift
//  DDAYO
//
//  Created by JJIKKYU on 12/31/24.
//

import ComposableArchitecture
import FeatureQuiz
import FeatureStudy
import FeatureBookmark
import FeatureSearch
import Model
import FirebaseFirestore
import Service
import SwiftData
import DI

@Reducer
public struct RootFeature {
    @Dependency(\.questionService) var questionService
    @Dependency(\.modelContext) var modelContext

    @ObservableState
    public struct State {
        public var questions: [QuestionItem] = []

        var routing = RootRoutingReducer.State()

        /// FeatureQuiz
        var featureQuizMain = FeatureQuizMainReducer.State()
        var featureQuizSubject = FeatureQuizSubjectReducer.State()
        var featureQuizPlay = FeatureQuizPlayReducer.State()

        /// FeatureStudy
        var featureStudyMain = FeatureStudyMainReducer.State()

        /// FeatureBookmark
        var featureBookmarkMain = FeatureBookmarkMainReducer.State()

        /// FeatureSearch
        var featureSearchMain = FeatureSearchMainReducer.State()
    }

    public enum Action {
        case task  // 앱 진입 시 호출
        case fetchQuestionsResponse(Result<[QuestionItem], Error>)

        case routing(RootRoutingReducer.Action)
        case clickFeatureQuiz
        case path(StackActionOf<Path>)

        /// FeatureQuiz
        case featureQuizMain(FeatureQuizMainReducer.Action)
        case featureQuizSubject(FeatureQuizSubjectReducer.Action)
        case featureQuizPlay(FeatureQuizPlayReducer.Action)

        /// FeatureStudy
        case featureStudyMain(FeatureStudyMainReducer.Action)

        /// FeatureBookmark
        case featureBookmarkMain(FeatureBookmarkMainReducer.Action)

        /// FeatureSearch
        case featureSearchMain(FeatureSearchMainReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce { state, action in
                switch action {
                case .task:
                    return .run { send in
                        do {
                            let dtos = try await questionService.fetchQuestionsFromFirebase()
                            let models = dtos.compactMap { $0.toModel() }

                            // 1. 기존 저장된 데이터가 있다면 삭제 (옵션)
                            let existing = try modelContext.fetch(FetchDescriptor<QuestionItem>())
                            for item in existing {
                                modelContext.delete(item)
                            }

                            // 2. 새 데이터 삽입
                            for model in models {
                                modelContext.insert(model)
                            }

                            // 3. 저장
                            try modelContext.save()

                            // 4. 상태 업데이트
                            await send(.fetchQuestionsResponse(.success(models)))
                        } catch {
                            await send(.fetchQuestionsResponse(.failure(error)))
                        }
                    }

                case let .fetchQuestionsResponse(.success(questions)):
                    state.questions = questions
                    print("RootFeature :: questions = \(questions)")
                    return .none

                case .fetchQuestionsResponse(.failure):
                    // TODO: 에러 처리
                    return .none

                case .routing(.path(let stackAction)):
                    guard case .element(_, let action) = stackAction else {
                        return .none
                    }

                    switch action {
                    case .featureQuizPlay(let playAction):
                        print("playAction! = \(playAction)")
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

                    case .navigateToSearch:
                        state.routing.path.append(.featureSearchMain(.init(source: .study)))
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

                case .featureStudyMain(let action):
                    switch action {
                    default:
                        return .none
                    }

                case .featureBookmarkMain(let action):
                    switch action {
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

            /// FeatureBookmark
            Scope(state: \.featureBookmarkMain, action: \.featureBookmarkMain) { FeatureBookmarkMainReducer() }

            /// FeatureSearchMain
            Scope(state: \.featureSearchMain, action: \.featureSearchMain, child: { FeatureSearchMainReducer() })
        }
    }

    @Reducer
    public enum Path { }
}
