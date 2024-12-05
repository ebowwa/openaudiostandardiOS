import Foundation
import AVFoundation
import CoreData

// MARK: - Audio Session Manager
protocol AudioSessionManaging {
    func setupAudioSession() throws
}

class AudioSessionManager: AudioSessionManaging {
    func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
    }
}

class AudioManager: NSObject, ObservableObject {
    private let audioSessionManager: AudioSessionManaging
    private let fileManager: FileManaging
    private let recorder: AudioRecording
    private var audioPlayer: AVAudioPlayer?
    
    @Published private(set) var recordings: [AudioFile] = []
    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentlyPlayingURL: URL?
    @Published private(set) var playbackProgress: Double = 0.0
    
    override init() {
        self.audioSessionManager = AudioSessionManager()
        self.fileManager = AudioFileManager()
        self.recorder = AudioRecorderService(fileManager: fileManager)
        super.init()
        loadRecordings()
    }
    
    init(audioSessionManager: AudioSessionManaging = AudioSessionManager(),
         fileManager: FileManaging = AudioFileManager(),
         recorder: AudioRecording? = nil) {
        self.audioSessionManager = audioSessionManager
        self.fileManager = fileManager
        self.recorder = recorder ?? AudioRecorderService(fileManager: fileManager)
        super.init()
        loadRecordings()
    }
    
    // MARK: - Recording Methods
    func startRecording(name: String) {
        do {
            try audioSessionManager.setupAudioSession()
            try recorder.startRecording(name: name)
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        recorder.stopRecording()
        isRecording = false
        loadRecordings()
    }
    
    // MARK: - File Management
    func deleteRecording(url: URL) {
        do {
            try fileManager.deleteRecording(at: url)
            loadRecordings()
        } catch {
            print("Failed to delete recording: \(error.localizedDescription)")
        }
    }
    
    private func loadRecordings() {
        recordings = fileManager.loadExistingRecordings()
    }
    
    // MARK: - Playback Methods
    func playRecording(url: URL) {
        do {
            if isPlaying {
                stopPlayback()
            }
            
            try audioSessionManager.setupAudioSession()
            
            print("Attempting to play audio file at: \(url.path)")
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            guard let player = audioPlayer else {
                print("Failed to initialize audio player")
                return
            }
            
            player.prepareToPlay()
            player.delegate = self
            
            if player.play() {
                isPlaying = true
                currentlyPlayingURL = url
                print("Successfully started audio playback")
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                    guard let self = self, let player = self.audioPlayer, player.isPlaying else {
                        timer.invalidate()
                        return
                    }
                    self.playbackProgress = player.currentTime / player.duration
                }
            } else {
                print("Failed to start audio playback")
            }
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
            print("Error domain: \(error._domain)")
            print("Error code: \(error._code)")
            stopPlayback()
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingURL = nil
        playbackProgress = 0.0
    }
    
    func togglePlayback(for url: URL) {
        if isPlaying && currentlyPlayingURL == url {
            stopPlayback()
        } else {
            playRecording(url: url)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlayback()
        }
    }
}
