// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Fibs",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.7.0")),
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.8.0")),
      .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "9.1.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.2.0"),
      .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.6.0"),
      .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.2.0")
    ],
    targets: [
      .target(
        name: "fibs",
        dependencies: [
            .target(name: "fibs-core"),
            "Kitura"
          ]
        ),
        .testTarget(
          name: "fibs-tests",
          dependencies: [
              .target(name: "fibs"),
              "Kitura"
            ]
        ),
        .target(
          name: "fibs-core",
          dependencies: [
              "Kitura",
              "KituraOpenAPI",
              "CloudEnvironment",
              "SwiftMetrics",
              "ShellOut"
            ]
        ),
        .testTarget(
          name: "fibs-core-tests",
          dependencies: [
              .target(name: "fibs-core"),
              "KituraOpenAPI",
              "CloudEnvironment",
              "SwiftMetrics",
              "ShellOut"
            ]
        )
    ]
)
