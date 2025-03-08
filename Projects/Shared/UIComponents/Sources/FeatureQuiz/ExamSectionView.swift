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
    public let buttons: [String]
    public let onTap: () -> Void

    public init(title: String, subtitle: String, buttons: [String], onTap: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons
        self.onTap = onTap
    }

    public var body: some View {
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
