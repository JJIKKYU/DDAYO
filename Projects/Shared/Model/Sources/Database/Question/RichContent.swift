//
//  RichContent.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation
import SwiftData

@Model
public final class RichContent {
    public var text: String

    // 이미지 여러 개를 저장할 수 있도록 관계형 구조
    @Relationship(deleteRule: .cascade)
    public var images: [ImageItem]? = nil

    public init(text: String, images: [ImageItem]? = nil) {
        self.text = text
        self.images = images
    }
}
