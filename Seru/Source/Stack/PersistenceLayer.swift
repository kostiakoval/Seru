//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Konstantin Koval on 20/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData
import Sweet


public class PersistenceLayer {
  
  public var errorHandler: ErrorHandler
  
  public var mainMOC: NSManagedObjectContext
  var managedObjectModel: NSManagedObjectModel
  var persistentStoreCoordinator: NSPersistentStoreCoordinator
  
  public init(configurator: PersistanceConfigurator, factory: FactoryType = Factory()) {
    
    self.errorHandler = configurator.errorHandler
    
    managedObjectModel = configurator.modelProvider()
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    mainMOC = factory.mainMOC(persistentStoreCoordinator)
    configurator.setupStoreCoordinator(persistentStoreCoordinator)
  }
}

//MARK:- Initializers
extension PersistenceLayer {
  public convenience init() {
    self.init(configurator: PersistanceConfigurator())
  }
  
  public convenience init(name: String, type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder, errorHandler: ErrorHandler = ErrorHandler()) {
    self.init(configurator: PersistanceConfigurator(name: name, type: type, location: location, errorHandler: errorHandler))
  }
}


// MARK: - Actions
extension PersistenceLayer {
  
  public func persist(moc: NSManagedObjectContext) -> Bool {
    return saveContext(moc)
  }
  
  public func persist() -> Bool {
    return persist(self.mainMOC)
  }
  
  public func saveContext(moc: NSManagedObjectContext) -> Bool {
    var result: Bool = true
    var error: NSError?
    moc.performBlock {
      if moc.hasChanges && !moc.save(&error) {
        result = false
        self.errorHandler.handle(error!)
      }
    }
    return result
  }
  
  public func saveContextsChain(moc: NSManagedObjectContext) -> Bool {
    saveContext(moc)
    var result: Bool = true
    var error: NSError?
    moc.performBlock { [unowned self] in
      if moc.hasChanges && !moc.save(&error) {
        result = false
        self.errorHandler.handle(error!)
      } else {
        if let parentMOC = moc.parentContext {
          self.saveContextsChain(parentMOC)
        }
      }
    }
    return result
  }

  
  public func performBackgroundSave(block :(context: NSManagedObjectContext) -> Void ) {
   
    let context = PersistenceLayer.backgroundContext(parent: mainMOC)
    context.performBlock {
     block(context: context)
      self.saveContextsChain(context)
    }
  }
  
  //MARKL:- Context
  public class func backgroundContext(parent: NSManagedObjectContext? = nil) -> NSManagedObjectContext {
    var context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.name = "background"
    context.parentContext = parent
    return context
  }
}



//MARK: - Factory

public protocol FactoryType {
  func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext
}

class Factory: FactoryType {
  
  final func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    moc.persistentStoreCoordinator = storeCoordinator
    moc.name = "main"
    return moc
  }
}
