@preconcurrency import ProjectDescription

let project = Project(
    name: "DDAYO",
    targets: [
        .target(
            name: "DDAYO",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jjikkyu.DDAYO",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["./Sources/**"],
            resources: ["./Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),
                .external(name: "FirebaseAnalytics", condition: nil),

                // Feature
                .project(target: "FeatureQuiz", path: "../Feature/FeatureQuiz", status: .required, condition: nil),
                .project(target: "FeatureStudy", path: "../Feature/FeatureStudy", status: .required, condition: nil),
                .project(target: "FeatureBookmark", path: "../Feature/FeatureBookmark", status: .required, condition: nil),

                // Shared
                .project(target: "UIComponents", path: "../Shared/UIComponents", status: .required, condition: nil),
                .project(target: "Model", path: "../Shared/Model", status: .required, condition: nil)
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        .target(
            name: "DDAYOTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikkyu.DDAYOTests",
            infoPlist: .default,
            sources: ["./Tests/**"],
            resources: [],
            dependencies: [.target(name: "DDAYO")]
        ),
    ]
)
