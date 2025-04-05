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
    // 이미지 바이너리 데이터
    public var data: Data?
    public var filename: String?

    public init(data: Data?, filename: String? = nil) {
        self.data = data
        self.filename = filename
    }
}
