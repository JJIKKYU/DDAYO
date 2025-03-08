//
//  FeatureQuizMainView.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import Model
import SwiftUI
import UIComponents

public struct FeatureQuizMainView: View {
    public let store: StoreOf<FeatureQuizMainReducer>
    @Namespace private var animationNamespace  // matchedGeometryEffect 사용
    @State private var internalSelectedTab: QuizTab = .실기

    public init(store: StoreOf<FeatureQuizMainReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Tabs(
                    tabs: [
                        .init(tab: .필기, title: "필기"),
                        .init(tab: .실기, title: "실기")
                    ],
                    animationNamespace: animationNamespace,
                    selectedTab: viewStore.binding(
                        get: \.selectedTab,
                        send: FeatureQuizMainReducer.Action.selectTab
                    )
                )
                .padding(.init(top: 0, leading: 20, bottom: 50, trailing: 20))

                TabView(
                    selection: viewStore.binding(
                        get: \.selectedTab,
                        send: { .swipeTab($0) }
                    )) {
                        VStack(spacing: 40) {
                            if let sections = viewStore.examSections[.필기] {
                                ForEach(sections.indices, id: \.self) { index in
                                    let section = sections[index]
                                    ExamSectionView(
                                        title: section.title,
                                        subtitle: section.subtitle,
                                        buttons: section.buttons.map ({ $0.title }),
                                        onTap: {
                                            viewStore.send(.navigateToQuizSubject(.필기))
                                        }
                                    )
                                }
                            }

                            Spacer()
                        }
                        .tag(QuizTab.필기)

                        VStack(spacing: 40) {
                            if let sections = viewStore.examSections[.실기] {
                                ForEach(sections.indices, id: \.self) { index in
                                    let section = sections[index]
                                    ExamSectionView(
                                        title: section.title,
                                        subtitle: section.subtitle,
                                        buttons: section.buttons.map ({ $0.title }),
                                        onTap: {
                                            viewStore.send(.navigateToQuizSubject(.실기))
                                        }
                                    )
                                }
                            }

                            Spacer()
                        }
                        .tag(QuizTab.실기)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewStore.selectedTab)
            }
            .border(.red, width: 1)
        }
    }
}

struct FeatureQuizMainView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureQuizMainView(
            store: Store(
                initialState: FeatureQuizMainReducer.State(),
                reducer: { FeatureQuizMainReducer() }
            )
        )
    }
}

struct TabScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        print("value = \(value), nextValue() = \(nextValue())")
        value = nextValue()
    }
}
