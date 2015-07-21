//
//  MyPassword.swift
//  MyPassword
//
//  Created by WuYikai on 15/7/16.
//  Copyright (c) 2015年 secoo. All rights reserved.
//

import Foundation
import CoreData

class MyPassword: NSManagedObject {

    @NSManaged var p_detail: String
    @NSManaged var p_description: String
    @NSManaged var p_title: String

}
