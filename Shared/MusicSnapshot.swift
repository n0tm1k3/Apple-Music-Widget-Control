import Foundation
import MusicKit

/// Small, non-sensitive snapshot shared between the app, intents, and widget.
struct MusicSnapshot: Codable {
    var title: String
    var artist: String
    var isPlaying: Bool
    var isShuffling: Bool
    var updatedAt: Date

    static let defaults = UserDefaults(suiteName: "group.com.example.SpinControls")
    static let storageKey = "musicSnapshot"

    static var placeholder: MusicSnapshot {
        MusicSnapshot(
            title: "Nothing playing",
            artist: "Start music in Apple Music",
            isPlaying: false,
            isShuffling: false,
            updatedAt: .now
        )
    }

    static func load() -> MusicSnapshot {
        guard
            let data = defaults?.data(forKey: storageKey),
            let snapshot = try? JSONDecoder().decode(MusicSnapshot.self, from: data)
        else {
            return .placeholder
        }
        return snapshot
    }

    static func save(_ snapshot: MusicSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: storageKey)
    }

    @MainActor
    static func refreshFromSystemPlayer() {
        let player = SystemMusicPlayer.shared
        let entry = player.queue.currentEntry
        let title = entry?.title ?? "Nothing playing"
        let artist = entry?.subtitle ?? "Start music in Apple Music"

        save(
            MusicSnapshot(
                title: title,
                artist: artist,
                isPlaying: player.state.playbackStatus == .playing,
                isShuffling: player.state.shuffleMode == .songs,
                updatedAt: .now
            )
        )
    }
}
