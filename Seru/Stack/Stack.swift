//
//  Stack.swift
//  Seru
//
//  Created by Konstantin Koval on 28/02/15.
//  Copyright (c) 2015 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData

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
  
  /*init(moc: NSManagedObjectContext, model: NSManagedObjectModel, coordinator: NSPersistentStoreCoordinator, errorHandler: ErrorHandling) {
    self.mainMOC = moc
    self.model = model
    self.coordinator = coordinator
    self.errorHandler = errorHandler
  }*/
  
  public init(bundle: NSBundle) {
    errorHandler = ErrorHandler()
    model = modelInBundle(bundle)
    
    coordinator =  NSPersistentStoreCoordinator(managedObjectModel: model)
    //setupCoordinator
    mainMOC = BaseStack.mainMOC(coordinator);

  }
  
  public convenience init() {
    self.init(bundle: NSBundle.mainBundle())
  }

  
//MARK: - Internal 
  
  static func mainMOC (storeCoordinator:  NSPersistentStoreCoordinator) -> NSManagedObjectContext {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    moc.persistentStoreCoordinator = storeCoordinator
    moc.name = "main"
    return moc
  }

}

public class SimpleStack: BaseStack {
    
  
}