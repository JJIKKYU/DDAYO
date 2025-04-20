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
    case programmingLanguage = "프로그래밍 언어 활용"
    case informationSystemManagement = "정보시스템 구축 관리"

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
    case basicApplicationTech = "응용SW기초 기술 활용"
    case softwarePackaging = "제품소프트웨어 패키징"

    // 실기 언어 과목
    case c = "c"
    case cpp = "cpp"
    case java = "java"
    case python = "python"
}

public extension QuizSubject {
    static var writtenCases: [QuizSubject] {
        return [
            .softwareDesign,
            .softwareDevelopment,
            .databaseConstruction,
            .programmingLanguage,
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
            .basicApplicationTech,
            .softwarePackaging
        ]
    }

    static var practicalLanguageCases: [QuizSubject] {
        return [
            .c,
            .cpp,
            .java,
            .python
        ]
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
}
