//
//  FeatureStudyMainReducer.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/1/25.
//

import ComposableArchitecture
import Model

@Reducer
public struct FeatureStudyMainReducer {

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        var concepts: [ConceptItem] = [
            .init(title: "가. 개념학습 1", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 1),
            .init(title: "나. 개념학습 2", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 223),
            .init(title: "다. 개념학습 3", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 3),
            .init(title: "아. 개념학습 4", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 44),
            .init(title: "카. 개념학습 5", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 51),
            .init(title: "하. 개념학습 6", description: "안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다 안녕하세요 반갑습니다", views: 6),
        ]
        var isSheetPresented: Bool = false
        var selectedSortOption: String? = nil
        // bottomSheet에서 선택한 값을 임시로 저장하고
        // bottomSheet이 없어질때 반영하기 위해서 임시 저장
        var tempSortOption: String? = nil
        @Presents var detail: FeatureStudyDetailReducer.State?

        public init() {}
    }

    public enum Action {
        case pressedSearchBtn
        case showSheet(Bool)

        case selectSortOption(String?)
        case selectItem(Int)
        case navigateToStudyDetail(Int)
        case presentDetail(PresentationAction<FeatureStudyDetailReducer.Action>)
        case test
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .test:
                return .none

            case .pressedSearchBtn:
                print("pressedSearchBtn! -> 다른 스크린으로 이동하는 로직 만들기")
                return .none

            case .showSheet(let isPresented):
                state.isSheetPresented = isPresented

                // bottomSheet가 닫히는데 유저가 선택한 값이 있으면 반영
                if isPresented == false,
                   let tempSortOption = state.tempSortOption {

                    if state.selectedSortOption == "적게 읽은 순" {
                        state.concepts = state.concepts.sorted(by: { $0.views < $1.views })
                    } else if state.selectedSortOption == "많이 읽은 순" {
                        state.concepts = state.concepts.sorted(by: { $0.views > $1.views })
                    } else if state.selectedSortOption == "A-Z순" {
                        state.concepts = state.concepts.sorted(by: { $0.title < $1.title })
                    } else if state.selectedSortOption == "Z-A순" {
                        state.concepts = state.concepts.sorted(by: { $0.title > $1.title })
                    }

                    state.selectedSortOption = tempSortOption
                    state.tempSortOption = nil
                }
                return .none

            case let .selectSortOption(option):
                state.tempSortOption = option
                return .run { send in
                    await send(.showSheet(false))
                }

            // index는 변경 필요
            case .selectItem(let index):
                state.detail = FeatureStudyDetailReducer.State.init()
                return .none

            case .presentDetail(.presented(.dismiss)):
                state.detail = nil
                return .none

            case .presentDetail(let action):
                return .none

            case .navigateToStudyDetail:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentDetail) {
            FeatureStudyDetailReducer()
        }
    }
}
