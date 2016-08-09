//
//  AMHudView.swift
//  Locations
//
//  Created by Amr Mohamed on 8/1/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import Foundation
import UIKit
import Dispatch

class AMProgressView : UIView {
    
    static var sharedView = AMProgressView(frame: CGRectMake(0, 0, 150, 150))
    
    var imageView = UIImageView()
    
    var textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.layer.shadowOpacity = 0.5
        self.backgroundColor = UIColor.whiteColor()
        
        self.imageView.frame = CGRectMake(8, 8, 150 - 16, 100 - 16)
        self.imageView.contentMode = .ScaleAspectFit
        
        self.textLabel.frame = CGRectMake(8, 108, 150 - 16, 50 - 16)
        self.textLabel.textAlignment = .Center
        
        self.addSubview(self.textLabel)
        self.addSubview(self.imageView)
    }
    
    func showAnimated(animated: Bool?) {
        if animated != nil && animated! {
            self.alpha = 0
            self.transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            UIView.animateWithDuration(0.5, animations: {
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
            })
        }
    }
    
    class func showInView(view: UIView , animated: Bool?) {
        self.sharedView.imageView.image = UIImage(named: "Checkmark")
        self.sharedView.textLabel.text = "Success"
        
        
        view.addSubview(self.sharedView)
        self.sharedView.center = view.center
        self.sharedView.showAnimated(animated)
    }
    
    class func hide() {
        self.sharedView.removeFromSuperview()
    }
    
}