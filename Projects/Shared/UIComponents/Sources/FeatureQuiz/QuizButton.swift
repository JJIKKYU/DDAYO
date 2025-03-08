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
