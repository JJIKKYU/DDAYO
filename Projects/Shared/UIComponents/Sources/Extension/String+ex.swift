//
//  Text+ex.swift
//  UIComponents
//
//  Created by 정진균 on 3/9/25.
//

import SwiftUI

extension String {
    var forceCharWrapping: Self {
        self.map({ String($0) }).joined(separator: "\u{200B}") // 200B: 가로폭 없는 공백문자
    }
}
