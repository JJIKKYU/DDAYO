//
//  FeatureQuizMainView.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/4/25.
//

import ComposableArchitecture
import SwiftUI

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

// MARK: - 문제 섹션 뷰
struct ExamSectionView: View {
    let title: String
    let subtitle: String
    let buttons: [String]
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .bold()
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)

            ForEach(buttons, id: \.self) { buttonTitle in
                QuizButton(title: buttonTitle, onTap: onTap)
            }
        }
        .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct QuizButton: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}

// MARK: - 필기/실기 구분 Enum
enum Tab: Hashable {
    case 필기
    case 실기
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

// ✅ 뷰의 중앙 위치를 감지하는 PreferenceKey 정의
struct TabScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        print("value = \(value), nextValue() = \(nextValue())")
        value = nextValue()
    }
}
