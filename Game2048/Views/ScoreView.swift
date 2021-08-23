//
//  ScoreView.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 23/08/21.
//

import UIKit

protocol ScoreViewProtocol {
  func scoreChanged(to s: Int)
}
class ScoreView: UIView, ScoreViewProtocol {
    
    var score : Int = 0 {
      didSet {
        label.text = "SCORE: \(score)"
      }
    }
    
    

    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)
    var label: UILabel

    init(backgroundColor bgcolor: UIColor, textColor tcolor: UIColor, font: UIFont, radius r: CGFloat) {
      label = UILabel(frame: defaultFrame)
      label.textAlignment = NSTextAlignment.center
      super.init(frame: defaultFrame)
      backgroundColor = bgcolor
      label.textColor = tcolor
      label.font = font
      layer.cornerRadius = r
      self.addSubview(label)
    }

    required init(coder aDecoder: NSCoder) {
      fatalError("NSCoding not supported")
    }

    func scoreChanged(to s: Int)  {
      score = s
    }

}
