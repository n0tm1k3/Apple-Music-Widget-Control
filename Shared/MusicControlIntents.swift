import AppIntents
import MusicKit
import WidgetKit

/// These intents run in the containing app process because they adopt AudioPlaybackIntent.
/// This lets the widget control the shared SystemMusicPlayer rather than owning a separate player.
struct TogglePlaybackIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Play or Pause Apple Music"
    static var description = IntentDescription("Toggles playback in the Apple Music app.")

    func perform() async throws -> some IntentResult {
        let player = SystemMusicPlayer.shared
        if player.state.playbackStatus == .playing {
            player.pause()
        } else {
            try await player.play()
        }
        await MusicSnapshot.refreshFromSystemPlayer()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct NextTrackIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Next Track"
    static var description = IntentDescription("Skips to the next track in Apple Music.")

    func perform() async throws -> some IntentResult {
        try await SystemMusicPlayer.shared.skipToNextEntry()
        await MusicSnapshot.refreshFromSystemPlayer()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct PreviousTrackIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Previous Track"
    static var description = IntentDescription("Skips to the previous track in Apple Music.")

    func perform() async throws -> some IntentResult {
        try await SystemMusicPlayer.shared.skipToPreviousEntry()
        await MusicSnapshot.refreshFromSystemPlayer()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ToggleShuffleIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Toggle Shuffle"
    static var description = IntentDescription("Turns Apple Music shuffle on or off.")

    func perform() async throws -> some IntentResult {
        let player = SystemMusicPlayer.shared
        player.state.shuffleMode = player.state.shuffleMode == .songs ? .off : .songs
        await MusicSnapshot.refreshFromSystemPlayer()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
