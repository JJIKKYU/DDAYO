//
//  Text+Markdown.swift
//  UIComponents
//
//  Created by 정진균 on 5/4/25.
//

import Foundation
import SwiftUI

public struct MarkdownTextView: View {
    public let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        textParts.reduce(Text("")) { partialResult, part in
            partialResult + format(part)
        }
    }

    private var textParts: [TextPart] {
        parseMarkdown(text)
    }

    private func format(_ part: TextPart) -> Text {
        switch part.style {
        case .normal:
            return Text(part.content)
        case .bold:
            return Text(part.content).bold()
        }
    }

    private func parseMarkdown(_ text: String) -> [TextPart] {
        var result: [TextPart] = []
        var currentIndex = text.startIndex
        var isBold = false

        while currentIndex < text.endIndex {
            if text[currentIndex...].hasPrefix("**") {
                isBold.toggle()
                currentIndex = text.index(currentIndex, offsetBy: 2)
                continue
            }

            let nextBold = text[currentIndex...].range(of: "**")?.lowerBound ?? text.endIndex
            let endIndex = isBold
                ? text[currentIndex...].range(of: "**")?.lowerBound ?? text.endIndex
                : nextBold

            let substring = String(text[currentIndex..<endIndex])
            result.append(TextPart(content: substring, style: isBold ? .bold : .normal))
            currentIndex = endIndex
        }

        return result
    }

    private struct TextPart {
        let content: String
        let style: Style

        enum Style {
            case normal
            case bold
        }
    }
}
