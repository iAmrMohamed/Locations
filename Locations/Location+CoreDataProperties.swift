//
//  Location+CoreDataProperties.swift
//  Locations
//
//  Created by Amr Mohamed on 7/17/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Location {
    
    @NSManaged var name: String?
    @NSManaged var category: String?
    @NSManaged var date: NSDate
    @NSManaged var photoID: NSNumber?
    
    @NSManaged var altitude: Double
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var placemark: CLPlacemark?
    
}
