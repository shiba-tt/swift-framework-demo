.PHONY: project build clean

# XcodeGen で .xcodeproj を生成
project:
	xcodegen generate

# ビルド（シミュレーター向け）
build: project
	xcodebuild build \
		-project ProximityParty.xcodeproj \
		-scheme ProximityParty \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-configuration Debug

# クリーン
clean:
	xcodebuild clean -project ProximityParty.xcodeproj -scheme ProximityParty 2>/dev/null || true
	rm -rf ProximityParty.xcodeproj
