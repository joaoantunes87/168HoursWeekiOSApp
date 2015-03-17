//
//  TasksTableViewController.swift
//  168HoursWeek
//
//  Created by João Antunes on 27/11/2014.
//  Copyright (c) 2014 InverseLife. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIAlertViewDelegate {

    lazy var fetchedResultsController: NSFetchedResultsController! = {
        
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        var fetchRequest: NSFetchRequest = self.taskTypeListFetchRequest()
        
        var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TaskTypeManager.sharedInstance
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.fetchedResultsController!.performFetch(nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadData", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTaskType(sender: UIBarButtonItem) {
        
        var alert: UIAlertView = UIAlertView(title: "Add Task Type", message: "Create a new type for your tasks:", delegate: self, cancelButtonTitle:"Cancel", otherButtonTitles: "Create")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
        var alertTextField: UITextField! = alert.textFieldAtIndex(0)
        alertTextField.placeholder = "Task name";
        alert.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 1 {
            let taskName = alertView.textFieldAtIndex(0)?.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !taskName!.isEmpty {
                if !TaskTypeManager.sharedInstance.createAndSaveTaskTypeWithName(taskName!) {
                    let cannotCreateAlert = UIAlertController(title: "Error", message: "Task can not be created. You can only have \(TaskTypeManager.sharedInstance.maxTasksNum) Tasks and the task name must be unique. You can delete tasks", preferredStyle: .Alert)
                    
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    cannotCreateAlert.addAction(okButton)
                    
                    self.presentViewController(cannotCreateAlert, animated: true, completion: nil)
                }
            } else {
                let cannotCreateAlert = UIAlertController(title: "Error", message: "Task Name is required", preferredStyle: .Alert)
                
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                cannotCreateAlert.addAction(okButton)
                
                self.presentViewController(cannotCreateAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let sections = self.fetchedResultsController.sections {
            var sectionInfo: NSFetchedResultsSectionInfo = sections[section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var taskType: TaskType = self.fetchedResultsController.objectAtIndexPath(indexPath) as TaskType
        if TaskTypeManager.sharedInstance.deleteTaskType(taskType) == false {
            let cannotDeleteAlert = UIAlertController(title: "Error", message: "Task can not be deleted because it has week logs. Try on the beginning of next week", preferredStyle: .Alert)
            
            let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
            cannotDeleteAlert.addAction(okButton)
            
            self.presentViewController(cannotDeleteAlert, animated: true, completion: nil)
        }
    }
    
    func taskTypeListFetchRequest() -> NSFetchRequest {
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LogTableViewCell = tableView.dequeueReusableCellWithIdentifier("LogCell", forIndexPath: indexPath) as LogTableViewCell
        if let taskType: TaskType = self.fetchedResultsController.objectAtIndexPath(indexPath) as? TaskType {
            cell.taskType = taskType
            cell.configureCell(self.tableView)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight: CGFloat = screenSize.height;
        
        let navigatonBarSize: CGRect? = self.navigationController?.navigationBar.bounds
        let navigationBarHeight: CGFloat = navigatonBarSize!.height
        
        if let sections = self.fetchedResultsController.sections {
            var sectionInfo: NSFetchedResultsSectionInfo = sections[0] as NSFetchedResultsSectionInfo
            CGFloat(sectionInfo.numberOfObjects)
            return ( screenHeight - navigationBarHeight ) / CGFloat(sectionInfo.numberOfObjects)
        }
        
        return 56
        
    }

}
