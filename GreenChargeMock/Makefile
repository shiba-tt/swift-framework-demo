.PHONY: project build clean

# XcodeGen で .xcodeproj を生成
project:
	xcodegen generate

# ビルド（シミュレーター向け）
build: project
	xcodebuild build \
		-project GreenCharge.xcodeproj \
		-scheme GreenCharge \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-configuration Debug

# クリーン
clean:
	xcodebuild clean -project GreenCharge.xcodeproj -scheme GreenCharge 2>/dev/null || true
	rm -rf GreenCharge.xcodeproj
