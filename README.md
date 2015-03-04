Seru (セル) 
=====
Seru is Cell in Japanees

[![Build Status](https://travis-ci.org/kostiakoval/Seru.svg?branch=develop)](https://travis-ci.org/kostiakoval/Seru) 
[![CocoaPods](https://img.shields.io/cocoapods/v/Seru.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

### CocoaPods
Seru is available through [CocoaPods](http://cocoapods.org). To install :

 - Install latest version of cocoapods `[sudo] gem install cocoapods --pre`
 - Add the following line to your Podfile:
 
```
use_frameworks!
pod 'Seru'
```

### Carthage
Installation is available using the dependency manager Carthage.

 - Install Carthage `brew install carthage`
 - Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) file

```
github "kostiakoval/Seru"
```
-  Run `carthage update`
-  Add Seru.framework (from Carthage/buid directory) to your project.

### Submodules

```
mkdir Vendor # you can keep your submodules in their own directory
git submodule add git@github.com:kostiakoval/Seru.git Vendor/Seru
git submodule update --init --recursive
``

### TODO
- [ ] CoreData Stack with background saving context
- [ ] Background data importer stack
- [ ] Error handler with UIAlertView
- [ ] Creating child contexts
- [ ] Insert new Object
- [ ] Delete object


## Author

Kostiantyn Koval  
[@KostiaKoval](https://twitter.com/KostiaKoval)

## License

Seru is available under the MIT license. See the LICENSE file for more info.


