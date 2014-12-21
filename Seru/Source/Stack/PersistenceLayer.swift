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
}

public class PersistenceLayer {
  
  private let coreDataName: String
  public var errorHandler: ErrorHandler

  public var mainMOC: NSManagedObjectContext
  var managedObjectModel: NSManagedObjectModel
  var persistentStoreCoordinator: NSPersistentStoreCoordinator
  
  public init(name: String, type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder, errorHandler: ErrorHandler) {
    coreDataName = name
    self.errorHandler = errorHandler
    
    managedObjectModel = Factory.defaultMOM(coreDataName)
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    mainMOC = Factory.mainMOC(persistentStoreCoordinator)
    
    switch location {
    case let .SharedGroup(group):
      sharedFilePath = FileHelper.sharedFilePath(group)
    default:
      break
    }

    setupCoordinator(persistentStoreCoordinator, name: name, type: type, location: location, errorHandler: errorHandler)
  }
  
  public convenience init(type: StoreType = .SQLite, location: StoreLocationType = .PrivateFolder) {
    self.init(name: AppInfo.productName, type: type, location: location, errorHandler: ErrorHandler())
  }
  
  public convenience init(name: String) {
    self.init(name: name, errorHandler: ErrorHandler())
  }
  public convenience init() {
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


// MARK:- Private

private extension StoreType  {
  var coreDataType: String {
    switch self {
    case .SQLite: return NSSQLiteStoreType
    case .Binary: return NSBinaryStoreType
    case .InMemory: return NSInMemoryStoreType
    }
  }
}

//MARK: - Factory
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
    
    return PersistenceLayer.storeConfigurator(coordinator)(type: .InMemory, params: params(), errorHandler: errorHandler)
    
  }
  
  final class func storeConfigurator(coordinator: NSPersistentStoreCoordinator)(type: StoreType, params: StoreParams?, errorHandler: ErrorHandler) -> NSPersistentStoreCoordinator {
    var error: NSError?
    if coordinator.addPersistentStoreWithType(type.coreDataType, configuration: params?.configuration, URL: params?.URL, options: params?.options, error: &error) == nil {
      errorHandler.handle(error!)
    }
    return coordinator
  }
  

  class Factory {
    
    class func defaultMOM(name: String) -> NSManagedObjectModel {
      if let modelURL = NSBundle.mainBundle().URLForResource(name, withExtension: "momd") {
        if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
          return model
        }
      }
      assertionFailure("model with name: \(name).momd not foun")
    }
    
// MARK:- NSManagedObjectContext
    
    final class func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
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