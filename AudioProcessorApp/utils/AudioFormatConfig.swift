import Foundation
import AVFoundation

struct AudioFormatConfig {
    static let defaultFileType: AudioFileType = .m4a
    
    static var recordingSettings: [String: Any] {
        return defaultFileType.settings
    }
    
    static var avFileType: AVFileType {
        return defaultFileType.avFileType
    }
    
    static func getFileName(baseName: String) -> String {
        return "\(baseName)_\(Date().timeIntervalSince1970).\(defaultFileType.rawValue)"
    }
}
