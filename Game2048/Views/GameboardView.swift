//
//  GameboardView.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit
class GameboardView: UIView {
    var dimension: Int
    var squareWidth: CGFloat
    var squarePadding: CGFloat
    var cornerRadius: CGFloat
    var squares: Dictionary<IndexPath, SquareView>

    let provider = DisplayProvider()

    let squarePopStartScale: CGFloat = 0.1
    let squarePopMaxScale: CGFloat = 1.1
    let squarePopDelay: TimeInterval = 0.05
    let squareExpandTime: TimeInterval = 0.18
    let squareContractTime: TimeInterval = 0.08

    let squareMergeStartScale: CGFloat = 1.0
    let squareMergeExpandTime: TimeInterval = 0.08
    let squareMergeContractTime: TimeInterval = 0.08

    let perSquareSlideDuration: TimeInterval = 0.08

    init(dimension d: Int, squareWidth width: CGFloat, squarePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor) {
      assert(d > 0)
      dimension = d
      squareWidth = width
      squarePadding = padding
      cornerRadius = radius
      squares = Dictionary()
      let sideLength = padding + CGFloat(dimension)*(width + padding)
      super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
      layer.cornerRadius = radius
      setupBackground(backgroundColor: backgroundColor, squareColor: foregroundColor)
    }

    required init(coder: NSCoder) {
      fatalError("NSCoding not supported")
    }

    
    /// Return whether a given position is valid. Used for bounds checking.
    func positionIsValid(_ pos: (Int, Int)) -> Bool {
      let (x, y) = pos
      return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }

