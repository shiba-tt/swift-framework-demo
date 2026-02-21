.PHONY: project build clean

# XcodeGen で .xcodeproj を生成
project:
	xcodegen generate

# ビルド（シミュレーター向け）
build: project
	xcodebuild build \
		-project SynthLab.xcodeproj \
		-scheme SynthLab \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-configuration Debug

# クリーン
clean:
	xcodebuild clean -project SynthLab.xcodeproj -scheme SynthLab 2>/dev/null || true
	rm -rf SynthLab.xcodeproj
