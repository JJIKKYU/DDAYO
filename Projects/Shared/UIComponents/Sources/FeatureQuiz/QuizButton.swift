//
//  QuizButton.swift
//  UIComponents
//
//  Created by 정진균 on 3/8/25.
//

import SwiftUI

public struct QuizButton: View {
    public let title: String
    public let onTap: () -> Void

    public init(title: String, onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .foregroundColor(Color.Grayscale._800)
                    .font(.system(size: 18, weight: .medium))
                Spacer()
            }
            .padding()
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.Grayscale.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.Grayscale._100, lineWidth: 1)
            )
        }
    }
}
