//
//  TaskTypeManager.swift
//  168HoursWeek
//
//  Created by João Antunes on 04/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation

//
//  ColorWheel.swift
//  168HoursWeek
//
//  Created by João Antunes on 03/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import CoreData

class TaskTypeManager {
    
    var colors: Array<String> = [
        "#ff001e",
        "#f13dff",
        "#309c58",
        "#39dbff",
        "#2a37ff",
        "#4b4f49",
        "#f7bb0f",
        "#f4a279",
        "#346f2c",
        "#ecc0c6"
    ]
    
    var initialTasks: Array<String> = [
        "Working",
        "Eating",
        "Sleeping",
        "Commuting",
        "Having Fun",
        "Exercising",
        "Surfing Internet",
        "Relaxing",
        "Nothing",
        "Playing"
    ]
    
    var maxTasksNum = 0
    
    init() {
        self.maxTasksNum = self.initialTasks.count
        self.loadTasks()
    }
    
    class var sharedInstance: TaskTypeManager {
        struct Static {
            static var instance: TaskTypeManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = TaskTypeManager()
        }
        
        return Static.instance!
        
    }
    
    func createAndSaveTaskTypeWithName(taskName: String) -> Bool {
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        
        // Check if is yet possible to create new tasks
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let tasks = coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskType] {
            
            if tasks.count >= self.maxTasksNum {
                return false
            }
            
        }
        
        // check if Task Name already exist
        var fetchByNameRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
        fetchByNameRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchByNameRequest.predicate = NSPredicate(format: "sid == %@", taskName.lowercaseString)
        if let task = coreDataStack.managedObjectContext!.executeFetchRequest(fetchByNameRequest, error: nil) as? [TaskType] {

            if task.count == 1 {
                return false
            }
            
        }
        
        var colorHex: String = self.nextHexColor()
        var taskType: TaskType = NSEntityDescription.insertNewObjectForEntityForName("TaskType", inManagedObjectContext: coreDataStack.managedObjectContext!) as TaskType
        taskType.colorHex = colorHex
        taskType.name = taskName
        taskType.sid = taskName.lowercaseString
        coreDataStack.saveContext()
        
