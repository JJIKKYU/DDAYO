@preconcurrency import ProjectDescription

let project = Project(
    name: "CoreNetworking",
    targets: [
        // Framework
        .target(
            name: "CoreNetworking",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jjikktu.CoreNetworking",
            infoPlist: .default,
            sources: ["./Sources/**"],
            dependencies: [
                // .external(name: "FirebaseFirestore"),

                // Shared
                .project(target: "Model", path: "../../Shared/Model", status: .required, condition: nil)
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "V237TD2AXA"
                ]
            )
        ),
    ]
)
