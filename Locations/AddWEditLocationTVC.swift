//
//  TagLocationTableViewController.swift
//  Locations
//
//  Created by Amr Mohamed on 7/12/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import CoreMedia
import MapKit

class AddWEditLocationTableViewController: UITableViewController {
    
    @IBOutlet weak var SaveButton : UIBarButtonItem!
    @IBOutlet weak var NameTextView : UITextView!
    @IBOutlet weak var NameTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var CategoryLabel : UILabel!
    @IBOutlet weak var DateLabel : UILabel!
    @IBOutlet weak var AltitudeLabel : UILabel!
    @IBOutlet weak var LatitudeLabel : UILabel!
    @IBOutlet weak var LongitudeLabel : UILabel!
    @IBOutlet weak var AddressLabel : UILabel!
    
    @IBOutlet weak var imageView : UIImageView! {
        didSet {
            dispatch_async(dispatch_get_main_queue(),  {
                self.imageView.layer.cornerRadius = self.imageView.frame.height/2
            })
        }
    }
        
    let geoCoder = CLGeocoder()
    
    var locationToEdit : Location? {
        didSet {
            dispatch_async(dispatch_get_main_queue(),  {
                self.title = "Edit Location"
                self.navigationItem.leftBarButtonItems = []
                self.navigationItem.rightBarButtonItems = []
                self.delay(0.2, compeletion: {
                    self.NameTextView.text = self.locationToEdit!.name
                    self.CategoryLabel.text = self.locationToEdit!.category
                    self.DateLabel.text = self.dateFormatter.stringFromDate(self.locationToEdit!.date)
                    self.AltitudeLabel.text = String(self.locationToEdit!.altitude)
                    self.LatitudeLabel.text = String(self.locationToEdit!.latitude)
                    self.LongitudeLabel.text = String(self.locationToEdit!.longitude)
                    self.AddressLabel.text = self.locationToEdit!.placemark!.fullAddress
                    if self.locationToEdit!.hasPhoto {
                        self.imageView.image = UIImage(contentsOfFile: self.locationToEdit!.photoPath)
                    } else {
                        self.imageView.image = UIImage(named: "No Photo")
                    }
                })
            })
        }
    }
    
    var currentLocation : CLLocation! {
        didSet {
            dispatch_async(dispatch_get_main_queue(),  {
                self.DateLabel.text = self.dateFormatter.stringFromDate(NSDate())
                self.AltitudeLabel.text = String(self.currentLocation.altitude)
                self.LatitudeLabel.text = String(self.currentLocation.coordinate.latitude)
                self.LongitudeLabel.text = String(self.currentLocation.coordinate.longitude)
            })
        }
    }
    
    var currentPlacemark : CLPlacemark! {
        didSet {
            dispatch_async(dispatch_get_main_queue(),  {
                self.AddressLabel.text = self.currentPlacemark.fullAddress
                self.SaveButton.enabled = true
            })
        }
    }
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    lazy var dateFormatter : NSDateFormatter = {
        let dateForm = NSDateFormatter()
        dateForm.dateStyle = .MediumStyle
        dateForm.timeStyle = .ShortStyle
        return dateForm
    }()
    
    lazy var managedObjectContext : NSManagedObjectContext! = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForBackgroundNotification()
        if self.locationToEdit == nil { self.locationManager.startUpdatingLocation() }
        self.NameTextView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.locationToEdit != nil {
            self.saveCoreLocationItem()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return 65
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 81
        }
        return 65
    }
    
    var observer : AnyObject!
    func listenForBackgroundNotification() {
        self.observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if self!.presentedViewController != nil {
                self!.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            if self?.locationToEdit != nil {
                self?.saveCoreLocationItem()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.observer)
    }
    
    @IBAction func AddPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        self.navigationController?.presentViewController(imagePicker, animated: true, completion: nil)
        print("Hey")
    }
    
    @IBAction func CancelAddingLocation() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func SaveAddingLocation() {
        self.NameTextView.resignFirstResponder()
        AMProgressView.showInView(self.tableView, animated: true)
        delay(1.0, compeletion: {
            self.navigationController?.dismissViewControllerAnimated(true, completion: {
                self.saveCoreLocationItem()
            })
        })
    }
    
    func saveCoreLocationItem() {
        let location : Location
        
        if locationToEdit != nil {
            location = self.locationToEdit!
        } else {
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext) as! Location
            location.placemark = self.currentPlacemark
        }
        
        location.altitude = Double(self.AltitudeLabel.text!)!
        location.latitude = Double(self.LatitudeLabel.text!)!
        location.longitude = Double(self.LongitudeLabel.text!)!
        location.name = self.NameTextView.text
        location.category = self.CategoryLabel.text
        location.date = self.dateFormatter.dateFromString(self.DateLabel.text!)!
        
        if let image = self.imageView.image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.writeToFile(location.photoPath, options: NSDataWritingOptions.DataWritingAtomic)
                } catch {
                    fatalError("Error Writing image")
                }
            }
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Fatal CoreData Error : \(error)")
        }
    }
    
    // MARK-: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let CTVC = segue.destinationViewController as? CategoriesTableViewController else {return}
        CTVC.selectedIndexPath = NSIndexPath(forRow: CTVC.tableData.indexOf(self.CategoryLabel.text!)!, inSection: 0)
        CTVC.delegate = self
    }
}

extension AddWEditLocationTableViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = locations.first
        self.geoCoder.reverseGeocodeLocation(self.currentLocation!) { (placemarks, error) in
            guard error == nil else { print(error!.localizedDescription) ; return}
            if let placemark = placemarks?.first {
                self.currentPlacemark = placemark
            }
        }
    }
}

extension AddWEditLocationTableViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddWEditLocationTableViewController : CategoriesTableViewControllerDelegate {
    func didSelectCategoryWithName(name: String) {
        self.CategoryLabel.text = name
    }
}

extension AddWEditLocationTableViewController : UITextViewDelegate {
    
    func updateTextViewHeight() {
        let constant = self.NameTextView.contentSize.height + self.NameTextView.contentInset.top + self.NameTextView.contentInset.bottom + 16
        if constant <= 250 {
            self.NameTextViewHeight.constant = constant
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.tableView.beginUpdates()
        self.updateTextViewHeight()
        self.tableView.endUpdates()
    }
}