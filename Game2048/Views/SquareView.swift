//
//  SquareView.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

class SquareView: UIView {

    var number: Int = 0{
        didSet{
            backgroundColor = .systemPink
        }
    }
    
    // Delegate to get squareColor,numberColor
    unowned let delegate: DisplayProviderProtocol
    let numberLabel: UILabel
    required init?(coder: NSCoder) {
        fatalError("NScoding not supported!!..")
    }
    //Init
    init(position: CGPoint,width:CGFloat,number:Int,radius:CGFloat,delegate d: DisplayProviderProtocol) {
        delegate = d
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.minimumScaleFactor = 0.5
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        //Setting up numberLabel
        self.number = number
        backgroundColor = delegate.squareColor(number)
        numberLabel.textColor = delegate.numberColor(number)
        numberLabel.text = "\(number)"
    }

}
