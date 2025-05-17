//
//  QuizSubject.swift
//  Model
//
//  Created by 정진균 on 3/8/25.
//

public enum QuizSubject: String, CaseIterable, Codable {
    // 필기 과목
    case softwareDesign = "소프트웨어 설계"
    case softwareDevelopment = "소프트웨어 개발"
    case databaseConstruction = "데이터베이스 구축"
    case programmingLanguageWritten = "프로그래밍 언어 활용"
    case informationSystemManagement = "정보 시스템 구축 관리"

    // 실기 과목
    case requirementsAnalysis = "요구사항 확인"
    case dataInputOutput = "데이터 입출력 구현"
    case integrationImplementation = "통합 구현"
    case serverProgramming = "서버프로그램 구현"
    case interfaceImplementation = "인터페이스 구현"
    case screenDesign = "화면 설계"
    case applicationTesting = "애플리케이션테스트 관리"
    case sqlApplication = "SQL 응용"
    case softwareSecurity = "소프트웨어 개발 보안 구축"
    case programmingLanguagePractical = "프로그래밍 언어 활용_실기"
    case basicApplicationTech = "응용SW기초 기술 활용"
    case softwarePackaging = "제품소프트웨어 패키징"

    // 실기 언어 과목
    case c = "프로그래밍 언어 활용_실기_C"
    // case cpp = "프로그래밍 언어 활용_실기_Cpp"
    case java = "프로그래밍 언어 활용_실기_JAVA"
    case python = "프로그래밍 언어 활용_실기_Python"
}

// MARK: - DisplayName
public extension QuizSubject {
    var displayName: String {
        switch self {
        case .c:
            return "C"

        /*
        case .cpp:
            return "C++"
        */

        case .java:
            return "Java"

        case .python:
            return "Python"

        case .programmingLanguageWritten,
             .programmingLanguagePractical:
            return "프로그래밍 언어 활용"

        default:
            return self.rawValue
                .replacingOccurrences(of: "_필기", with: "")
                .replacingOccurrences(of: "_실기", with: "")
        }
    }
}

// MARK: - Case

public extension QuizSubject {
    static var writtenCases: [QuizSubject] {
        return [
            .softwareDesign,
            .softwareDevelopment,
            .databaseConstruction,
            .programmingLanguageWritten,
            .informationSystemManagement
        ]
    }

    static var practicalCases: [QuizSubject] {
        return [
            .requirementsAnalysis,
            .dataInputOutput,
            .integrationImplementation,
            .serverProgramming,
            .interfaceImplementation,
            .screenDesign,
            .applicationTesting,
            .sqlApplication,
            .softwareSecurity,
            .programmingLanguagePractical,
            .basicApplicationTech,
            .softwarePackaging
        ]
    }

    static var practicalLanguageCases: [QuizSubject] {
        return [
            .c,
            // .cpp,
            .java,
            .python
        ]
    }

    var isWrittenCase: Bool {
        return QuizSubject.writtenCases.contains(self)
    }

    var isPracticalCase: Bool {
        return QuizSubject.practicalCases.contains(self)
    }

    var isPracticalLanguageCase: Bool {
        return QuizSubject.practicalLanguageCases.contains(self)
    }

    var group: [QuizSubject] {
        if QuizSubject.writtenCases.contains(self) {
            return QuizSubject.writtenCases
        } else if QuizSubject.practicalCases.contains(self) {
            return QuizSubject.practicalCases
        } else if QuizSubject.practicalLanguageCases.contains(self) {
            return QuizSubject.practicalLanguageCases
        } else {
            return []
        }
    }

    var quizTab: QuizTab? {
        if QuizSubject.writtenCases.contains(self) {
            return .필기
        } else if QuizSubject.practicalCases.contains(self) || QuizSubject.practicalLanguageCases.contains(self) {
            return .실기
        } else {
            return nil
        }
    }

    // 필기, 실기, 언어 별로 문제 풀기 과목 순서
    var index: Int {
        if let idx = QuizSubject.writtenCases.firstIndex(of: self) {
            return idx
        } else if let idx = QuizSubject.practicalCases.firstIndex(of: self) {
            return idx
        } else if let idx = QuizSubject.practicalLanguageCases.firstIndex(of: self) {
            return idx
        } else {
            return 0
        }
    }

    // 로그용 디테일 String
    var logSubjectDetail: String {
        if let idx = QuizSubject.writtenCases.firstIndex(of: self) {
            return "t\(idx)"
        } else if let idx = QuizSubject.practicalCases.firstIndex(of: self) {
            return "p\(idx)"
        } else if QuizSubject.practicalLanguageCases.contains(self) {
            return self.rawValue
        } else {
            return ""
        }
    }
}
