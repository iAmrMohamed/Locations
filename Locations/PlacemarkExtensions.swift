//
//  AMPlacemarkParser.swift
//  Locations
//
//  Created by Amr Mohamed on 7/13/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    
    var fullAddress : String {
        var fullAddress = ""
        if let thoroughfare = self.thoroughfare {
            fullAddress += thoroughfare + ", "
        }
        
        if let locality = self.locality {
            fullAddress += locality + ", "
        }
        
        if let administrativeArea = self.administrativeArea {
            fullAddress += administrativeArea + ", "
        }
        
        if let country = self.country {
            fullAddress += country + ", "
        }
        return fullAddress
    }
    
}
