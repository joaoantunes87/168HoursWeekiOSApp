//
//  Log.swift
//  168HoursWeek
//
//  Created by João Antunes on 01/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import CoreData

@objc(Log)
class Log: NSManagedObject {

    @NSManaged var startTimestamp: NSTimeInterval
    @NSManaged var endTimestamp: NSTimeInterval
    @NSManaged var type: TaskType

}
