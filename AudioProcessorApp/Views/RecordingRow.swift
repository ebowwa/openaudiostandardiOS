import SwiftUI
import AVFoundation

struct RecordingRow: View {
    let audioFile: AudioFile
    let onDelete: () -> Void
    @ObservedObject var audioManager: AudioManager
    
    private var isPlaying: Bool {
        audioManager.isPlaying && audioManager.currentlyPlayingURL == audioFile.url
    }
    
    var body: some View {
        HStack {
            Button(action: {
                audioManager.togglePlayback(for: audioFile.url)
            }) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                AudioWaveformView(
                    isPlaying: isPlaying,
                    duration: 0, // TODO: Add actual duration
                    progress: audioManager.playbackProgress
                )
                
                HStack {
                    Text(audioFile.fileName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(DateFormatterUtil.shared.string(from: audioFile.createdAt))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .swipeActions {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
