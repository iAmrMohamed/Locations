//
//  ViewController.swift
//  Locations
//
//  Created by Amr Mohamed on 7/12/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit
import CoreLocation

struct TableItem {
    var title = ""
    var value = ""
}

class CurrentLocationTableViewController: UITableViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var AddButton: UIBarButtonItem!
    
    var tableData = [TableItem]()
    
    let geoCoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var currentPlacemark : CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let item = self.tableData[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.value
        
        return cell
    }
    
    @IBAction func LoadLocation() {
        print("LoadLocation")
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func TagLocation() {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        self.currentLocation = locations.first
        self.reloadData()
        self.locationManager.stopUpdatingLocation()
    }
    
    func reloadData() {
        self.geoCoder.reverseGeocodeLocation(self.currentLocation!) { (placemarks, error) in
            guard error == nil else { print(error!.localizedDescription) ; return}
            
            if let placemark = placemarks?.first {
                
                self.currentPlacemark = placemark
                
                if let thoroughfare = placemark.thoroughfare {
                    self.tableData.append(TableItem(title: "StreetName", value: thoroughfare))
                }
                
                if let locality = placemark.locality {
                    self.tableData.append(TableItem(title: "City", value: locality))
                }
                
                if let administrativeArea = placemark.administrativeArea {
                    self.tableData.append(TableItem(title: "State", value: administrativeArea))
                }
                
                if let country = placemark.country {
                    self.tableData.append(TableItem(title: "Country", value: country))
                }
                
                self.tableData.append(TableItem(title: "Altitude", value: String(self.currentLocation!.altitude)))
                self.tableData.append(TableItem(title: "Latitude", value: String(self.currentLocation!.coordinate.latitude)))
                self.tableData.append(TableItem(title: "Longitude", value: String(self.currentLocation!.coordinate.longitude)))
                
            }
            
            self.AddButton.enabled = true
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let nav = segue.destinationViewController as? UINavigationController else {return}
        guard let ALTVC = nav.viewControllers.first as? AddLocationTableViewController else {return}
        ALTVC.currentLocation = self.currentLocation
        ALTVC.currentPlacemark = self.currentPlacemark
    }
    
}