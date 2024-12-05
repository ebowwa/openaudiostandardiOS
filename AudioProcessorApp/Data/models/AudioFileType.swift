import Foundation
import AVFoundation

enum AudioFileType: String, CaseIterable {
    case m4a = "m4a"      // Default
    case aac = "aac"
    case wav = "wav"
    case mp3 = "mp3"
    case raw = "bytes"    // Raw audio bytes
    
    static var `default`: AudioFileType { .m4a }
    
    var fileExtension: String {
        return rawValue
    }
    
    var mimeType: String {
        switch self {
        case .wav:
            return "audio/wav"
        case .mp3:
            return "audio/mpeg"
        case .m4a:
            return "audio/m4a"
        case .aac:
            return "audio/aac"
        case .raw:
            return "application/octet-stream"
        }
    }
    
    var settings: [String: Any] {
        switch self {
        case .mp3:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEGLayer3),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 128000
            ]
        case .wav:
            return [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16
            ]
        case .m4a, .aac:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        case .raw:
            return [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
        }
    }
    
    var avFileType: AVFileType {
        switch self {
        case .wav:
            return .wav
        case .mp3:
            return .mp3
        case .m4a, .aac:
            return .m4a
        case .raw:
            return .wav  // Using WAV container for raw PCM data
        }
    }
    
    static func type(from url: URL) -> AudioFileType? {
        return AudioFileType(rawValue: url.pathExtension.lowercased())
    }
}
