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
  
  private let coreDataName: String
  private var errorHandler: ErrorHandler

  lazy var managedObjectModel: NSManagedObjectModel = Factory.defaultMOM(self.coreDataName)
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = Factory.storeCoordinator(self.coreDataName, mom: self.managedObjectModel, errorHandler: self.errorHandler)

  public lazy var mainMOC: NSManagedObjectContext = Factory.mainMOC(self.persistentStoreCoordinator)
  
  public init(name: String, errorHandler: ErrorHandler) {
    coreDataName = name
    self.errorHandler = errorHandler
  }

  public convenience init(name : String) {
    self.init(name : name, errorHandler: ErrorHandler())
  }
  public convenience init() {
    self.init(name : AppInfo.productName)
  }
}

//MARK: - Error Handler
public class ErrorHandler {
  public typealias errorHandlerType = (NSError)->()
  private var handler: errorHandlerType

  public init(errorHandler: errorHandlerType) {
    handler = errorHandler
  }

  public convenience init() {
    self.init(errorHandler: Factory.defaultErrorHandler())
  }

  public func handle(error: NSError) {
    handler(error)
  }
}

// MARK: - Actions
extension PersistenceLayer {

  public func persist() {
    saveContext(self.mainMOC)
  }
  
  public func saveContext(moc: NSManagedObjectContext) {
    var error: NSError?
    if moc.hasChanges && !moc.save(&error) {
      self.errorHandler.handle(error!)
    }
  }

}

//MARK: - Factory
extension PersistenceLayer {

class Factory {

  class func defaultMOM(name: String) -> NSManagedObjectModel {
    let modelURL = NSBundle.mainBundle().URLForResource(name, withExtension: "momd")
    return NSManagedObjectModel(contentsOfURL: modelURL)
  }

  class func storeCoordinator(name:String, mom: NSManagedObjectModel, errorHandler: ErrorHandler) -> NSPersistentStoreCoordinator {

    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
    var error: NSError?
    if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: FileHelper.filePathURL("\(name).sqlite"), options: nil, error: &error) == nil {
      errorHandler.handle(error!)
    }
    return coordinator
  }

  class func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = storeCoordinator
    return managedObjectContext
  }
}
}

extension ErrorHandler {

class Factory {

  class func defaultErrorHandler () -> ErrorHandler.errorHandlerType {
    return { error in
      NSLog("Unresolved Core Data Error \(error), \(error.userInfo)")
      abort()
    }
  }
}

}