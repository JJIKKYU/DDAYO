import SwiftUI

public struct SearchResultCellView: View {
    public let keyword: String
    public let result: String
    public let onTap: () -> Void

    public init(
        keyword: String,
        result: String,
        onTap: @escaping () -> Void
    ) {
        self.keyword = keyword
        self.result = result
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(.search)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.Grayscale._900)
                    .frame(width: 16, height: 16)

                if let range = result.range(of: keyword, options: .caseInsensitive) {
                    let prefix = String(result[..<range.lowerBound])
                    let match = String(result[range])
                    let suffix = String(result[range.upperBound...])

                    (
                        Text(prefix)
                            .foregroundColor(Color.Grayscale._900)
                        +
                        Text(match).foregroundColor(Color.Blue._500)
                        +
                        Text(suffix)
                            .foregroundColor(Color.Grayscale._900)
                    )
                    .font(.system(size: 16, weight: .medium))
                } else {
                    Text(result)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.Grayscale._900)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchResultCellView(keyword: "개념", result: "모든 개념을 검색해보세요", onTap: { print("onTap!")} )
}
