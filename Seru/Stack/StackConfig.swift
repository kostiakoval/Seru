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

func mainBundleModel() -> NSManagedObjectModel {
  return modelForBundles(nil)
}

func allFrameworksBundlesModel() -> NSManagedObjectModel {
  return modelForBundles(NSBundle.allFrameworks() as? [NSBundle])
}

func allAppBundlesModel() -> NSManagedObjectModel {
  return modelForBundles(NSBundle.allBundles() as? [NSBundle])
}

private func modelForBundles(bundles: [NSBundle]?) -> NSManagedObjectModel {
  if let m = NSManagedObjectModel.mergedModelFromBundles(bundles) {
    return m
  }
  assertionFailure("Cant get model for bundles")
}
