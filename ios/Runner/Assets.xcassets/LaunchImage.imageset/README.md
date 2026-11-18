# iOS launch image

The native iOS launch storyboard displays this image set before Flutter starts. Keep the 1×, 2× and 3× image filenames in sync with the [asset catalog](Contents.json).

On macOS, run `open ios/Runner.xcworkspace` from the repository root. In Xcode, select **Runner → Assets.xcassets → LaunchImage** and replace the three images. The subsequent Flutter splash screen uses the bundled [Flutter artwork](../../../../docs/design/assets.md).
