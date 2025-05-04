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
import FeatureAuth
import FeatureProfile

enum AppRoute {
    case splash
    case login
    case main
}

@Reducer
public struct RootFeature {
    @Dependency(\.questionService) var questionService
    @Dependency(\.modelContext) var modelContext
    @Dependency(\.conceptService) var conceptService
    @Dependency(\.firebaseAuth) var firebaseAuth

    @ObservableState
    public struct State {
        public var questions: [QuestionItem] = []

        var routing = RootRoutingReducer.State()
        var appState: AppRoute = .splash

        /// FeatureAuth
        var featureAuth = AuthFeatureReducer.State()
        var featureAuthName = FeatureAuthNameReducer.State()

        /// FeatureQuiz
        var featureQuizMain = FeatureQuizMainReducer.State()
        var featureQuizSubject = FeatureQuizSubjectReducer.State()
        var featureQuizPlay = FeatureQuizPlayReducer.State(sourceType: .subject(nil, nil))

        /// FeatureStudy
        var featureStudyMain = FeatureStudyMainReducer.State()
        var featureStudyDetail = FeatureStudyDetailReducer.State(items: [], index: 0)

        /// FeatureBookmark
        var featureBookmarkMain = FeatureBookmarkMainReducer.State()

        /// FeatureSearch
        var featureSearchMain = FeatureSearchMainReducer.State()

        /// FeatureProfile
        var featureProfileMain = FeatureProfileMainReducer.State()
    }

    public enum Action {
        case task  // 앱 진입 시 호출
        case syncInitialData
        case checkAuthResult(FirebaseUser?)

        case fetchQuestionsResponse(Result<[QuestionItem], Error>)

        case routing(RootRoutingReducer.Action)
        case clickFeatureQuiz
        case path(StackActionOf<Path>)

        /// FeatureAuth
        case featureAuth(AuthFeatureReducer.Action)
        case featureAuthName(FeatureAuthNameReducer.Action)

        /// FeatureQuiz
        case featureQuizMain(FeatureQuizMainReducer.Action)
        case featureQuizSubject(FeatureQuizSubjectReducer.Action)
        case featureQuizPlay(FeatureQuizPlayReducer.Action)

        /// FeatureStudy
        case featureStudyMain(FeatureStudyMainReducer.Action)
        case featureStudyDetail(FeatureStudyDetailReducer.Action)

        /// FeatureBookmark
        case featureBookmarkMain(FeatureBookmarkMainReducer.Action)

        /// FeatureSearch
        case featureSearchMain(FeatureSearchMainReducer.Action)

