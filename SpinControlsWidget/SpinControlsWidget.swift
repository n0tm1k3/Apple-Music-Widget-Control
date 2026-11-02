import SwiftUI
import AppIntents
import MusicKit
import WidgetKit

struct SpinControlsEntry: TimelineEntry {
    let date: Date
    let snapshot: MusicSnapshot
}

struct SpinControlsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpinControlsEntry {
        SpinControlsEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SpinControlsEntry) -> Void) {
        completion(SpinControlsEntry(date: .now, snapshot: MusicSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpinControlsEntry>) -> Void) {
        let entry = SpinControlsEntry(date: .now, snapshot: MusicSnapshot.load())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct SpinControlsWidgetView: View {
    let entry: SpinControlsEntry

    private let green = Color(red: 0.25, green: 0.88, blue: 0.48)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [green.opacity(0.9), Color(red: 0.05, green: 0.35, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "music.note")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.8))
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.snapshot.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.snapshot.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                    Text("APPLE MUSIC")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(green)
                }
                Spacer(minLength: 0)
            }

            HStack {
                Button(intent: ToggleShuffleIntent()) {
                    Image(systemName: "shuffle")
                        .foregroundStyle(entry.snapshot.isShuffling ? green : .white.opacity(0.65))
                }
                .accessibilityLabel("Toggle shuffle")
                Spacer()
                Button(intent: PreviousTrackIntent()) {
                    Image(systemName: "backward.end.fill")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Previous track")
                Spacer()
                Button(intent: TogglePlaybackIntent()) {
                    Image(systemName: entry.snapshot.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(.black)
                        .frame(width: 42, height: 42)
                        .background(.white, in: Circle())
                }
                .accessibilityLabel(entry.snapshot.isPlaying ? "Pause" : "Play")
                Spacer()
                Button(intent: NextTrackIntent()) {
                    Image(systemName: "forward.end.fill")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Next track")
            }
            .font(.system(size: 17, weight: .semibold))
            .buttonStyle(.plain)
        }
        .padding(16)
        .containerBackground(Color(red: 0.055, green: 0.06, blue: 0.07), for: .widget)
    }
}

@main
struct SpinControlsWidget: Widget {
    let kind = "SpinControlsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpinControlsProvider()) { entry in
            SpinControlsWidgetView(entry: entry)
        }
        .configurationDisplayName("SpinControls")
        .description("Control Apple Music playback from your Home Screen.")
        .supportedFamilies([.systemMedium])
    }
}
