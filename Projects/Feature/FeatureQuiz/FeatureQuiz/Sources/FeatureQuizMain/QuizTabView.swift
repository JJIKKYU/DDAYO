//
//  Tabs.swift
//  FeatureQuiz
//
//  Created by JJIKKYU on 2/7/25.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Model

struct QuizTabView: View {
    var tabs: [QuizTab]
    let animationNamespace: Namespace.ID

    @Binding var selectedTab: QuizTab
    @State private var tabWidths: [CGFloat] = []
    var onSelectSearch: (() -> Void)
    var onSelectMenu: (() -> Void)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    ForEach(0 ..< tabs.count, id: \.self) { row in
                        Button {
                            selectedTab = tabs[row]
                        } label: {
                            Text(tabs[row].getName())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(selectedTab == tabs[row] ? Color.Green._600 : Color.Grayscale._400)
                                .background(GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            if tabWidths.count < tabs.count {
                                                tabWidths.append(geo.size.width)
                                            }
                                        }
                                })
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button {
                        onSelectSearch()
                    } label: {
                        Image(uiImage: UIComponentsAsset.search.image)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.Grayscale._900)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onSelectMenu()
                    } label: {
                        Image(uiImage: UIComponentsAsset.kebab.image)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.Grayscale._900)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 11)
            .background(
                Rectangle()
                    .fill(Color.Grayscale._100)
                    .frame(height: 1),
                alignment: .bottom
            )

            if let selectedIndex = tabs.firstIndex(where: { $0 == selectedTab }),
               tabWidths.indices.contains(selectedIndex) {
                Rectangle()
                    .fill(Color.Green._600)
                    .frame(width: tabWidths[selectedIndex], height: 3)
                    .offset(x: tabWidths.prefix(selectedIndex).reduce(0, +) + CGFloat(selectedIndex) * 10)
                    .matchedGeometryEffect(id: "underline", in: animationNamespace)
                    .zIndex(10)
                    .padding(.leading, 20)
            }
        }
        .background(Color.Grayscale.white.ignoresSafeArea())
        .animation(.easeInOut, value: selectedTab)
    }
}

struct Tabs_Previews: PreviewProvider {
    @Namespace private static var animationNamespace // matchedGeometryEffect 사용

    static var previews: some View {
        VStack {
            QuizTabView(tabs: [.필기, .실기],
                        animationNamespace: animationNamespace,
                        selectedTab: .constant(.필기),
                        onSelectSearch: { print("onSelectSearch!") },
                        onSelectMenu: { print("onSelectMenu!")}
            )

            Spacer()
        }
    }
}
