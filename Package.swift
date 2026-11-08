// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TreeSitterXo",
    products: [
        .library(name: "TreeSitterXo", targets: ["TreeSitterXo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterXo",
            dependencies: [],
            path: ".",
            sources: [
                "src/parser.c",
                "src/scanner.c",
            ],
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterXoTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterXo",
            ],
            path: "bindings/swift/TreeSitterXoTests"
        )
    ],
    cLanguageStandard: .c11
)
