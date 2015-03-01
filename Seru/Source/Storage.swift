//
//  Actions.swift
//  Seru
//
//  Created by Konstantin Koval on 28/02/15.
//  Copyright (c) 2015 Konstantin Koval. All rights reserved.
//

import Foundation
import CoreData

protocol StorageAtions {

  var errorHandler: ErrorHandling {get}
  var mainMOC: NSManagedObjectContext {get}

  func persist(moc: NSManagedObjectContext)
}

public class Storage {
  let stack: CoreDataStack
  let errorHandler: ErrorHandling

  public init (stack: CoreDataStack) {
    self.stack = stack
    errorHandler = ErrorHandler()
  }

  public convenience init() {
    self.init(stack: BaseStack())
  }
  
  public func persist() {
    return persist(stack.mainMOC)
  }


  var mainMOC: NSManagedObjectContext {
    return stack.mainMOC
  }
  
  public func persist(moc: NSManagedObjectContext) {
    saveContext(moc)
  }
  
  public func saveContext(moc: NSManagedObjectContext, completion: (Bool -> Void)? = nil) {
    
    moc.performBlock {
      var error: NSError?
      var result: Bool = true
      
      if moc.hasChanges && !moc.save(&error) {
        self.errorHandler.handle(error!)
        result = false
      }
      main_queue_call_if(completion, result)
    }
  }
  
  public func saveContextsChain(moc: NSManagedObjectContext, completion: (Bool -> Void)? = nil) {
    
    saveContext(moc) { [unowned self] result in
      if result && moc.parentContext != nil {
        self.saveContextsChain(moc.parentContext!, completion: completion)
      } else {
        call_if(completion, result)
      }
    }
  }
  
  public func performBackgroundSave(block: (context: NSManagedObjectContext) -> Void, completion: (Bool -> Void)? ) {
    
    let context = Storage.backgroundContext(parent: stack.mainMOC)
    context.performBlock {
      block(context: context)
      self.saveContextsChain(context, completion: completion)
    }
  }
  
  //MARKL:- Context
  public class func backgroundContext(parent: NSManagedObjectContext? = nil) -> NSManagedObjectContext {
    var context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.name = "Background"
    context.parentContext = parent
    return context
  }
}

//MARK - Helpers
func if_let<T>(a: T?, f: (T) -> Void) {
  if let a = a {
    f(a)
  }
}

func call_if<P>(f: (P -> Void)?, param: P) {
  if let f = f {
    f(param)
  }
}

func main_queue_call_if<P>(f: (P -> Void)?, param: P) {
  if let f = f {
    dispatch_async(dispatch_get_main_queue(), {
      f(param)
    })
  }
}
