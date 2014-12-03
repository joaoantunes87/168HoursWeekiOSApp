//
//  ColorWheel.swift
//  168HoursWeek
//
//  Created by João Antunes on 03/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ColorWheel {
    
    var colors: Array<String> = ["#ff001e",
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
    
    init() {
        self.loadColors()
    }
    
    class var sharedInstance: ColorWheel {
        struct Static {
            static var instance: ColorWheel?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ColorWheel()
        }
        
        return Static.instance!
        
    }
    
    func nextHexColor() -> String {
        var unsignedArrayCount = UInt32(self.colors.count)
        var randomNumber = Int(arc4random_uniform(unsignedArrayCount))
        var hexColor: String = self.colors[randomNumber]
        self.colors.removeAtIndex(randomNumber)
        return hexColor
    }

    func convertHexColorStringToUiColor(hexColor: String) -> UIColor {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hexColor.hasPrefix("#") {
            let index   = advance(hexColor.startIndex, 1)
            let hex     = hexColor.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if countElements(hex) == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if countElements(hex) == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9")
                }
            } else {
                println("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func loadColors() -> Void {

        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        if let tasks = coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [TaskType] {
            println("Tasks Count: \(tasks.count)")
            for task:TaskType in tasks {
                for var index = 0; index < self.colors.count; index++ {
                    if task.colorHex == colors[index] {
                        self.colors.removeAtIndex(index)
                    }
                }
            }
            
        }
        
    }
    
}
