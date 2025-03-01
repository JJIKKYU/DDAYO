@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureQuiz",
    targets: [
        // Framework
        .target(
            name: "FeatureQuiz",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureQuiz",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureQuiz/Sources/**"],
            resources: ["FeatureQuiz/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),

                // Shared
                .project(target: "UIComponents", path: "../../Shared/UIComponents", status: .required, condition: nil)
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        // UnitTests
        .target(
            name: "FeatureQuizTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureQuizTests",
            infoPlist: .default,
            sources: ["FeatureQuiz/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureQuiz")]
        ),
    ]
)
