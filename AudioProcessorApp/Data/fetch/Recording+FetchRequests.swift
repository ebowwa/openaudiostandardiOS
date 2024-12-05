import CoreData

extension Recording {
    
    // MARK: - Fetch Request Helpers
    
    static func activeRecordings(context: NSManagedObjectContext) throws -> [Recording] {
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "isExpired == NO")
        return try context.fetch(request)
    }
    
    static func recordings(byDateRange startDate: Date, endDate: Date, context: NSManagedObjectContext) throws -> [Recording] {
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", startDate as NSDate, endDate as NSDate)
        return try context.fetch(request)
    }
    
    static func recording(byId id: UUID, context: NSManagedObjectContext) throws -> Recording? {
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func expiredRecordings(context: NSManagedObjectContext) throws -> [Recording] {
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "isExpired == YES OR expirationDate <= %@", Date() as NSDate)
        return try context.fetch(request)
    }
    
    static func lastWeekRecordings(context: NSManagedObjectContext) throws -> [Recording] {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "createdAt >= %@", lastWeek as NSDate)
        return try context.fetch(request)
    }
    
    static func recentRecordings(context: NSManagedObjectContext) throws -> [Recording] {
        let calendar = Calendar.current
        let last24Hours = calendar.date(byAdding: .day, value: -1, to: Date())!
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "createdAt >= %@", last24Hours as NSDate)
        return try context.fetch(request)
    }
    
    static func recordings(matchingName searchTerm: String, context: NSManagedObjectContext) throws -> [Recording] {
        let request = NSFetchRequest<Recording>(entityName: "Recording")
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)
        return try context.fetch(request)
    }
}
