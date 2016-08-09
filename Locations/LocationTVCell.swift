//
//  LocationTableViewCell.swift
//  Locations
//
//  Created by Amr Mohamed on 7/20/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var LocationImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.LocationImage.layer.cornerRadius = self.LocationImage.frame.height/2
    }
    
    func configureCellForLocation(location : Location) {
        if location.hasPhoto {
            self.LocationImage.image = UIImage(named: documentsDirectoryPath.stringByAppendingString("photo-\(location.photoID!).jpg"))
        } else {
            self.LocationImage.image = UIImage(named: "No Photo")
        }
        if let name = location.name {
            self.NameLabel.text = name
        }
        if let placemark = location.placemark?.fullAddress {
            self.AddressLabel.text = placemark
        }
    }
    
}
