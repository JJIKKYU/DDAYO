//
//  BookmarkReason.swift
//  Model
//
//  Created by 정진균 on 4/6/25.
//

import Foundation

public enum BookmarkReason: String, Codable, CaseIterable {
    case manual    // 사용자가 직접 북마크한 경우
    case wrong     // 틀린 문제로 자동 북마크된 경우
}
