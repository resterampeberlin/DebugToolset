//
//  File.swift
//  
//
//  Created by Markus Nickels on 01.05.20.
//

import Foundation
import CoreData

/// A general Core data debug helper
public struct CoreDataTest {

    private(set) var container: NSPersistentContainer
    
    public var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    /// Initializer
    /// - Parameter container: a valid container
    public init(container: NSPersistentContainer) {
        self.container = container
    }
    
    /// Delete entire persistant store
    public func reset() {
        let coordinator = container.persistentStoreCoordinator
        
        for store in coordinator.persistentStores {
            std.info("Store attached", store.type, store.url?.relativeString ?? "")
        }
        
        // delete entire store
        for entity in container.managedObjectModel.entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let count = try? context.count(for: fetchRequest)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try coordinator.execute(deleteRequest, with: context)
            }
            catch let error as NSError {
                std.error("Could not delete", error)
            }
            
            std.info("\(count!) records for \(entity.name!) deleted")
        }
    }
    
    /// Save persistant store
    public func save() {
        do {
            try  context.save()
        }
        catch let error as NSError {
            std.error("Could not save store \(error)")
        }
        
        std.info("Store succesfully saved")
    }
}
