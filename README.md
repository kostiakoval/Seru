Seru (セル) 
=====
Seru is Cell in Japanees

[![Build Status](https://travis-ci.org/kostiakoval/Seru.svg?branch=develop)](https://travis-ci.org/kostiakoval/Seru) 
[![Issue Stats](http://issuestats.com/github/kostiakoval/Seru/badge/pr)](http://issuestats.com/github/kostiakoval/Seru)

##Core Data Stack in Swift.
Clean and Beautiful Core Data stack in **1** line of code `PersistenceLayer()`  
Seru provides a simple Core Data Stack and actions API
 
## Usages

#### Setup CoreData

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {            
  lazy var seruStack = Seru()
  ...
}
```

#### Actions 

Save
```swift
var seruStack: Seru
seruStack.persist()
```

Perform background save.
All the changes will be saved to the context
```swift
seruStack.performBackgroundSave({ context in
  let person = Person.(managedObjectContext: context)
}
```

Perform background work
```swift
seruStack.performInBackgroundContext { context in
  let fetch = NSFetchRequest(entityName: "Person")
  var error: NSError?
  let result = context.executeFetchRequest(fetch, error: &error)
}
```



##Installation

### Carthage
Installation is available using the dependency manager Carthage.

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "kostiakoval/Seru"
```
Then do `carthage update`. After that, add the framework to your project.

### Submodules

Run `git submodule update`

### TODO
- [ ] CoreData Stack with background saving context
- [ ] Background data importer stack
- [ ] Error handler with UIAlertView
- [ ] Creating child contexts
- [ ] Insert new Object
- [ ] Delete object


# Author

Kostiantyn Koval  
[@KostiaKoval](https://twitter.com/KostiaKoval)

