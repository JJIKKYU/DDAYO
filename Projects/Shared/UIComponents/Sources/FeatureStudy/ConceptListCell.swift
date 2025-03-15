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
                        Text(concept.title)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.Grayscale._900)

                        Spacer()
                    }
                    .padding(.bottom, 10)

                    Text(concept.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.Grayscale._900)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .lineSpacing(5)
                        .padding(.bottom, 14)

                    if type == .continueLearning {
                        ContinueLearningButton {
                            print("이어서학습하기 버튼 누름!")
                        }
                        .padding(.bottom, 8)
                    }

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "eye")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.Grayscale._300)
                            .frame(width: 16, height: 16)
                            .padding(.trailing, 2)

                        Text("\(concept.views)")
                            .font(.system(size: 11))
                            .foregroundColor(Color.Grayscale._400)

                        Spacer()

                        Button {
                            print("Bookmark!!")
                        } label: {
                            Image(.bookmark)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color.Grayscale._300)
                                .frame(width: 24, height: 24)
                        }
                    }

                }
                .padding()
                .background(Color.Grayscale.white)
                .cornerRadius(12)
                .shadow(radius: 1)
            }
            .buttonStyle(PlainButtonStyle())
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
