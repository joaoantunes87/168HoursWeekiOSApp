//
//  Task.swift
//  168HoursWeek
//
//  Created by João Antunes on 27/11/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var startTimestamp: NSTimeInterval
    @NSManaged var endTimestamp: NSTimeInterval
    @NSManaged var taskType: TaskType

}