    func setupBackground(backgroundColor bgColor: UIColor, squareColor: UIColor) {
      backgroundColor = bgColor
      var xCursor = squarePadding
      var yCursor: CGFloat
      let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
      for _ in 0..<dimension {
        yCursor = squarePadding
        for _ in 0..<dimension {
          // Draw each square
          let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: squareWidth, height: squareWidth))
          background.layer.cornerRadius = bgRadius
          background.backgroundColor = squareColor
          addSubview(background)
          yCursor += squarePadding + squareWidth
        }
        xCursor += squarePadding + squareWidth
      }
    }

    /// Update the gameboard by inserting a square in a given location. The square will be inserted with a 'pop' animation.
    func insertSquare(at pos: (Int, Int), value: Int) {
      assert(positionIsValid(pos))
      let (row, col) = pos
      let x = squarePadding + CGFloat(col)*(squareWidth + squarePadding)
      let y = squarePadding + CGFloat(row)*(squareWidth + squarePadding)
      let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
      let square = SquareView(position: CGPoint(x: x, y: y), width: squareWidth, value: value, radius: r, delegate: provider)
      square.layer.setAffineTransform(CGAffineTransform(scaleX: squarePopStartScale, y: squarePopStartScale))

      addSubview(square)
      bringSubviewToFront(square)
      squares[IndexPath(row: row, section: col)] = square

      // Add to board
      UIView.animate(withDuration: squareExpandTime, delay: squarePopDelay, options: UIView.AnimationOptions(),
        animations: {
          // Make the square 'pop'
          square.layer.setAffineTransform(CGAffineTransform(scaleX: self.squarePopMaxScale, y: self.squarePopMaxScale))
        },
        completion: { finished in
          // Shrink the square after it 'pops'
          UIView.animate(withDuration: self.squareContractTime, animations: { () -> Void in
            square.layer.setAffineTransform(CGAffineTransform.identity)
          })
      })
    }

    /// Update the gameboard by moving a single square from one location to another. If the move is going to collapse two
    /// squares into a new square, the square will 'pop' after moving to its new location.
    func moveOnesquare(from: (Int, Int), to: (Int, Int), value: Int) {
      assert(positionIsValid(from) && positionIsValid(to))
      let (fromRow, fromCol) = from
      let (toRow, toCol) = to
      let fromKey = IndexPath(row: fromRow, section: fromCol)
      let toKey = IndexPath(row: toRow, section: toCol)

      // Get the squares
      guard let square = squares[fromKey] else {
        assert(false, "placeholder error")
      }
      let endsquare = squares[toKey]

      // Make the frame
      var finalFrame = square.frame
      finalFrame.origin.x = squarePadding + CGFloat(toCol)*(squareWidth + squarePadding)
      finalFrame.origin.y = squarePadding + CGFloat(toRow)*(squareWidth + squarePadding)

      // Update board state
      squares.removeValue(forKey: fromKey)
      squares[toKey] = square

      // Animate
      let shouldPop = endsquare != nil
      UIView.animate(withDuration: perSquareSlideDuration,
        delay: 0.0,
        options: UIView.AnimationOptions.beginFromCurrentState,
        animations: {
          // Slide square
          square.frame = finalFrame
        },
        completion: { (finished: Bool) -> Void in
          square.value = value
          endsquare?.removeFromSuperview()
          if !shouldPop || !finished {
            return
          }
          square.layer.setAffineTransform(CGAffineTransform(scaleX: self.squareMergeStartScale, y: self.squareMergeStartScale))
          // Pop square
          UIView.animate(withDuration: self.squareMergeExpandTime,
            animations: {
              square.layer.setAffineTransform(CGAffineTransform(scaleX: self.squarePopMaxScale, y: self.squarePopMaxScale))
            },
            completion: { finished in
              // Contract square to original size
              UIView.animate(withDuration: self.squareMergeContractTime, animations: {
                square.layer.setAffineTransform(CGAffineTransform.identity)
              })
          })
      })
    }

    /// Update the gameboard by moving two squares from their original locations to a common destination. This action always
    /// represents square collapse, and the combined square 'pops' after both squares move into position.
    func moveTwosquares(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
      assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
      let (fromRowA, fromColA) = from.0
      let (fromRowB, fromColB) = from.1
      let (toRow, toCol) = to
      let fromKeyA = IndexPath(row: fromRowA, section: fromColA)
      let fromKeyB = IndexPath(row: fromRowB, section: fromColB)
      let toKey = IndexPath(row: toRow, section: toCol)

      guard let squareA = squares[fromKeyA] else {
        assert(false, "placeholder error")
      }
      guard let squareB = squares[fromKeyB] else {
        assert(false, "placeholder error")
      }

      // Make the frame
      var finalFrame = squareA.frame
      finalFrame.origin.x = squarePadding + CGFloat(toCol)*(squareWidth + squarePadding)
      finalFrame.origin.y = squarePadding + CGFloat(toRow)*(squareWidth + squarePadding)

      // Update the state
      let oldsquare = squares[toKey]  // TODO: make sure this doesn't cause issues
      oldsquare?.removeFromSuperview()
      squares.removeValue(forKey: fromKeyA)
      squares.removeValue(forKey: fromKeyB)
      squares[toKey] = squareA

      UIView.animate(withDuration: perSquareSlideDuration,
        delay: 0.0,
        options: UIView.AnimationOptions.beginFromCurrentState,
        animations: {
          // Slide squares
          squareA.frame = finalFrame
          squareB.frame = finalFrame
        },
        completion: { finished in
          squareA.value = value
          squareB.removeFromSuperview()
          if !finished {
            return
          }
          squareA.layer.setAffineTransform(CGAffineTransform(scaleX: self.squareMergeStartScale, y: self.squareMergeStartScale))
          // Pop square
          UIView.animate(withDuration: self.squareMergeExpandTime,
            animations: {
              squareA.layer.setAffineTransform(CGAffineTransform(scaleX: self.squarePopMaxScale, y: self.squarePopMaxScale))
            },
            completion: { finished in
              // Contract square to original size
              UIView.animate(withDuration: self.squareMergeContractTime, animations: {
                squareA.layer.setAffineTransform(CGAffineTransform.identity)
              })
          })
      })
    }
}
