//
//  QuizPopupMessageContext.swift
//  Model
//
//  Created by 정진균 on 4/19/25.
//

import Foundation

public enum QuizPopupMessageContext {
    case allDoneFromBookmark
    case allDoneFromRandom
    case allDoneFromSubject(next: String?)
    case allDoneFromLanguage(next: String?)
    case notYetDone
}