        /// FeatureProfile
        case featureProfileMain(FeatureProfileMainReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        CombineReducers {
            Reduce { state, action in
                switch action {
                case .task:
                    // 앱 시작시 로그인 여부 확인
                    let user = firebaseAuth.getCurrentUser()
                    return .send(.checkAuthResult(user))

                case .checkAuthResult(let user):
                    print("RootFeature :: user = \(user)")
                    if let user {
                        // 로그인이 되어 있을 경우에 데이터 초기화
                        state.appState = .main
                        return .send(.syncInitialData)
                    } else {
                        // 로그인 필요
                        state.appState = .login
                    }

                case .syncInitialData:
                    return .run { send in
                        // 1. 개념 데이터를 먼저 처리
                        await MainActor.run {
                            do {
                                _ = try conceptService.loadConceptsAndSyncWithLocal(context: modelContext)
                                _ = try questionService.loadQuestionsAndSyncWithLocal(context: modelContext)
                            } catch {
                                print("❌ 데이터 싱크가 실패했습니다.")
                            }
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
                        case .navigateToQuizPlay(let subject, let quiestionType):
                            return .send(.routing(.push(.featureQuizPlay(.init(sourceType: .subject(subject, quiestionType))))))

                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    case .featureSearchMain(let searchAction):
                        switch searchAction {
                        case .navigateToQuizPlay(let questionItems, let index):
                            return .send(.routing(.push(.featureQuizPlay(.init(sourceType: .searchResult(items: questionItems, index: index))))))

                        case .navigateToStudyDetail(let items, let index):
                            return .send(.routing(.push(.featureStudyDetail(.init(items: items, index: index)))))

                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    case .featureStudyDetail(let studyAction):
                        switch studyAction {
                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    case .featureAuthName(let authAction):
                        switch authAction {
                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        case .navigateToMain:
                            state.appState = .main
                            return .send(.routing(.pop))

                        default:
                            break
                        }

                    case .featureProfileMain(let profileAction):
                        switch profileAction {
                        case .pressedBackBtn:
                            return .send(.routing(.pop))

                        case .navigateToAuthView:
                            state.appState = .login
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
                    if case .navigateToQuizPlay(let subject, let questionType) = action {
                        return .send(.routing(.push(.featureQuizPlay(FeatureQuizPlayReducer.State(sourceType: .subject(subject, questionType))))))
                    }
                    return .none

                case .featureQuizMain(let action):
                    switch action {
                    case .navigateToQuizSubject(let quizTab, let questionType, let quizStartOption):
                        switch quizStartOption {
                        // 언어별, 과목별은 세부 과목 선택
                        case .startLanguageQuiz, .startSubjectQuiz:
                            return .send(.routing(.push(.featureQuizSubject(FeatureQuizSubjectReducer.State(selectedQuizTab: quizTab, selectedQuestionType: questionType, selectedStartOption: quizStartOption)))))

                        // 랜덤 퀴즈는 바로 진입
                        case .startRandomQuiz:
                            return .send(.routing(.push(.featureQuizPlay(.init(sourceType: .random(quizTab, questionType))))))
                        }

                    case .navigateToSearch(let source):
                        return .send(.routing(.push(.featureSearchMain(.init(source: source)))))

                    case .navigateToProfileMain:
                        return .send(.routing(.push(.featureProfileMain(.init()))))

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
                    case .navigateToSearch(let source):
                        return .send(.routing(.push(.featureSearchMain(.init(source: source)))))

                    case .navigateToStudyDetail(let items, let index):
                        return .send(.routing(.push(.featureStudyDetail(.init(items: items, index: index)))))

                    default:
                        return .none
                    }

                case .featureBookmarkMain(let action):
                    switch action {
                    case .navigateToQuizPlay(let items, let index):
                        return .send(.routing(.push(.featureQuizPlay(.init(sourceType: .fromBookmark(items: items, index: index))))))

                    case .navigateToStudyDetail(let items, let index):
                        return .send(.routing(.push(.featureStudyDetail(.init(items: items, index: index)))))

                    default:
                        break
                    }

                case .featureSearchMain(let action):
                    switch action {
                    default:
                        return .none
                    }

                case .featureAuth(let action):
                    print("RootFeature :: AuthFeature = \(action)")
                    switch action {
                    case .signInCompleted(let user):
                        state.appState = .main
                        return .none

                    case .navigateToAuthNameView:
                        return .send(.routing(.push(.featureAuthName(.init()))))

                    default:
                        break
                    }
                    return .none

                default:
                    return .none
                }

                return .none
            }

            // ✅ 내비게이션 관련 로직을 제거하고, RoutingReducer로 위임
            Scope(state: \.routing, action: \.routing) { RootRoutingReducer() }

            /// FeatureAuth
            Scope(state: \.featureAuth, action: \.featureAuth) { AuthFeatureReducer() }
            Scope(state: \.featureAuthName, action: \.featureAuthName) { FeatureAuthNameReducer() }

            /// FeatureQuiz
            Scope(state: \.featureQuizMain, action: \.featureQuizMain) { FeatureQuizMainReducer() }
            Scope(state: \.featureQuizSubject, action: \.featureQuizSubject) { FeatureQuizSubjectReducer() }
            Scope(state: \.featureQuizPlay, action: \.featureQuizPlay) { FeatureQuizPlayReducer() }

            /// FeatureStudy
            Scope(state: \.featureStudyMain,action: \.featureStudyMain) { FeatureStudyMainReducer() }
            Scope(state: \.featureStudyDetail,action: \.featureStudyDetail) { FeatureStudyDetailReducer() }

            /// FeatureBookmark
            Scope(state: \.featureBookmarkMain, action: \.featureBookmarkMain) { FeatureBookmarkMainReducer() }

            /// FeatureSearchMain
            Scope(state: \.featureSearchMain, action: \.featureSearchMain, child: { FeatureSearchMainReducer() })

            /// FeatureProfileMain
            Scope(state: \.featureProfileMain, action: \.featureProfileMain, child: { FeatureProfileMainReducer() })
        }
    }

    @Reducer
    public enum Path { }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch GlobalRouteObserver.shared.currentRoute {
        case .featureQuizPlay, .featureStudyDetail:
            return false

        default:
            return viewControllers.count > 1 && presentedViewController == nil
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
