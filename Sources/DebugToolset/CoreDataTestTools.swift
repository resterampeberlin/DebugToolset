//
//  CoreDataTest.swift
//  
//
//  Created by Markus Nickels on 01.05.20.
//

import Foundation
import CoreData

/// A general Core data debug helper
public struct CoreDataTest {
    
    private(set) var container: NSPersistentContainer
            
    /// Return the NSManagedObjectContext
    public var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    /// Initializer
    /// - Parameter container: a valid container
    public init(container: NSPersistentContainer) {
        self.container = container
    }
    
    /// Print all attached stoes
    public func printStores() {
        for store in container.persistentStoreCoordinator.persistentStores {
            std.info("Attached store type: \(store.type) url:", store.url?.relativeString ?? "<empty>", highlight: .none)
        }
    }

    /// Add a persistent store an load it
    /// - Parameter storeURL: URL to the attached store
    public mutating func setStore(at storeURL: URL) {
        do {
            let coordinator = container.persistentStoreCoordinator
            
            context.processPendingChanges()
            save()
            
            // exchange all attached stores
            for store in coordinator.persistentStores {
                // try coordinator.remove(store)
                coordinator.setURL(storeURL, for: store)
                
                std.info("Attached store changed", store.type, store.url?.relativeString ?? "<empty>")
            }
/*
            // add test store
            let newStore = NSPersistentStoreDescription(url: storeURL)
            
            newStore.type = NSSQLiteStoreType
            newStore.shouldAddStoreAsynchronously = false
            newStore.configuration = "Default"
                        
            coordinator.addPersistentStore(with: newStore) { store, error in
                guard error == nil else {
                    std.error("Could not load persistent stores. \(error!)")
                    
                    return
                }
                
                std.info("Store added:", store)
            }
*/
            printStores()
        }
        catch {
            std.error("Exception occured \(error)")
        }
    }
    
    /// Delete entire persistant store
    public func resetStore() {
        let coordinator = container.persistentStoreCoordinator
                
        // delete entire store
        for entity in container.managedObjectModel.entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let count = try? context.count(for: fetchRequest)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try coordinator.execute(deleteRequest, with: context)
            }
            catch {
                // BatchDelete could lead to an inconsistent data model since it does not respect
                // relationships. In this case I do not care, because I am deleting the whole store, so at the end
                // it will be consistent
                // see https://www.avanderlee.com/swift/nsbatchdeleterequest-core-data/
                std.info("Exception occured \(error) which is probably ok", highlight: .none)
            }
            
            std.info("\(count!) records for \(entity.name!) deleted")
        }
    }
    
    /// Save persistant store
    public func save() {
        do {
            try context.save()
        }
        catch {
            std.error("Exception occured \(error)")
        }
        
        std.info("Store succesfully saved")
    }
}
