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

public enum StoreLocationType : Equatable {
  case PrivateFolder //Located in Documents directory. Visible only to the app
  case SharedGroup(String)
  // Located in shared Group directory and visible to all exntesion that have access to that group
}

public  func == (lhs:StoreLocationType, rhs:StoreLocationType) -> Bool {
  switch (lhs, rhs) {
    case (.PrivateFolder, .PrivateFolder): return true
    case (.SharedGroup, .SharedGroup): return true
    case (_, _): return false
  }
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
typealias StoreCoordinatorSetup = (NSPersistentStoreCoordinator) -> NSPersistentStore?
typealias ModelProviderType = () -> NSManagedObjectModel

protocol configurator {
  var modelProvider: ModelProviderType {get}
  var setupStoreCoordinator: StoreCoordinatorSetup  {get}
}

public struct PersistanceConfigurator : configurator {
  let name: String
  let type: StoreType
  let location: StoreLocationType
  let errorHandler: ErrorHandler
  
  let modelProvider: ModelProviderType
  let setupStoreCoordinator: StoreCoordinatorSetup
}

extension PersistanceConfigurator {
  
  init(name: String = AppInfo.productName, type: StoreType = .SQLite,
    location: StoreLocationType = .PrivateFolder, errorHandler: ErrorHandler = ErrorHandler(),
    modelProvider: ModelProviderType = ModelProcivder.mainBundleModel) {
    self.name = name
    self.type = type
    self.location = location
    self.errorHandler = errorHandler
    self.modelProvider = modelProvider
    
    let params = PersistanceConfigurator.storeParams(name, type: type, location: location)
    self.setupStoreCoordinator = StoreCoordinatorProvider.addStoreCoordinator(type, params: params, errorHandler: errorHandler)
  }
  
  
  static func storeParams(name:String, type: StoreType, location: StoreLocationType) ->StoreParams? {
    
    func params() -> StoreParams? {
      switch (type, location) {
      case (.Binary, .PrivateFolder):
        let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).data"))
        return (nil, url, nil)
      case (.SQLite, .PrivateFolder):
        let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).sqlite"))
        return (nil, url, nil)

      case (_, .SharedGroup(let group)):
        let url = FileHelper.sharedFilePath(group)(file: "\(name).sqlite")
        return (nil, url, nil)
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

  static func addStoreCoordinator(type: StoreType, params: StoreParams?, errorHandler: ErrorHandler)(coordinator: NSPersistentStoreCoordinator) -> NSPersistentStore? {
  
    var error: NSError?
    
    if let store = coordinator.addPersistentStoreWithType(type.coreDataType, configuration: params?.configuration, URL: params?.URL, options: params?.options, error: &error) {
      return store
    } else {
      errorHandler.handle(error!)
      return nil
    }
  }
}

