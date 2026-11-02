import SwiftUI
import MusicKit
import WidgetKit

struct ContentView: View {
    @State private var authorizationMessage = "Connect to Apple Music to enable controls."
    @State private var snapshot = MusicSnapshot.load()

    private let player = SystemMusicPlayer.shared

    var body: some View {
        ZStack {
            Color(red: 0.055, green: 0.06, blue: 0.07).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 10) {
                    Image(systemName: "waveform")
                        .font(.title2.bold())
                        .foregroundStyle(Color(red: 0.25, green: 0.88, blue: 0.48))
                    Text("SpinControls")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(snapshot.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(snapshot.artist)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                    Text(authorizationMessage)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.55))
                }

                HStack(spacing: 0) {
                    control("shuffle", active: snapshot.isShuffling) {
                        Task { await run(ToggleShuffleIntent()) }
                    }
                    Spacer()
                    control("backward.end.fill") {
                        Task { await run(PreviousTrackIntent()) }
                    }
                    Spacer()
                    control(snapshot.isPlaying ? "pause.fill" : "play.fill", prominent: true) {
                        Task { await run(TogglePlaybackIntent()) }
                    }
                    Spacer()
                    control("forward.end.fill") {
                        Task { await run(NextTrackIntent()) }
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22))

                Button {
                    Task { await requestAccessAndRefresh() }
                } label: {
                    Text("Connect Apple Music")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.25, green: 0.88, blue: 0.48), in: Capsule())
                }

                Text("Add the SpinControls widget from the iPhone Home Screen widget gallery. Start a playlist in Apple Music first, then use the widget controls.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
        .task { await requestAccessAndRefresh() }
    }

    private func control(
        _ symbol: String,
        active: Bool = false,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: prominent ? 25 : 19, weight: .semibold))
                .foregroundStyle(active ? Color(red: 0.25, green: 0.88, blue: 0.48) : .white)
                .frame(width: prominent ? 54 : 38, height: 54)
                .background(prominent ? Color.white : .clear, in: Circle())
                .foregroundStyle(prominent ? .black : .white)
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func requestAccessAndRefresh() async {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized:
            authorizationMessage = "Apple Music access granted."
            MusicSnapshot.refreshFromSystemPlayer()
            snapshot = MusicSnapshot.load()
            WidgetCenter.shared.reloadAllTimelines()
        case .denied:
            authorizationMessage = "Music access was denied. Enable it in Settings."
        case .restricted:
            authorizationMessage = "Music access is restricted on this device."
        case .notDetermined:
            authorizationMessage = "Music access has not been granted yet."
        @unknown default:
            authorizationMessage = "Could not determine Apple Music access."
        }
    }

    @MainActor
    private func run<I: AppIntent>(_ intent: I) async {
        // Buttons in this companion app call the same player actions as the widget intents.
        do {
            switch intent {
            case is TogglePlaybackIntent:
                if player.state.playbackStatus == .playing { player.pause() }
                else { try await player.play() }
            case is NextTrackIntent:
                try await player.skipToNextEntry()
            case is PreviousTrackIntent:
                try await player.skipToPreviousEntry()
            case is ToggleShuffleIntent:
                player.state.shuffleMode = player.state.shuffleMode == .songs ? .off : .songs
            default:
                break
            }
            MusicSnapshot.refreshFromSystemPlayer()
            snapshot = MusicSnapshot.load()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            authorizationMessage = "Apple Music action failed: \(error.localizedDescription)"
        }
    }
}
