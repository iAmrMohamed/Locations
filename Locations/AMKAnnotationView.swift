//
//  AMKAnnotationView.swift
//  Locations
//
//  Created by Amr Mohamed on 7/31/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import MapKit

class AMKAnnotationView: MKAnnotationView {
    
    var imageView = AMRoundedImageView()
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, size: CGSize) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRectMake(0, 0, size.width, size.height)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func commonInit() {
        self.imageView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.imageView.layer.borderWidth = 5.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.addSubview(imageView)
        self.sendSubviewToBack(self.imageView)
    }
    
}