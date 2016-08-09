//
//  Location.swift
//  Locations
//
//  Created by Amr Mohamed on 7/17/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject , MKAnnotation {
    
    var coordinate : CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longitude))
        }
    }
    
    var title: String? {
        return self.name
    }
    
    var subtitle: String? {
        return self.category
    }
    
    var hasPhoto : Bool {
        return self.photoID != nil
    }
    
    var photoPath : String {
        assert(self.photoID != nil)
        return documentsDirectoryPath + "photo-\(self.photoID!.integerValue).jpg"
    }
    
    var photoImage : UIImage {
        return UIImage(contentsOfFile: self.photoPath)!
    }
    
    func removePhotoFile() {
        if self.hasPhoto {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(self.photoPath)
            } catch { print(error) }
        }
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("photoID")
        let newID = currentID + 1
        userDefaults.setInteger(newID, forKey: "photoID")
        userDefaults.synchronize()
        return newID
    }
    
}
