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


public enum StoreLocationType {
  case PrivateFolder //Located in Documents directory. Visible only to the app
  case SharedGroup(String) // Located in shared Group directory and visible to all exntesion that have access to that group
}

public enum StoreType {
  case SQLite
  case Binary
  case InMemory
  
  var coreDataType: String {
    switch self {
    case .SQLite: return NSSQLiteStoreType
    case .Binary: return NSBinaryStoreType
    case .InMemory: return NSInMemoryStoreType
    }
  }
}

public class PersistenceLayer {
  
  public var errorHandler: ErrorHandler

  public var mainMOC: NSManagedObjectContext
  var managedObjectModel: NSManagedObjectModel
  var persistentStoreCoordinator: NSPersistentStoreCoordinator
  
  public init(name: String, type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder, errorHandler: ErrorHandler, factory: FactoryType = Factory()) {

    self.errorHandler = errorHandler
    
    managedObjectModel = factory.defaultMOM(name)
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    mainMOC = factory.mainMOC(persistentStoreCoordinator)
    
    switch location {
    case let .SharedGroup(group):
      sharedFilePath = FileHelper.sharedFilePath(group)
    default:
      break
    }

    setupCoordinator(persistentStoreCoordinator, name: name, type: type, location: location, errorHandler: errorHandler)
  }
  
  public convenience init(name: String, type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder) {
    self.init(name: name, type: type, location: location, errorHandler: ErrorHandler(), factory: Factory())
  }
  
  public convenience init(type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder) {
    self.init(name: AppInfo.productName)
  }
  
//  MARK: - Private
  let sharedFilePath: ((file: String) -> NSURL)?
  
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

  public func persist(moc: NSManagedObjectContext) -> Bool {
    return saveContext(moc)
  }
  
  public func persist() -> Bool {
    return persist(self.mainMOC)
  }
  
  public func saveContext(moc: NSManagedObjectContext) -> Bool {
    var error: NSError?
    if moc.hasChanges && !moc.save(&error) {
      self.errorHandler.handle(error!)
      return false
    }
    return true
  }
}

//MARK: - Factory

public protocol FactoryType {
  func defaultMOM(name: String) -> NSManagedObjectModel
  func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext
}
  
class Factory: FactoryType {
  
  func defaultMOM(name: String) -> NSManagedObjectModel {
    if let model = NSManagedObjectModel.mergedModelFromBundles(nil) {
      return model
    }
    assertionFailure("model with name: \(name).momd not foun")
  }
  
  // MARK:- NSManagedObjectContext
  
  final func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = storeCoordinator
    return managedObjectContext
  }
  
}


private extension PersistenceLayer {

  typealias StoreParams = (configuration: String?, URL: NSURL?, options: [NSObject : AnyObject]?)

  
  func setupCoordinator(coordinator: NSPersistentStoreCoordinator, name:String, type: StoreType, location: StoreLocationType, errorHandler: ErrorHandler) -> NSPersistentStoreCoordinator {

    func params() -> StoreParams? {
      switch (type, location) {
        case (.SQLite, .PrivateFolder):
          let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).sqlite"))
          return (nil, url, nil)
      case (_, .SharedGroup):
        let url = sharedFilePath!(file: "\(name).sqlite")
        return (nil, url, nil)
      case (_, _):
        return nil
      }
    }
    
    return PersistenceLayer.storeConfigurator(coordinator)(type: type, params: params(), errorHandler: errorHandler)
    
  }
  
  final class func storeConfigurator(coordinator: NSPersistentStoreCoordinator)(type: StoreType, params: StoreParams?, errorHandler: ErrorHandler) -> NSPersistentStoreCoordinator {
    var error: NSError?
    if coordinator.addPersistentStoreWithType(type.coreDataType, configuration: params?.configuration, URL: params?.URL, options: params?.options, error: &error) == nil {
      errorHandler.handle(error!)
    }
    return coordinator
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