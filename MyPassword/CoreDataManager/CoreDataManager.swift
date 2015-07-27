//
//  CoreDataManager.swift
//  MyPassword
//
//  Created by WuYikai on 15/7/14.
//  Copyright (c) 2015年 secoo. All rights reserved.
//

import UIKit
import CoreData

let kCoreDataDidSaveNotification = "kCoreDataDidSaveNotification"

class CoreDataManager: NSObject {
  
  /// 模型器
  final var _model: NSManagedObjectModel?
  /// 链接器
  final var _coordinator: NSPersistentStoreCoordinator?
  /// 管理器
  final var _context: NSManagedObjectContext?
  /// 沙盒目录
  final var applicationDocumentURL: NSURL {
    get {
      let documentPathList = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
      let sqlitePath = documentPathList.last?.stringByAppendingPathComponent("MyPassword.sqlite")
      println(sqlitePath)
      return NSURL(fileURLWithPath: sqlitePath!)!
    }
  }
  
  final func model() -> NSManagedObjectModel {
    if _model == nil {
      _model = NSManagedObjectModel.mergedModelFromBundles(nil)
    }
    return _model!
  }
  
  final func coordinator() -> NSPersistentStoreCoordinator {
    if _coordinator == nil {
      _coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model())
      // 设置版本升级
      let options = [NSMigratePersistentStoresAutomaticallyOption : NSNumber(bool: true)]
      var error: NSError?
      let persistentStore = _coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.applicationDocumentURL, options: options, error: &error)
      if persistentStore == nil {
        let dic = [NSLocalizedDescriptionKey:"failed to return NSPersistentStoreCoordinator", NSLocalizedFailureReasonErrorKey:"There was an error NSPersistentStoreCoordinator", NSUnderlyingErrorKey:error!]
        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dic)
        println("NSPersistentStoreCoordinator error: \(error)\n\(error?.userInfo)")
        abort()
      }
    }
    return _coordinator!
  }
  
  final func context() -> NSManagedObjectContext {
    if _context == nil {
      _context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
      _context?.persistentStoreCoordinator = self.coordinator()
    }
    return _context!
  }
  
  override init() {
    super.init()
    self.context()
    // 通知中心注册单例对象监听管理器是否发生变化
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "save", name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
  }
  
  /// 保存
  final func save() {
    if self.context().hasChanges {
      var error: NSError?
      if !(self.context().save(&error)) {
        println("coreData save error: \(error?.userInfo)")
      }
      NSNotificationCenter.defaultCenter().postNotificationName(kCoreDataDidSaveNotification, object: nil)
    }
  }
  
/*******************************************************************************************************/
  
  // MARK: - Publick Methods
  /// 单例
  static let defaultManager: CoreDataManager = {
    return CoreDataManager()
  }()

  // 创建实体对象
  func creatPassword() -> MyPassword {
    let entityDescription = NSEntityDescription.entityForName("MyPassword", inManagedObjectContext: self.context())
    let password = MyPassword(entity: entityDescription!, insertIntoManagedObjectContext: self.context())
    return password
  }
  
  // 删除实体对象
  func remove(passwd: MyPassword) {
    self.context().deleteObject(passwd)
  }
  
  // 删除所有实体对象
  func removeAll() {
    let passwordList = self.passwordList()
    for password in passwordList {
      self.remove(password as! MyPassword)
    }
  }
  
  // 读取实体对象列表
  func passwordList() -> NSArray {
    let request = NSFetchRequest(entityName: "MyPassword")
    let list = self.context().executeFetchRequest(request, error: nil)
    return list!
  }
}
