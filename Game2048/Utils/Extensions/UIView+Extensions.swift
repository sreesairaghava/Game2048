//
//  UIView+Extensions.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import Foundation
import UIKit.UIView

extension UIView{
    enum axis{
        case x
        case y
    }
    func PositionToCenterView(to v: UIView, axis: axis){
        var viewAxis: CGFloat
        var vcAxis: CGFloat
        var tempAxis: CGFloat
        switch axis {
        case .x:
            viewAxis  = self.bounds.size.width
            vcAxis = v.bounds.size.width
            tempAxis = 0.5 * (vcAxis - viewAxis)
        case .y:
            viewAxis = self.bounds.size.height
            vcAxis = v.bounds.height
            tempAxis = 0.5 * (vcAxis - viewAxis)
        }
    
        self.frame.origin.x = tempAxis
    }
}
