//
//  RealmMultiTheadTestsTests.swift
//  RealmMultiTheadTestsTests
//
//  Created by Kawajiri Ryoma on 5/16/15.
//  Copyright (c) 2015 strobo inc. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift

class RealmMultiTheadTestsTests: XCTestCase {

  let realmPathForTesting = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("RealmPathForSensorLogExtractorTests")

  override func setUp() {
    super.setUp()
    deleteRealmFilesAtPath(realmPathForTesting)
    Realm.defaultPath = realmPathForTesting
  }

  override func tearDown() {
    deleteRealmFilesAtPath(realmPathForTesting)
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
  }

  func deleteRealmFilesAtPath(path: String) {
    let fileManager = NSFileManager.defaultManager()
    fileManager.removeItemAtPath(path, error: nil)
    let lockPath = path + ".lock"
    fileManager.removeItemAtPath(lockPath, error: nil)
  }
}
