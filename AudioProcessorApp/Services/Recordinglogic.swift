// the name of this script is now recordinglogic, which to me implies like this is the logic to record, but it also includes logic on dealing with recordigns i.e. playbacks etc i want that to have its own script
// this script should be titled AudioManager and we should modularize out the recording logic 
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

// MARK: - Audio Recorder Service
protocol AudioRecording {
    func startRecording(name: String) throws
    func stopRecording()
    var isRecording: Bool { get }
}

class AudioRecorderService: AudioRecording {
    private var audioRecorder: AVAudioRecorder?
    private let fileManager: FileManaging
    
    private(set) var isRecording = false
    
    init(fileManager: FileManaging) {
        self.fileManager = fileManager
    }
    
    func startRecording(name: String) throws {
        let fileName = AudioFormatConfig.getFileName(baseName: name)
        let audioFilename = fileManager.getDocumentsDirectory().appendingPathComponent(fileName)
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: AudioFormatConfig.recordingSettings)
        audioRecorder?.record()
        isRecording = true
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
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
    
    func playRecording(url: URL) {
        do {
            if isPlaying {
                stopPlayback()
            }
            
            // Setup audio session before playback
            try audioSessionManager.setupAudioSession()
            
            print("Attempting to play audio file at: \(url.path)")
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            guard let player = audioPlayer else {
                print("Failed to initialize audio player")
                return
            }
            
            // Prepare the audio player
            player.prepareToPlay()
            player.delegate = self
            
            // Start playback
            if player.play() {
                isPlaying = true
                currentlyPlayingURL = url
                print("Successfully started audio playback")
                
                // Start timer for progress updates
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
            
            // Reset playback state
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
