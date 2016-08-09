//
//  AMMKAnnotationView.swift
//
//  Created by Amr Mohamed on 7/28/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import MapKit


extension MKMapView {
    func showUser(coordinates : CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
        self.setRegion(region, animated: true)
    }
    
    func setRegionForAnnotations(annotations:[MKAnnotation]) {
        var region : MKCoordinateRegion
        
        switch annotations.count {
        case 0: region = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, 1000, 1000)
        case 1: region = MKCoordinateRegionMakeWithDistance(annotations.first!.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2DMake(-90, 180)
            var bottomRightCoord = CLLocationCoordinate2DMake(90, -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 2.0
            let span = MKCoordinateSpanMake(abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        self.setRegion(self.regionThatFits(region), animated: true)
    }
}
