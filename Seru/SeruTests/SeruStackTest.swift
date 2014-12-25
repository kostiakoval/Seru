//
//  SeruStackTest.swift
//  Seru
//
//  Created by Konstantin Koval on 25/12/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData
import XCTest

class SeruStackTest: XCTestCase {
  var stack: PersistenceLayer!
 
  override func setUp() {
    super.setUp()
    stack = PersistenceLayer(name:"Seru")
  }
  
  override func tearDown() {
    stack = nil
    super.tearDown()
  }
  
  func testSetupTrack() {
    XCTAssertNotNil(stack)
    XCTAssertNotNil(stack.errorHandler)
    XCTAssertNotNil(stack.mainMOC)
    XCTAssertNotNil(stack.managedObjectModel)
    XCTAssertNotNil(stack.persistentStoreCoordinator)
    XCTAssertTrue(stack.sharedFilePath == nil)
  }
  
  func testDefaulModel() {
    let entities = stack.managedObjectModel.entities as [NSEntityDescription]
    
    //XCTAssertEqual(entities.count, 1)
    // XCTAssertEqual(entities.first!.name!, "Entity")
  }
  
  func testContext() {
    let moc = stack.mainMOC
    
    XCTAssertNotNil(moc.persistentStoreCoordinator)
    XCTAssertEqual(moc.persistentStoreCoordinator!, stack.persistentStoreCoordinator)
    XCTAssertNil(moc.parentContext)
    XCTAssertEqual(moc.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    XCTAssertNil(moc.undoManager)
  }
  
  func testCoordinator() {
    
    let coordinator = stack.persistentStoreCoordinator
    XCTAssertNotNil(coordinator.managedObjectModel)
    XCTAssertNotNil(coordinator.persistentStores)
    
    let stores = coordinator.persistentStores as [NSPersistentStore]
    XCTAssertEqual(stores.count, 1)
    
    let store: NSPersistentStore = stores.first!
    XCTAssertNil(store.options)
    XCTAssertTrue(store.URL!.absoluteString!.hasSuffix("Documents/Seru.sqlite"))
    XCTAssertTrue(store.URL!.absoluteString!.hasPrefix("file:///"))
    XCTAssertEqual(store.type, StoreType.SQLite.coreDataType)
    XCTAssertFalse(store.readOnly)
    XCTAssertEqual(store.persistentStoreCoordinator!, coordinator)
  }
  
}
