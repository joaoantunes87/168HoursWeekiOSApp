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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.fetchedResultsController!.performFetch(nil)
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
        
        if ( buttonIndex == 1 ) {
            
            var taskName: String = alertView.textFieldAtIndex(0)!.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !taskName.isEmpty {
                // TODO check if task already exists if not add
                // Limit the num of task type -- Add more on premium
                println("TaskName: \(taskName)")
                var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
                var colorHex: String = ColorWheel.sharedInstance.nextHexColor()
                var taskType: TaskType = NSEntityDescription.insertNewObjectForEntityForName("TaskType", inManagedObjectContext: coreDataStack.managedObjectContext!) as TaskType
                taskType.colorHex = colorHex
                taskType.name = taskName
                coreDataStack.saveContext()
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
        var coreDataStack: CoreDataStack = CoreDataStack.defaultStack
        coreDataStack.managedObjectContext?.deleteObject(taskType)
        coreDataStack.saveContext()
    }
    
    func taskTypeListFetchRequest() -> NSFetchRequest {
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskType")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LogTableViewCell = tableView.dequeueReusableCellWithIdentifier("LogCell", forIndexPath: indexPath) as LogTableViewCell
        var taskType: TaskType = self.fetchedResultsController.objectAtIndexPath(indexPath) as TaskType
        cell.taskType = taskType
        cell.configureCell()
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
            self.tableView.deleteRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    
    
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
