// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Fibs",
    platforms: [.macOS(.v10_12)],
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.9.1")),
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
              "ShellOut"
            ]
        ),
        .testTarget(
          name: "fibs-core-tests",
          dependencies: [
              .target(name: "fibs-core"),
              "ShellOut"
            ]
        )
    ]
)
