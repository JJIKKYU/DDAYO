// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "Alamofire": .framework,
            "DeviceKit": .framework,
            "SwiftCollections": .framework,
            "SwiftUIIntrospect": .framework,
            "ComposableArchitecture": .framework,
            "ComposableUserNotifications": .framework,
            "CustomKeyboardKit": .framework,
            "Dependencies": .framework,
            "OrderedCollections": .framework,
            "Perception": .framework,
            "CombineSchedulers": .framework,
            "XCTestDynamicOverlay": .framework,
            "ConcurrencyExtras": .framework,
            "IssueReporting": .framework,
            "PerceptionCore": .framework
        ]
    )
#endif

let package = Package(
    name: "DDAYO",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.6.0")
    ]
)
