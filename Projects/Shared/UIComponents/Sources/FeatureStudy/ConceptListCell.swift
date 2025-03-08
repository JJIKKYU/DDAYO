//
//  FeatureStudyCell.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI
import Model

// MARK: - ConceptListCell

public struct ConceptListCell: View {
    public let concept: ConceptItem
    public let type: ConceptListCellType

    public init(concept: ConceptItem, type: ConceptListCellType) {
        self.concept = concept
        self.type = type
    }

    public var body: some View {
            Button(action: {
                print("Cell tapped")
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "bookmark") // 북마크 아이콘
                            .foregroundColor(.gray)
                        Text(concept.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.bottom, 10)

                    Text(concept.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2) // 최대 2줄까지만 표시
                        .truncationMode(.tail) // 말줄임표 적용
                        .lineSpacing(5)
                        .padding(.bottom, 14)

                    switch type {
                    case .regular:
                        HStack {
                            Image(systemName: "eye") // 조회수 아이콘
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)

                            Text("\(concept.views)회")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Spacer()
                        }

                    case .continueLearning:
                        ContinueLearningButton {
                            print("버튼 누름!")
                        }
                    }

                }
                .padding()
                .background(Color(.systemGray6)) // 카드 느낌의 배경
                .cornerRadius(12) // 모서리 둥글게
                .shadow(radius: 1) // 약간의 그림자 효과
            }
            .buttonStyle(PlainButtonStyle()) // 버튼 효과 제거 (텍스트만 보이게)
        }
}

// Preview
struct ConceptListView_Previews: PreviewProvider {
    static var previews: some View {
        let concept: ConceptItem = .init(
            title: "개념학습 1",
            description: "이것은 첫 번째 개념입니다. 최대 두 줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.줄까지 노출됩니다.",
            views: 120
        )

        VStack(alignment: .leading, spacing: 12) {
            ConceptListCell(concept: concept, type: .regular)
            ConceptListCell(concept: concept, type: .continueLearning)
        }
    }
}
