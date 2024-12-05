import SwiftUI

struct RecordingControls: View {
    @ObservedObject var audioManager: AudioManager
    let recordingName: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(audioManager.isRecording ? Color.red : Color.blue)
                .frame(width: 80, height: 80)
                .onTapGesture {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    } else {
                        audioManager.startRecording(name: recordingName)
                    }
                }
            
            Text(audioManager.isRecording ? "Stop Recording" : "Start Recording")
                .font(.headline)
                .padding(.bottom)
        }
    }
}
