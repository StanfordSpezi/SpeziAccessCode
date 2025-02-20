// swift-tools-version:5.10

//
// This source file is part of the Spezi open source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziAccessGuard",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziAccessGuard", targets: ["SpeziAccessGuard"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi", from: "1.2.3"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage", from: "2.0.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews", from: "1.3.1")
    ],
    targets: [
        .target(
            name: "SpeziAccessGuard",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziKeychainStorage", package: "SpeziStorage"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ]
        ),
        .testTarget(
            name: "SpeziAccessGuardTests",
            dependencies: [
                .target(name: "SpeziAccessGuard")
            ]
        )
    ]
)
