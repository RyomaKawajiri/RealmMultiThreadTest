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
    let condition = NSCondition()
    let loaded = expectationWithDescription("upload")

    // Load and Delete
    let loadQueue = dispatch_queue_create("load", DISPATCH_QUEUE_SERIAL)
    var isFinish = false
    var dogsCount = 0
    dispatch_async(loadQueue) {
      let realm = Realm()
      while true {
        let dogs = realm.objects(Dog)
        if dogs.count == 0 {
          if isFinish {
            break
          } else {
            condition.lock()
            condition.waitUntilDate(NSDate(timeIntervalSinceNow: 1))
            condition.unlock()
            continue
          }
        }

        dogsCount += dogs.count
        realm.write {
          realm.delete(dogs)
        }
      }
      loaded.fulfill()
    }

    // Insert
    let insertQueue = dispatch_queue_create("insert", DISPATCH_QUEUE_SERIAL)
    for i in 1...100 {
      dispatch_async(insertQueue) {
        let dog = Dog()
        dog.name = "dog \(i)"

        let realm = Realm()
        realm.write {
          realm.add(dog)
        }
        condition.lock()
        condition.signal()
        condition.unlock()
      }
    }

    // Wait
    sleep(3)
    isFinish = true
    waitForExpectationsWithTimeout(1) { error in }

    // Assert
    XCTAssertEqual(100, dogsCount, "")

    let dogs = Realm().objects(Dog)
    XCTAssertEqual(0, dogs.count, "")
  }

  func deleteRealmFilesAtPath(path: String) {
    let fileManager = NSFileManager.defaultManager()
    fileManager.removeItemAtPath(path, error: nil)
    let lockPath = path + ".lock"
    fileManager.removeItemAtPath(lockPath, error: nil)
  }
}
