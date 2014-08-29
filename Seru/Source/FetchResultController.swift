//
//  FetchResultController.swift
//  Seru
//
//  Created by Konstantin Koval on 29/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData

public class FetchResultController {

  public class func make(moc: NSManagedObjectContext, entityName: String) -> NSFetchedResultsController {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
    let sortDescriptors = [sortDescriptor]
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Master")
//    aFetchedResultsController.delegate = self
//    _fetchedResultsController = aFetchedResultsController
    
//    var error: NSError? = nil
//    if !_fetchedResultsController!.performFetch(&error) {
//      // Replace this implementation with code to handle the error appropriately.
//      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//      //println("Unresolved error \(error), \(error.userInfo)")
//      abort()
//    }
    
    return aFetchedResultsController

  }
  
  public class func fetch(fetchRC: NSFetchedResultsController, errorHandler: ErrorHandler) {
    var error: NSError? = nil
    if fetchRC.performFetch(&error) {
      errorHandler.handle(error!)
    }
  }
}