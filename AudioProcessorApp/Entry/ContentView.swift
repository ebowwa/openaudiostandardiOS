import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var recordingName = "Recording"
    
    var body: some View {
        NavigationView {
            VStack {
                RecordingControls(
                    audioManager: audioManager,
                    recordingName: recordingName
                )
                
                RecordingsList(audioManager: audioManager)
            }
            .padding()
            .navigationTitle("Audio Recorder")
        }
    }
}
