//
//  AppDelegate.swift
//  SeruDemo
//
//  Created by Konstantin Koval on 04/03/15.
//  Copyright (c) 2015 Kostiantyn Koval. All rights reserved.
//

import UIKit
import Seru

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var seruStack = Seru()
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let viewController = (window?.rootViewController as UINavigationController).topViewController as MasterViewController
    viewController.seruStack = seruStack
    
    return true
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    seruStack.persist()
  }
  
  func applicationWillTerminate(application: UIApplication) {
    seruStack.persist()
  }
}

