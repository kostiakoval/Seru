//
//  Stack.swift
//  Seru
//
//  Created by Konstantin Koval on 28/02/15.
//  Copyright (c) 2015 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData
import Sweet

protocol Stack {
  
  var errorHandler: ErrorHandling {get}
  var mainMOC: NSManagedObjectContext {get}
  var model: NSManagedObjectModel {get}
  var coordinator: NSPersistentStoreCoordinator {get}
}

public class BaseStack: Stack {
  
  var errorHandler: ErrorHandling
  var mainMOC: NSManagedObjectContext
  public var model: NSManagedObjectModel
  var coordinator: NSPersistentStoreCoordinator
  
  public init(name:String = AppInfo.productName, bundle: NSBundle = NSBundle.mainBundle(), type: StoreType = .SQLite, location: StoreLocation = .PrivateFolder) {
      
    errorHandler = ErrorHandler()
    model = modelWithName(name, inBundle: bundle)
    coordinator =  NSPersistentStoreCoordinator(managedObjectModel: model)
    
    //setupCoordinator

    let url = storeUrl(name, type: type, location: location)
    BaseStack.setupStore(coordinator, type: type, configuration: nil, URL: url)

    mainMOC = BaseStack.mainMOC(coordinator)
  }
  
//MARK: - Internal 
  
  static func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    moc.persistentStoreCoordinator = storeCoordinator
    moc.name = "main"
    return moc
  }
  
  static func setupStore(coordinator: NSPersistentStoreCoordinator, type:StoreType, configuration: String?, URL: NSURL?) -> NSError? {
    
    let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption:true]
    var error: NSError?
    coordinator.addPersistentStoreWithType(type.coreDataType, configuration: configuration, URL: URL, options: options, error: &error)
    return error
  }
}

public class SimpleStack: BaseStack {
    
  
}