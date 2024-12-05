import Foundation
import CoreData

@objc(Recording)
public class Recording: NSManagedObject {
    @NSManaged public var audioData: Data?
    @NSManaged public var audioUrl: URL?
    @NSManaged public var createdAt: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isExpired: Bool
    @NSManaged public var name: String?
    
    // Convenience initializer
    @discardableResult
    static func create(in context: NSManagedObjectContext,
                      name: String,
                      audioData: Data? = nil,
                      audioUrl: URL? = nil) -> Recording {
        let recording = Recording(context: context)
        recording.id = UUID()
        recording.name = name
        recording.audioData = audioData
        recording.audioUrl = audioUrl
        recording.createdAt = Date()
        recording.isExpired = false
        return recording
    }
}

// MARK: - Identifiable
extension Recording: Identifiable {}
