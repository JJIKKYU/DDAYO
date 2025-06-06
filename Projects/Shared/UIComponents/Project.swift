@preconcurrency import ProjectDescription

let project = Project(
    name: "UIComponents",
    targets: [
        // Framework
        .target(
            name: "UIComponents",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.UIComponents",
            infoPlist: .default,
            sources: ["./Sources/**"],
            resources: ["./Resources/**"],
            dependencies: [
                .project(target: "Model", path: "../Model", status: .required, condition: nil)
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
    ]
)
