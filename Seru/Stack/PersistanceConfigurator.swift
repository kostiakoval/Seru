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




public enum ModelLocation {
  case MainBundle
  case AllMainBundles
  case FrameworksBundle
  case ModelInBundle(NSBundle)
  case ModelAtUrl(String)
  case Custom(ModelProviderType)
  
  var modelProvider: ModelProviderType {
    switch self {
      case .MainBundle: return mainBundleModel
      case .AllMainBundles: return allAppBundlesModel
      case .FrameworksBundle: return allFrameworksBundlesModel
      case .ModelInBundle(let bundle): return mainBundleModel
      case .ModelAtUrl(let url): return mainBundleModel
      case .Custom(let provider): return provider
    }
  }
}

public typealias StoreParams = (configuration: String?, URL: NSURL?, options: [NSObject : AnyObject]?)
public typealias StoreCoordinatorSetup = (NSPersistentStoreCoordinator) -> NSPersistentStore?
public typealias ModelProviderType = () -> NSManagedObjectModel

protocol Configurator {
  var modelProvider: ModelProviderType {get}
  var setupStoreCoordinator: StoreCoordinatorSetup  {get}
}

public struct PersistanceConfigurator : Configurator {
  
  public let type: StoreType
  public let location: StoreLocationType
  public let errorHandler: ErrorHandler
  
  public let modelProvider: ModelProviderType
  public let setupStoreCoordinator: StoreCoordinatorSetup
}

public extension PersistanceConfigurator {
  
  init(name: String = AppInfo.productName, type: StoreType = .SQLite,
    location: StoreLocationType = .PrivateFolder, errorHandler: ErrorHandler = ErrorHandler(),
    modelLocation: ModelLocation = ModelLocation.MainBundle) {

    self.type = type
    self.location = location
    self.errorHandler = errorHandler
    self.modelProvider = modelLocation.modelProvider
    
    let params = PersistanceConfigurator.storeParams(name, type: type, location: location)
    self.setupStoreCoordinator = StoreCoordinatorProvider.addStoreCoordinator(type, params: params, errorHandler: errorHandler)
  }
  
  
  static func storeParams(name:String, type: StoreType, location: StoreLocationType) ->StoreParams? {
    
    func params() -> StoreParams? {
      let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption:true]

      switch (type, location) {
        
      case (.Binary, .PrivateFolder):
        let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).data"))
        return (nil, url, options)
      
      case (.SQLite, .PrivateFolder):
        let url = NSURL.fileURLWithPath(FileHelper.filePath("\(name).sqlite"))
        return (nil, url, options)

      case (_, .SharedGroup(let group)):
        let url = FileHelper.sharedFilePath(group)(file: "\(name).sqlite")
        return (nil, url, options)
      
      case (_, _):
        return nil
      }
    }
    return params()
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

