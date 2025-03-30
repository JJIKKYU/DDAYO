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
        var selectedSortOption: SortOption? = .az
        // bottomSheet에서 선택한 값을 임시로 저장하고
        // bottomSheet이 없어질때 반영하기 위해서 임시 저장
        var tempSortOption: SortOption? = .az
        @Presents var detail: FeatureStudyDetailReducer.State?

        public init() {
            
        }
    }

    public enum Action {
        case pressedSearchBtn
        case showSheet(Bool)

        case selectSortOption(SortOption?)
        case selectItem(Int)
        case presentDetail(PresentationAction<FeatureStudyDetailReducer.Action>)
        case dismiss
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

                // bottomSheet가 닫히는 시점에만 반영
                if !isPresented, let tempOption = state.tempSortOption {
                    switch tempOption {
                    case .leastViewed:
                        state.concepts.sort { $0.views < $1.views }

                    case .mostViewed:
                        state.concepts.sort { $0.views > $1.views }

                    case .az:
                        state.concepts.sort { $0.title < $1.title }

                    case .za:
                        state.concepts.sort { $0.title > $1.title }
                    }

                    state.selectedSortOption = tempOption
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

            case .dismiss:
                print("FeatureStudyMainReducer :: dismiss")
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentDetail) {
            FeatureStudyDetailReducer()
        }
    }
}
