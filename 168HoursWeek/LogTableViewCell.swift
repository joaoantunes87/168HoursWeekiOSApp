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
    @IBOutlet weak var weekTimeLabel: UILabel!
   
    var tableView: UITableView?
    var taskType: TaskType?
    var weekTimeInSeconds: Int = 0
    var timer: NSTimer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(tableView: UITableView) -> Void {
        
        self.tableView = tableView
        
        if let taskTypeTemp:TaskType = self.taskType? {
            self.taskTypeNameLabel.text = taskTypeTemp.name
            self.backgroundColor = ColorWheel.sharedInstance.convertHexColorStringToUiColor(taskTypeTemp.colorHex)
            var state: State = TaskTypeManager.sharedInstance.taskState(taskTypeTemp)
            self.weekTimeInSeconds = TaskTypeManager.sharedInstance.calculateWeekTimeInSecondsForTask(taskTypeTemp)
            self.weekTimeLabel.text = TaskTypeManager.sharedInstance.formatSecondsToPresent(self.weekTimeInSeconds)
            self.updateState(state)
        }
        
    }
    
    @IBAction func stopOrStartLog() {
        if let task = self.taskType {
            var state: State = TaskTypeManager.sharedInstance.toggleForTask(self.taskType!)
            if let tableViewTemp = self.tableView {
                tableViewTemp.reloadData()
            }
        }

    }
    
    private func updateState(state: State) {
        switch state {
        case .Running:
            self.actionButton.setTitle("Stop", forState: UIControlState.Normal)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        case .Stopped:
            self.actionButton.setTitle("Play", forState: UIControlState.Normal)
            self.timer?.invalidate()
        }
        
    }
    
    func updateTimer() {
        self.weekTimeInSeconds++
        self.weekTimeLabel.text = TaskTypeManager.sharedInstance.formatSecondsToPresent(self.weekTimeInSeconds)
    }
    
}
