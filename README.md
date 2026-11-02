# SpinControls

A Spotify-inspired iOS Home Screen widget for controlling the **Apple Music app**.

## What this starter includes

- SwiftUI iPhone app
- WidgetKit medium Home Screen widget
- Interactive shuffle, previous, play/pause, and next buttons
- App Intents using `AudioPlaybackIntent`
- MusicKit `SystemMusicPlayer` integration (controls the Music app's player)
- GitHub Actions macOS workflow that generates the Xcode project and builds an unsigned iOS Simulator app

## Important limitations

1. **A native iOS app cannot be compiled on Windows itself.** The included GitHub Actions workflow uses a GitHub-hosted macOS runner with Xcode.
2. The workflow produces an **unsigned Simulator build**, not an installable iPhone IPA. Installing on a physical iPhone requires Apple code signing and provisioning. TestFlight distribution normally requires Apple Developer Program membership.
3. Apple controls widget refresh scheduling. The widget is interactive, but its displayed song metadata can lag behind playback changes until the next intent-triggered refresh or timeline refresh.
4. MusicKit permissions, Apple Music account access, and a compatible Apple Music subscription may be required for playback control.
5. This is a starter implementation. It must be built and tested on Apple's toolchain before treating it as release-ready.

## Repository setup (Windows)

1. Download and extract this ZIP.
2. Create a new empty GitHub repository named `SpinControls`.
3. In the extracted folder, open PowerShell.
4. Run:

```powershell
git init
git add .
git commit -m "Initial SpinControls iOS widget"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/SpinControls.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username.

## Run the cloud build

1. On GitHub, open your repository.
2. Select **Actions**.
3. Approve GitHub Actions if GitHub asks.
4. Open **Build iOS Simulator app** and choose **Run workflow**.
5. When it finishes, open the workflow run and download the `SpinControls-Simulator-Debug` artifact.

The artifact is for the iOS Simulator. It is useful for validating that Xcode compiles the app and widget extension, but it cannot be installed directly on your iPhone.

## Configure the bundle identifier before signing

The starter uses `com.example.SpinControls`. Before a device release, change this to a unique identifier you control in `project.yml`, and update the App Group identifier in `project.yml` and `Config/SpinControls.entitlements`.

For device installation, configure an Apple Developer team and provisioning profiles in Xcode or a secure signing workflow. Do not put certificates, private keys, or Apple credentials in the repository.

## Project layout

```text
SpinControls/
├── .github/workflows/ios-build.yml
├── Config/SpinControls.entitlements
├── Shared/MusicControlIntents.swift
├── SpinControls/SpinControlsApp.swift
├── SpinControls/ContentView.swift
├── SpinControls/MusicSnapshot.swift
├── SpinControlsWidget/SpinControlsWidget.swift
├── project.yml
└── README.md
```

## Apple documentation

- [SystemMusicPlayer](https://developer.apple.com/documentation/musickit/systemmusicplayer)
- [MusicPlayer](https://developer.apple.com/documentation/musickit/musicplayer)
- [Interactive widgets](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [AudioPlaybackIntent](https://developer.apple.com/documentation/appintents/audioplaybackintent)
