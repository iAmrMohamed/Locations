//
//  LocationsTableViewController.swift
//  Locations
//
//  Created by Amr Mohamed on 7/12/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

extension UIViewController {
    func delay(delay: Double, compeletion: ()->()) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay))
        dispatch_after(when, dispatch_get_main_queue(), compeletion)
    }
}

class LocationsTableViewController: UITableViewController {
    
    lazy var locationsMapViewController : LocationsMapViewController! = {
       return self.storyboard?.instantiateViewControllerWithIdentifier("LocationsMapViewController") as! LocationsMapViewController
    }()
    
    @IBAction func SegmentValueChanged(sender: AnyObject) {
        if self.childViewControllers.first is LocationsMapViewController {
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
            self.tableView.scrollEnabled = true
            self.locationsMapViewController.view.removeFromSuperview()
            self.locationsMapViewController.removeFromParentViewController()
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.tableView.scrollEnabled = false
            self.addChildViewController(self.locationsMapViewController)
            self.locationsMapViewController.didMoveToParentViewController(self)
            self.locationsMapViewController.view.frame = self.view.bounds
            self.locationsMapViewController.MapView.center.x = self.locationsMapViewController.MapView.center.x + self.view.bounds.width * 2
            self.view.addSubview(self.locationsMapViewController.view)
        }
    }
    
    var locations = [Location]()
    
    lazy var managedObjectContext : NSManagedObjectContext! = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        _ = try? self.fetchedResultsController.performFetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LocationTableViewCell
        let location = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        cell.configureCellForLocation(location)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sectionIndexTitles[section]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !self.tableView.editing
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            self.managedObjectContext.deleteObject(location)
            do {
                location.removePhotoFile()
                try self.managedObjectContext.save()
            } catch { print(error) }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocationDetails" {
            guard let ALVC = segue.destinationViewController as? AddWEditLocationTableViewController else {return}
            guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
            ALVC.locationToEdit = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Location
        }
    }
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        var loadLocations = {
            do {
                self.locations = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]
            } catch {
                print(error)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object:self.managedObjectContext, queue: NSOperationQueue.mainQueue()) { (notification) in
            loadLocations()
        }
        loadLocations()
        
        NSFetchedResultsController.deleteCacheWithName("Locations")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "locations")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    deinit {
        self.fetchedResultsController.delegate = nil
    }
    
}

extension LocationsTableViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type:
        NSFetchedResultsChangeType) {
        switch type {
        case .Insert: self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete: self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move: print("Section Move")
        case .Update: print("Section Update")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert: self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete: self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? LocationTableViewCell {
                let location = controller.objectAtIndexPath(indexPath!) as! Location
                cell.configureCellForLocation(location)
            }
        }
    }
    
}
