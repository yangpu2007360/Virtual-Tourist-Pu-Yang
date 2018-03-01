//
//  CoreDataStack.swift
//
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    // MARK:  - Properties
    private let model : NSManagedObjectModel
    private let coordinator : NSPersistentStoreCoordinator
    private let modelURL : NSURL
    private let dbURL : NSURL
    let context : NSManagedObjectContext
    
    // MARK:  - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL as NSURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        
        
        // create a context and add connect it to the coordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard fm.urls(for: .documentDirectory, in: .userDomainMask).first != nil else{
            print("Unable to reach the documents folder")
            return nil
        }
        
//        self.dbURL = docUrl.URLByAppendingPathComponent("model.sqlite")
        
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
        
        do{
            try addStoreCoordinator(storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject])
            
        }catch{
            print("unable to add store at \(dbURL)")
        }
        
        
        
        
        
    }
    
    // MARK:  - Utils
    func addStoreCoordinator(storeType: String,
                             configuration: String?,
                             storeURL: NSURL,
                             options : [NSObject : AnyObject]?) throws{
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL as URL, options: nil)
        
    }
}


// MARK:  - Removing data
extension CoreDataStack  {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL as URL, ofType:NSSQLiteStoreType , options: nil)
        
        try addStoreCoordinator(storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        
        
    }
}

// MARK:  - Save
extension CoreDataStack {
    
    func saveContext() throws{
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            do{
                try saveContext()
                print("Autosaving")
            }catch{
                print("Error while autosaving")
            }
            
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(dispatch_time_t(DispatchTime.now()), Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds: delayInSeconds)
            })
            
        }
    }
}
