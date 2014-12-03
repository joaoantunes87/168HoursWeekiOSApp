//
//  LogTableViewCell.swift
//  168HoursWeek
//
//  Created by João Antunes on 01/12/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import UIKit
import CoreData

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var taskTypeNameLabel: UILabel!
   
    var taskType: TaskType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell() -> Void {
        
        if let taskTypeTemp:TaskType = self.taskType? {
            self.taskTypeNameLabel.text = taskTypeTemp.name
            self.backgroundColor = ColorWheel.sharedInstance.convertHexColorStringToUiColor(taskTypeTemp.colorHex)
            // TODO configure action
        }
        
    }
    
    @IBAction func stopOrStartLog() {

        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        if let taskTypeTemp:TaskType = self.taskType? {
            
            // TODO is to stop or start
            
            // start
            var log: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: coreDataStack.managedObjectContext!) as Log
            log.startTimestamp = NSDate().timeIntervalSince1970
            log.type = taskTypeTemp
            coreDataStack.saveContext()
            
        }
        
    }
    
}
