//
//  TaskType.swift
//  168HoursWeek
//
//  Created by João Antunes on 27/11/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import CoreData

class TaskType: NSManagedObject {

    @NSManaged var sid: String
    @NSManaged var colorHex: String

}
