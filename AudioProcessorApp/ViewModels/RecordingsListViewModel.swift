import Foundation
import Combine

class RecordingsListViewModel: ObservableObject {
    @Published private(set) var recordings: [AudioFile] = []
    private let audioManager: AudioManager
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        self.recordings = audioManager.recordings
        
        // Subscribe to changes in audioManager's recordings
        audioManager.$recordings
            .assign(to: &$recordings)
    }
    
    func deleteRecording(url: URL) {
        audioManager.deleteRecording(url: url)
    }
}
