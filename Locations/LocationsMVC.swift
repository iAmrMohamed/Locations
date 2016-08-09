//
//  LocationsMapViewController.swift
//  Locations
//
//  Created by Amr Mohamed on 7/28/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsMapViewController: UIViewController {
    
    lazy var managedObjectContext : NSManagedObjectContext! = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    @IBOutlet weak var MapView: MKMapView! {
        didSet {
            self.MapView.delegate = self
        }
    }
    
    var locations = [Location]() {
        didSet {
            dispatch_async(dispatch_get_main_queue(),  {
                self.MapView.removeAnnotations(self.locations)
                self.MapView.addAnnotations(self.locations)
                self.MapView.setRegionForAnnotations(self.locations)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocationDetails" {
            guard let ALVC = segue.destinationViewController as? AddWEditLocationTableViewController else {return}
            guard let index = sender?.view.tag else {return}
            print(index)
            ALVC.locationToEdit = self.locations[index]
        }
    }
    
    func performFetch() {
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        
        let loadLocations = {
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
        
    }
    
    func saveCoreData() {
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Fatal CoreData Error : \(error)")
        }
    }
    
}

extension LocationsMapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else { return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? AMKAnnotationView
        
        if annotationView == nil {
            annotationView = AMKAnnotationView(annotation: annotation, reuseIdentifier: "pin", size: CGSizeMake(65, 65))
        }
        
        annotationView?.annotation = annotation
        annotationView?.draggable = true
        annotationView?.canShowCallout = true
        
        if let index = self.locations.indexOf(annotation as! Location) {
            let location = self.locations[index]
            
            var image = UIImage()
            if location.hasPhoto {
                image = UIImage(contentsOfFile: location.photoPath)!
            } else {
                image = UIImage(named: "No Photo")!
            }
            
            annotationView!.imageView.image = image
            let imageView = AMRoundedImageView(frame: CGRectMake(0, 0, 45, 45))
            imageView.image = image
            annotationView?.leftCalloutAccessoryView = imageView
            
            let deleteButton = UIButton(type: .Custom)
            deleteButton.frame = CGRectMake(0, 0, 45, 45)
            deleteButton.setImage(UIImage(named: "Trash"), forState: .Normal)
            deleteButton.tintColor = UIColor.redColor()
            deleteButton.tag = index
            deleteButton.addTarget(self, action: #selector(self.deleteAnnotation(_:)), forControlEvents: .TouchUpInside)
            annotationView?.rightCalloutAccessoryView = deleteButton
        }
        
        return annotationView
    }
    
    func deleteAnnotation(sender: UIButton) {
        let location = self.locations[sender.tag]
        self.managedObjectContext.deleteObject(location)
        self.MapView.removeAnnotation(location)
        self.saveCoreData()
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .Starting:
            view.dragState = .Dragging
        case .Ending, .Canceling:
            view.dragState = .None
            
            if let anno = view.annotation {
                if let location = anno as? Location {
                    location.latitude = anno.coordinate.latitude
                    location.longitude = anno.coordinate.longitude
                    self.saveCoreData()
                }
            }
            
        default: break
        }
    }
    
}
