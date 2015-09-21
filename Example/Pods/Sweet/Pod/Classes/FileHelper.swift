//
//  FileHelper.swift
//  MyMovies
//
//  Created by Konstantin Koval on 25/08/14.
//  Copyright (c) 2014 Konstantin Koval. All rights reserved.
//

import Foundation

public class FileHelper {

  public static var documentDirectory: String {
    return directoryPath(.DocumentDirectory)
  }

  public static func filePath(file :String, directory: NSSearchPathDirectory = .DocumentDirectory) -> String {
    let st: NSString = directoryPath(directory)
    return st.stringByAppendingPathComponent(file)
  }

  public class func sharedApplicationGroupContainer(groupName: String) -> NSURL {
    if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupName) {
      return containerURL
    }
    fatalError("The shared application group container is unavailable. Check your entitlements and provisioning profiles for this target")
  }

  public class func sharedFilePath(groupName: String)(file :String) -> NSURL {
    return sharedApplicationGroupContainer(groupName).URLByAppendingPathComponent(file)
  }


//  MARK:- Private
  private static func directoryPath(dir: NSSearchPathDirectory) -> String {
    return NSSearchPathForDirectoriesInDomains(dir, .UserDomainMask, true).first!
  }
}
