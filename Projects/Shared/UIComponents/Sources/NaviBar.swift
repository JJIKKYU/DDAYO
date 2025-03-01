//
//  NaviBar.swift
//  UIComponents
//
//  Created by 정진균 on 2/22/25.
//

import SwiftUI

public struct NaviBar: View {
    public let title: String
    public let onBack: () -> Void

    public init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    public var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.black)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            Rectangle()
                .fill(Color.clear)
                .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.white)
    }
}

struct NaviBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NaviBar(title: "실기 과목별로 풀기") {
                print("뒤로 가기 버튼 클릭됨")
            }
            Spacer()
        }
        .previewLayout(.sizeThatFits) // 적절한 크기로 미리보기
    }
}
