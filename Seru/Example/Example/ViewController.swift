//
//  ViewController.swift
//  Example
//
//  Created by Konstantin Koval on 27/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import UIKit
import Seru
import CoreData

class ViewController: UIViewController {
  
  var stack: PersistenceLayer!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var object : NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Entity", inManagedObjectContext: stack.mainMOC) as NSManagedObject
    object.setValue("MyName", forKey: "name")
    stack.persist()
    fetch()
    // Do any additional setup after loading the view, typically from a nib.
  }

  func fetch() {
    var fetch = NSFetchRequest(entityName: "Entity")
    var error: NSError?
    let res = stack.mainMOC.executeFetchRequest(fetch, error: &error)
    println("count : \(res?.count)  \(res) \(error)")
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

