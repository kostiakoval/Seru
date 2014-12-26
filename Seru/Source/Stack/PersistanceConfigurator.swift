//
//  PersistanceConfigurator.swift
//  Seru
//
//  Created by Konstantin Koval on 25/12/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData
import Sweet

public enum StoreLocationType {
  case PrivateFolder //Located in Documents directory. Visible only to the app
  case SharedGroup(name: String)
  // Located in shared Group directory and visible to all exntesion that have access to that group
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

typealias StoreParams = (configuration: String?, URL: NSURL?, options: [NSObject : AnyObject]?)
typealias StoreCoordinatorSetup = (NSPersistentStoreCoordinator) -> NSPersistentStoreCoordinator

protocol configurator {
  var modelProvider: () -> NSManagedObjectModel {get}
  var setupStoreCoordinator: StoreCoordinatorSetup  {get}
}

public struct PersistanceConfigurator : configurator {
  let name: String
  let type: StoreType = .SQLite
  let location: StoreLocationType = .PrivateFolder
  let errorHandler = ErrorHandler()
  
  let modelProvider = ModelProcivder.mainBundleModel
  var setupStoreCoordinator: StoreCoordinatorSetup
}

extension PersistanceConfigurator {

  init() {
    self.init(name: AppInfo.productName)
  }
  
  init(name: String) {
    self.init(name: name, type: .SQLite)
  }
  
  init(name: String, type: StoreType) {
    self.name = name
    self.type = type
    let params = PersistanceConfigurator.storeParams(name, type: type, location: location)
    setupStoreCoordinator = StoreCoordinatorProvider.addStoreCoordinator(type, params: params, errorHandler: errorHandler)
  }
  
  
  static func storeParams(name:String, type: StoreType, location: StoreLocationType) ->StoreParams? {
    
    func params() -> StoreParams? {
      switch (type, location) {
      case (.SQLite, .PrivateFolder):
        let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).sqlite"))
        return (nil, url, nil)
      case (_, .SharedGroup(let group)):
        let url = FileHelper.sharedFilePath(group)(file: "\(name).sqlite")
        return (nil, nil, nil)
      case (_, _):
        return nil
      }
    }
    return params()
  }

}

struct ModelProcivder {
  
  static func mainBundleModel() -> NSManagedObjectModel {
    if let m = NSManagedObjectModel.mergedModelFromBundles(nil) {
      return m
    }
    assertionFailure("Cant get model form main bundle")
  }
}


struct StoreCoordinatorProvider {

  static func addStoreCoordinator(type: StoreType, params: StoreParams?, errorHandler: ErrorHandler)(coordinator: NSPersistentStoreCoordinator) -> NSPersistentStoreCoordinator {
    
    var error: NSError?
    if coordinator.addPersistentStoreWithType(type.coreDataType, configuration: params?.configuration, URL: params?.URL, options: params?.options, error: &error) == nil {
      errorHandler.handle(error!)
    }
    return coordinator
  }
}

