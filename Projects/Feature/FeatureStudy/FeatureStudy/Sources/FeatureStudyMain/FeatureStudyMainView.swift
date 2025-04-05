//
//  FeatureStudyMainView.swift
//  FeatureStudy
//
//  Created by 정진균 on 3/1/25.
//

import ComposableArchitecture
import SwiftUI
import UIComponents
import Model

public struct FeatureStudyMainView: View {
    public let store: StoreOf<FeatureStudyMainReducer>

    public init(store: StoreOf<FeatureStudyMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe:  { $0 }) { viewStore in
            VStack {
                NaviBar(type: .study, title: "개념학습", trailing1: {
                    store.send(.navigateToSearch(.study))
                })
                ScrollView {
                    if let recentItem = viewStore.recentItem {
                        HStack {
                            Text("최근 본")
                                .foregroundStyle(Color.Grayscale._800)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 20)

                            Spacer()
                        }

                        ConceptListCell(
                            concept: recentItem,
                            type: .continueLearning,
                            onTap: {
                                print("계속 공부하자!")
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }

                    HStack {
                        Text("모든 개념")
                            .foregroundStyle(Color.Grayscale._800)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)

                        Spacer()
                    }
                    .padding(.top, 15)

                    HStack {
                        SortingBtnView(title: viewStore.selectedSortOption?.displayName ?? SortOption.az.displayName, onTap: {
                            viewStore.send(.showSheet(true))
                        })
                        .sheet(
                            isPresented: viewStore.binding(
                                get: \.isSheetPresented,
                                send: FeatureStudyMainReducer.Action.showSheet
                            )
                        ) {
                            SortBottomSheetView(
                                selectedOption: viewStore.selectedSortOption,
                                onSelect: { viewStore.send(.selectSortOption($0)) },
                                onClose: { viewStore.send(.dismiss) }
                            )
                            .presentationDetents(
                                [.height(320)]
                            )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    LazyVStack {
                        ForEach(Array(zip(store.concepts.indices, store.concepts)), id: \.1.id) { index, data in
                            ConceptListCell(
                                concept: data,
                                type: .regular,
                                onTap: {
                                    print("Tapped index: \(index), title: \(data.title)")
                                    viewStore.send(.selectItem(index))
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }
                    }
                }
            }
            .task {
                viewStore.send(.onAppear)
            }
        }
        .background(Color.Background._2)
    }
}

struct FeatureStudyMainView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureStudyMainView(
            store: Store(
                initialState: FeatureStudyMainReducer.State(),
                reducer: { FeatureStudyMainReducer() }
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
