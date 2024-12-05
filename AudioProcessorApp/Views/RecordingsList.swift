import SwiftUI

struct RecordingsList: View {
    @StateObject private var viewModel: RecordingsListViewModel
    @ObservedObject var audioManager: AudioManager
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        _viewModel = StateObject(wrappedValue: RecordingsListViewModel(audioManager: audioManager))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.recordings) { audioFile in
                RecordingRow(
                    audioFile: audioFile,
                    onDelete: { viewModel.deleteRecording(url: audioFile.url) },
                    audioManager: audioManager
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
