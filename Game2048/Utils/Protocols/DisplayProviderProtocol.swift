//
//  DisplayProviderProtocol.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

protocol DisplayProviderProtocol: AnyObject {
    func squareColor(_ value: Int) -> UIColor
    func numberColor(_ value: Int) -> UIColor
}

class DisplayProvider: DisplayProviderProtocol {
    func squareColor(_ value: Int) -> UIColor {
        switch value {
        case 2:
            return UIColor("#eee4da",alpha: 1)
        case 4:
            return UIColor("#ede0c8",alpha: 1)
        case 8:
            return UIColor("#f2a579",alpha: 1)
        case 16:
            return UIColor("#f59663",alpha: 1)
        case 32:
            return UIColor("#f67d5f",alpha: 1)
        case 64:
            return UIColor("#f65d3b",alpha: 1)
        case 128, 256, 512,1024,2048:
            return UIColor("#edce72",alpha: 1)
        default:
            return UIColor.white
        }
    }
    
    func numberColor(_ value: Int) -> UIColor {
        switch value {
        case 2,4:
            return UIColor("#776e65",alpha: 1)
        default:
            return UIColor.white
        }
    }
}
