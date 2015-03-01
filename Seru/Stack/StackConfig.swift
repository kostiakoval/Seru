//
//  StackConfig.swift
//  Seru
//
//  Created by Konstantin Koval on 01/03/15.
//  Copyright (c) 2015 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData

//MARK: - Model

func modelInBundle(bundle: NSBundle) -> NSManagedObjectModel {
  return modelForBundles([bundle])
}

private func modelForBundles(bundles: [NSBundle]?) -> NSManagedObjectModel {
  if let m = NSManagedObjectModel.mergedModelFromBundles(bundles) {
    return m
  }
  assertionFailure("Cant get model for bundles")
}


//MARK: Store Coordinator

public enum StoreType {
  case SQLite
  case Binary
  case InMemory
  
  public var coreDataType: String {
    switch self {
    case .SQLite: return NSSQLiteStoreType
    case .Binary: return NSBinaryStoreType
    case .InMemory: return NSInMemoryStoreType
    }
  }
}

public enum StoreLocationType : Equatable {
  //Located in Documents directory. Visible only to the app
  case PrivateFolder
  // Located in shared Group directory and visible to all exntesion that have access to that group
  case SharedGroup(String)
}

public  func == (lhs:StoreLocationType, rhs:StoreLocationType) -> Bool {
  switch (lhs, rhs) {
  case (.PrivateFolder, .PrivateFolder): return true
  case (.SharedGroup, .SharedGroup): return true
  case (_, _): return false
  }
}


//MARK: - Not used

func mainBundleModel() -> NSManagedObjectModel {
  return modelForBundles(nil)
}

func allFrameworksBundlesModel() -> NSManagedObjectModel {
  return modelForBundles(NSBundle.allFrameworks() as? [NSBundle])
}

func allAppBundlesModel() -> NSManagedObjectModel {
  return modelForBundles(NSBundle.allBundles() as? [NSBundle])
}

func modelWithName(name: String) -> NSManagedObjectModel {
  if let modelURL = NSBundle.mainBundle().URLForResource("name", withExtension: "momd"),
    let model = NSManagedObjectModel(contentsOfURL:modelURL) {
      return model
  }
  assertionFailure("Model with name is not available")
}
