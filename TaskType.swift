//
//  TaskType.swift
//  168HoursWeek
//
//  Created by João Antunes on 01/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import CoreData

@objc(TaskType)
class TaskType: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var colorHex: String
    @NSManaged var sid: String
    
    func isRunning() -> Bool {
        var taskTypeRunning: TaskType! = TaskTypeManager.sharedInstance.currentTaskRunning()
        return taskTypeRunning != nil && taskTypeRunning.sid == self.sid
    }
    
    func toogleAction() -> Void {
        if self.isRunning() {
            self.stop()
        } else {
            self.play()
        }
    }
    
    func play() -> Void {
        
    }
    
    func stop() -> Void {
        
    }

}
