//
//  QuizPopupAction.swift
//  Model
//
//  Created by 정진균 on 4/19/25.
//

import Foundation

public enum QuizPopupAction {
    case dismiss            // 배경 클릭 or 나가기
    case keepStudying       // 더 공부하기
    case finishStudy        // 끝내기
    case reviewRandom       // 복습하기
    case nextSubject        // 다음 과목 풀기
    case nextLanguage       // 다음 언어 풀기
    case reviewRandomFromBookmark // 복습하기 (북마크)
}
