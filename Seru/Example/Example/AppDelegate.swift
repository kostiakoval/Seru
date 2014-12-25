//
//  AppDelegate.swift
//  Example
//
//  Created by Konstantin Koval on 27/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import UIKit
import Seru

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  var persistenceController =  PersistenceLayer()
//  var persistenceController1 =  PersistenceLayer(name: "Example")
//  var persistenceController2 =  PersistenceLayer(name: "Example", errorHandler:
//    
//    ErrorHandler(errorHandler: { error in
//    // custom error handling for all issue related with CoreData
//  })
//)

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    // Override point for customization after application launch.
//    persistenceController.persist()
//    persistenceController1.persist()
//    persistenceController2.persist()
    (window?.rootViewController as ViewController).stack = persistenceController
    return true
  }

  func applicationWillResignActive(application: UIApplication!) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication!) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication!) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication!) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication!) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    persistenceController.persist()
  }
}

