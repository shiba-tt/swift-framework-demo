// swift-tools-version: 6.1
// CookMaster — マルチタイマー料理アシスタント
//
// このファイルはプロジェクト構造の参考用です。
// 実際のビルドは Xcode プロジェクト（.xcodeproj）で行います。
//
// 動作要件:
//   - iOS 26.0+
//   - Xcode 26+
//   - AlarmKit フレームワーク（iOS 26 SDK に含まれる）
//
// ターゲット構成:
//   - CookMaster: メインアプリターゲット
//   - CookMasterWidgets: Widget Extension（Live Activity / Dynamic Island）

import PackageDescription

let package = Package(
    name: "CookMaster",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "CookMaster",
            targets: ["CookMaster"]
        ),
    ],
    targets: [
        .target(
            name: "CookMaster",
            path: "CookMaster",
            exclude: ["Info.plist", "Assets.xcassets"]
        ),
    ]
)
