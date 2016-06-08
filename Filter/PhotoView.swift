//
//  PhotoView.swift
//  Filter
//
//  Created by tse on 16/6/8.
//  Copyright © 2016年 tse. All rights reserved.
//

import UIKit

class PhotoView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var lastTouchTime: NSDate? = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first {
            let location = touch.locationInView(self)
            print("x:\(location.x) y:\(location.y)")
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        let currentTime = NSDate()
        if let previousTime = lastTouchTime {
            if currentTime.timeIntervalSinceDate(previousTime) < 0.5 {
                print("double tap")
                
                lastTouchTime = nil
            } else {
                lastTouchTime = currentTime
            }
        } else {
            lastTouchTime = currentTime
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
    }
}
