//
//  ExamSectionView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct ExamSectionView: View {
    public let title: String
    public let isAi: Bool
    public let subtitle: String
    public let buttons: [(title: String, action: () -> Void)]

    public init(
        title: String,
        isAi: Bool,
        subtitle: String,
        buttons: [(title: String, action: () -> Void)]
    ) {
        self.title = title
        self.isAi = isAi
        self.subtitle = subtitle
        self.buttons = buttons
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundStyle(Color.Grayscale._800)

                if isAi {
                    Image(.AI)
                        .frame(width: 20, height: 20)
                }
            }

            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.Grayscale._400)
                .padding(.bottom, 6)

            ForEach(buttons.indices, id: \.self) { index in
                let button = buttons[index]
                QuizButton(title: button.title, onTap: button.action)
            }
        }
        .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}
