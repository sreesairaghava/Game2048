//
//  SquareView.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit
/// A view representing a single swift-2048 tile.
class SquareView : UIView {
  var value : Int = 0 {
    didSet {
      backgroundColor = delegate.squareColor(value)
      numberLabel.textColor = delegate.numberColor(value)
      numberLabel.text = "\(value)"
    }
  }

  unowned let delegate : DisplayProviderProtocol
  let numberLabel : UILabel

  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
    
  init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: DisplayProviderProtocol) {
    delegate = d
    numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
    numberLabel.textAlignment = NSTextAlignment.center
    numberLabel.minimumScaleFactor = 0.5

    super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
    addSubview(numberLabel)
    layer.cornerRadius = radius

    self.value = value
    backgroundColor = delegate.squareColor(value)
    numberLabel.textColor = delegate.numberColor(value)
    numberLabel.text = "\(value)"
  }
}