        return true
        
    }
    
    func formatSecondsToPresent(seconds: Int) -> String {

        if seconds == 0 {
            return "0s"
        }
        
        var days: Int = seconds / ( 24 * 60 * 60 )
        var daysSecondsLeft: Int = seconds % ( 24 * 60 * 60 )
        var hours: Int = daysSecondsLeft / ( 60 * 60 )
        var hoursSecondsLeft: Int = daysSecondsLeft % ( 60 * 60 )
        var minutes: Int = hoursSecondsLeft / 60
        var seconds: Int = hoursSecondsLeft % 60
        
        var formattedString: String = "\(seconds)s"
        if minutes > 0 {
            formattedString = "\(minutes)m " + formattedString
        }
        
        if ( hours > 0 ) {
            formattedString = "\(hours)h " + formattedString
        }
        
        if ( days > 0 ) {
            formattedString = "\(days)d " + formattedString
        }
        
        return formattedString
        
    }
    
    func taskState(task: TaskType) -> State {
       
        if let currentLogRunning: Log = TaskTypeManager.sharedInstance.currentLogRunning() {
            if ( currentLogRunning.type.sid == task.sid) {
                return State.Running
            } else {
                return State.Stopped
            }
        }
        
        return State.Stopped
        
    }
    
    func toggleForTask(task: TaskType) -> State {
        
        var toStartTask = true
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        if let currentLogRunning: Log = TaskTypeManager.sharedInstance.currentLogRunning() {
            currentLogRunning.endTimestamp = NSDate().timeIntervalSinceReferenceDate
            toStartTask = !(currentLogRunning.type.sid == task.sid)
        }
        
        if ( toStartTask ) {
            var log: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: coreDataStack.managedObjectContext!) as Log
            log.startTimestamp = NSDate().timeIntervalSinceReferenceDate
            log.type = task
            coreDataStack.saveContext()
            
            return State.Running
        }
        
        coreDataStack.saveContext()
        return State.Stopped
        
    }
    
    func deleteTaskType(task: TaskType) -> Bool {

        // check if have no logs on the current week
        var logs: Array<Log> = self.weekLogsForTaskType(task)
        if logs.count == 0 {
            var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
            self.colors.append(task.colorHex)
            coreDataStack.managedObjectContext?.deleteObject(task)
            coreDataStack.saveContext()
            return true
        }
        
        return false
        
    }
    
    func calculateWeekTimeInSecondsForTask(task: TaskType) -> Int {
        
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        calendar.firstWeekday = 2                   // monday
        var currentDate: NSDate = NSDate()
        var startOfTheWeek: NSDate? = nil
        var interval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(NSCalendarUnit.WeekCalendarUnit, startDate: &startOfTheWeek, interval: &interval, forDate: currentDate)
        var endOfWeek: NSDate = startOfTheWeek!.dateByAddingTimeInterval(interval - 1)
        
        var startOfWeekTimestamp: Int = Int(startOfTheWeek!.timeIntervalSinceReferenceDate)
        var endOfWeekTimestamp: Int = Int(endOfWeek.timeIntervalSinceReferenceDate)
        var currentDateTimestamp: Int = Int(currentDate.timeIntervalSinceReferenceDate)
        
        var weekTimeInSeconds: Int = 0
        for log:Log in self.weekLogsForTaskType(task) {
            
            var endTimestamp: Int = Int(log.endTimestamp)
            var startTimestamp: Int = Int(log.startTimestamp)
            if endTimestamp == 0 {
                weekTimeInSeconds += ( currentDateTimestamp - startTimestamp )
            } else if startTimestamp >= startOfWeekTimestamp && endTimestamp <= endOfWeekTimestamp {
                weekTimeInSeconds += ( endTimestamp - startTimestamp )
            } else if startTimestamp < startOfWeekTimestamp {
                weekTimeInSeconds += ( endTimestamp - startOfWeekTimestamp )
            } else if endTimestamp > endOfWeekTimestamp {
                weekTimeInSeconds += ( endOfWeekTimestamp - startTimestamp )
            }
            
        }
        
        return weekTimeInSeconds
        
    }
    
    private func weekLogsForTaskType(task:TaskType) -> Array<Log> {
        
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        calendar.firstWeekday = 2 // monday
        var currentDate: NSDate = NSDate()
        var startOfTheWeek: NSDate? = nil
        var interval: NSTimeInterval = 0
        
        calendar.rangeOfUnit(NSCalendarUnit.WeekCalendarUnit, startDate: &startOfTheWeek, interval: &interval, forDate: currentDate)
        var endOfWeek: NSDate = startOfTheWeek!.dateByAddingTimeInterval(interval - 1)
        
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Log")
        fetchRequest.predicate = NSPredicate(format: "type == %@ AND ( endTimestamp == nil OR ( startTimestamp >= %@ AND startTimestamp <= %@ ) OR ( endTimestamp >= %@ AND endTimestamp <= %@ ) )", task, startOfTheWeek!, endOfWeek, startOfTheWeek!, endOfWeek)
        if let logs = coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Log] {
            return logs
        }
        
        return Array<Log>()
        
    }
    
    private func currentLogRunning() -> Log? {
        
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Log")
        fetchRequest.predicate = NSPredicate(format: "endTimestamp = nil")
        if let currentLog = coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Log] {
            
            if ( currentLog.count == 1 ) {
                return currentLog.first?
            }
            
        }
        
        
        return nil
        
    }
    
    private func currentTaskRunning() -> TaskType? {
        
        if let currentLogRunning: Log = currentLogRunning() {
            return currentLogRunning.type
        }
        
        return nil
        
    }
    
    private func nextHexColor() -> String {
        var unsignedArrayCount = UInt32(self.colors.count)
        var randomNumber = Int(arc4random_uniform(unsignedArrayCount))
        var hexColor: String = self.colors[randomNumber]
        self.colors.removeAtIndex(randomNumber)
        return hexColor
    }
    
    private func loadTasks() -> Void {
        
        let databaseCreated: Bool? = NSUserDefaults.standardUserDefaults().objectForKey("database_created") as? Bool        
        if (( databaseCreated ) != nil && databaseCreated! ) {
            
            var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
            var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            if let tasks = coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskType] {

                for task:TaskType in tasks {
                    for var index = 0; index < self.colors.count; index++ {
                        if task.colorHex == colors[index] {
                            self.colors.removeAtIndex(index)
                        }
                    }
                }
            
            }
            
        } else {
            
            for taskName:String in self.initialTasks {
                self.createAndSaveTaskTypeWithName(taskName)
            }
            
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "database_created")
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
    }
    
}
