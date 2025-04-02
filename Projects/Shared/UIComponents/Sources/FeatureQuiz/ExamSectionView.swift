//
//  ExamSectionView.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct ExamSectionView: View {
    public let title: String
    public let subtitle: String
    public let buttons: [(title: String, action: () -> Void)]

    public init(
        title: String,
        subtitle: String,
        buttons: [(title: String, action: () -> Void)]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 20))
                .bold()
                .foregroundStyle(Color.Grayscale._800)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.Grayscale._400)

            ForEach(buttons.indices, id: \.self) { index in
                let button = buttons[index]
                QuizButton(title: button.title, onTap: button.action)
            }
        }
        .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}
