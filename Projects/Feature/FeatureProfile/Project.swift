@preconcurrency import ProjectDescription

let project = Project(
    name: "FeatureProfile",
    targets: [
        // Framework
        .target(
            name: "FeatureProfile",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.FeatureProfile",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FeatureProfile/Sources/**"],
            resources: ["FeatureProfile/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture", condition: nil),

                // Shared
                .project(target: "Model", path: "../../Shared/Model", status: .required, condition: nil),
                .project(target: "Service", path: "../../Shared/Service", status: .required, condition: nil),
                .project(target: "DI", path: "../../Shared/DI", status: .required, condition: nil),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
        // UnitTests
        .target(
            name: "FeatureProfileTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jjikktu.FeatureProfileTests",
            infoPlist: .default,
            sources: ["FeatureProfile/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FeatureProfile")]
        ),
    ]
)
