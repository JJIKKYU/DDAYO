//
//  ImageItem.swift
//  Model
//
//  Created by JJIKKYU on 3/31/25.
//

import Foundation
import SwiftData

@Model
public final class ImageItem {
    public var data: Data         // 이미지 바이너리 데이터
    public var filename: String? // 선택사항

    public init(data: Data, filename: String? = nil) {
        self.data = data
        self.filename = filename
    }
}
