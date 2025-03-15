//
//  ContinueLearningButton.swift
//  UIComponents
//
//  Created by 정진균 on 3/1/25.
//

import SwiftUI

struct ContinueLearningButton: View {
    var action: () -> Void // 버튼 액션 핸들러

    var body: some View {
        Button(action: action) {
            Text("이어서 학습하기")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.Grayscale.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.5)
                .background(Color.Green._500)
                .cornerRadius(12)
        }
    }
}

// Preview
struct ContinueLearningButton_Previews: PreviewProvider {
    static var previews: some View {
        ContinueLearningButton {
            print("이어서 학습하기 버튼 클릭됨")
        }
        .padding()
        .previewLayout(.sizeThatFits) // 미리보기에서 크기 맞추기
    }
}
