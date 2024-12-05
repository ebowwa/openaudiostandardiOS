import Foundation

// MARK: - Audio File Model
struct AudioFile: Identifiable {
    let id = UUID()
    let url: URL
    let createdAt: Date
    
    var fileName: String {
        url.lastPathComponent
    }
    
    var filePath: String {
        url.path
    }
}

// MARK: - File Manager Service
protocol FileManaging {
    func loadExistingRecordings() -> [AudioFile]
    func deleteRecording(at url: URL) throws
    func getDocumentsDirectory() -> URL
    func saveRecording(_ recording: AudioFile) throws
}

class AudioFileManager: FileManaging {
    func loadExistingRecordings() -> [AudioFile] {
        let fileManager = FileManager.default
        let documentsPath = getDocumentsDirectory().path
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            let audioFiles = files.filter { fileName in
                guard let fileType = AudioFileType(rawValue: URL(fileURLWithPath: fileName).pathExtension.lowercased()) else {
                    return false
                }
                return AudioFileType.allCases.contains(fileType)
            }
            
            return audioFiles.compactMap { fileName in
                let url = getDocumentsDirectory().appendingPathComponent(fileName)
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                return AudioFile(url: url, createdAt: creationDate)
            }.sorted(by: { $0.createdAt > $1.createdAt })
        } catch {
            print("Error loading recordings: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteRecording(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveRecording(_ recording: AudioFile) throws {
        // The recording is already in the documents directory
        // Just ensure it exists
        // TODO: rename this function more appropriately
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: recording.url.path) {
            throw NSError(domain: "AudioFileManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Recording file not found"])
        }
    }
}
