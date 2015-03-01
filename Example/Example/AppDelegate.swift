//
//  AppDelegate.swift
//  Example
//
//  Created by Konstantin Koval on 27/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  var storage = Storage()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    
    let viewController = (window?.rootViewController as! UINavigationController).topViewController as! MasterViewController
    viewController.stack = storage
    return true
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    storage.persist()
    
  }
  func applicationWillTerminate(application: UIApplication) {
    storage.persist()
  }
}

