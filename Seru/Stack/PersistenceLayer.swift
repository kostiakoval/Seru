//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Konstantin Koval on 20/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData

public class PersistenceStack {
  
  public var errorHandler: ErrorHandling
  
  public var mainMOC: NSManagedObjectContext
  public var model: NSManagedObjectModel
  public var persistentStoreCoordinator: NSPersistentStoreCoordinator
  
  public init(configurator: PersistanceConfigurator, factory: FactoryType = Factory()) {
    
    self.errorHandler = configurator.errorHandler
    
    model = configurator.modelProvider()
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    mainMOC = factory.mainMOC(persistentStoreCoordinator)
    configurator.setupStoreCoordinator(persistentStoreCoordinator)
  }
}

//MARK:- Initializers
public extension PersistenceStack {
  
  public convenience init(type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder, modelLocation: ModelLocation = .MainBundle, errorHandler: ErrorHandler = ErrorHandler()) {
    
    self.init(configurator: PersistanceConfigurator(type: type, location: location, modelLocation: modelLocation, errorHandler: errorHandler))
  }
  
  public convenience init(name: String, type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder, modelLocation: ModelLocation = .MainBundle, errorHandler: ErrorHandler = ErrorHandler()) {
    self.init(configurator: PersistanceConfigurator(name: name, type: type, location: location, modelLocation: modelLocation, errorHandler: errorHandler))
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




