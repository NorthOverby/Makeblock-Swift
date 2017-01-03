//
//  UIForceTouchButton.swift
//  DemoProject
//
//  Created by North Overby on 1/2/17.
//  Copyright © 2017 Makeblock. All rights reserved.
//

import Foundation
import UIKit


class UIForceTouchButton : UIBorderedButton {
    
    var onForceTouchPressureChanged: ((CGFloat) -> Void)?
    var lastTouchPressure: CGFloat = 0.0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendForceTouchPressureUpdates(forTouches: touches)
        print("touch began")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendForceTouchPressureUpdates(forTouches: touches)
        print("touch moved")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendForceTouchPressureUpdates(touchPressure: 0.0)
        print("touch ended")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendForceTouchPressureUpdates(forTouches: touches)
        print("touch cancelled")
    }
}

extension UIForceTouchButton {
    fileprivate func touchPressureFromTouchEvent(_ touch: UITouch) -> CGFloat {
        return touch.force == 0 ? touch.force : (touch.force / touch.maximumPossibleForce)
    }
    
    fileprivate func sendForceTouchPressureUpdates(touchPressure: CGFloat) {
        guard let forceTouchChanged = onForceTouchPressureChanged else { return }
        forceTouchChanged(touchPressure)
    }
    
    fileprivate func sendForceTouchPressureUpdates(forTouches touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        guard let forceTouchChanged = onForceTouchPressureChanged else { return }
        
        let touchPressure = touchPressureFromTouchEvent(touch)
        if touchPressure != lastTouchPressure {
            lastTouchPressure = touchPressure
            forceTouchChanged(touchPressure)
            print("new pressure: \(touchPressure)")
        }
        
    }
}
