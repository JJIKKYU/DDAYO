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
    public let onTap: (() -> Void)

    public init(
        concept: ConceptItem,
        type: ConceptListCellType,
        onTap: @escaping (() -> Void)
    ) {
        self.concept = concept
        self.type = type
        self.onTap = onTap
    }

    public var body: some View {
            Button(action: {
                print("Cell tapped")
                onTap()
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(concept.title)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.Grayscale._900)

                        Spacer()
                    }
                    .padding(.bottom, 10)

                    Text(concept.desc)
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
                        Image(.eye)
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
            title: "개념 학습 1",
            desc: "내용입니다.",
            views: 0,
            mnemonics: ["안녕하세요"],
            subject: "주제입니다",
            subjectId: 1
        )

        VStack(alignment: .leading, spacing: 12) {
            ConceptListCell(concept: concept, type: .regular, onTap: {
                print("!!")
            })
            ConceptListCell(concept: concept, type: .continueLearning, onTap: {
                print("!!!")
            })
        }
    }
}
