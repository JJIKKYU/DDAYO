@preconcurrency import ProjectDescription

let project = Project(
    name: "Model",
    targets: [
        // Framework
        .target(
            name: "Model",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.Model",
            infoPlist: .default,
            sources: ["./Sources/**"],
            resources: ["./Resources/**"],
            dependencies: [],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
    ]
)
