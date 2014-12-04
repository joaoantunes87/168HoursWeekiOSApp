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
        "#68ff45",
        "#39dbff",
        "#2a37ff",
        "#f6ff09",
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
        "Nothing"
    ]
    
    init() {
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
    
    func createAndSaveTaskTypeWithName(taskName: String) -> Void {
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        
        // TODO check if Task Name already exist
        
        // TODO Check if is yet possible to create new tasks
        
        var colorHex: String = self.nextHexColor()
        var taskType: TaskType = NSEntityDescription.insertNewObjectForEntityForName("TaskType", inManagedObjectContext: coreDataStack.managedObjectContext!) as TaskType
        taskType.colorHex = colorHex
        taskType.name = taskName
        taskType.sid = taskName.lowercaseString
        coreDataStack.saveContext()
        
    }
    
    func currentTaskRunning() -> TaskType! {
        return nil
    }
    
    func deleteTaskType(task: TaskType) {

        // TODO check if have no logs on the current week
        
        // TODO after deleted return color
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
