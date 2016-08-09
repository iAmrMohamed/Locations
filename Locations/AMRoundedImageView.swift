//
//  AMRoundedImageView.swift
//  Locations
//
//  Created by Amr Mohamed on 7/31/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit

class AMRoundedImageView : UIImageView {
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
}
