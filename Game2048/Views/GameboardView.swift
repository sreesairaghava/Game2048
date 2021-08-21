//
//  GameboardView.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

class GameboardView: UIView {
    // GameboardView's parameters
    var dimension: Int
    var cornerRadius: CGFloat
    var squareWidth: CGFloat
    var squarePadding: CGFloat
    var squares: Dictionary<IndexPath,SquareView>
    
    let provider = DisplayProvider()
    
    //Square paramters for animation
    let squarePopStartScale: CGFloat = 0.1
    let squarePopMaxScale: CGFloat = 1.1
    let squarePopDelay: TimeInterval = 0.05
    let squareExpandTime: TimeInterval = 0.18
    let squareContractTime: TimeInterval = 0.08
    
    init(dimension d: Int,cornerRadius radius: CGFloat,squareWidth width: CGFloat,squarePadding padding:CGFloat,backgroundColor: UIColor,foregroundColor:UIColor) {
        dimension = d
        cornerRadius = radius
        squareWidth = width
        squarePadding = padding
        squares = Dictionary()
        let sideLength = padding + CGFloat(dimension)*(width + padding)
        super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        setupGameBackground(backgroundColor: backgroundColor, squareColor: foregroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// SetupGameBackground with backgroundColor and  tileColor
    func setupGameBackground(backgroundColor bgColor: UIColor, squareColor: UIColor){
        backgroundColor = bgColor
        var xDirection = squarePadding
        var yDirection: CGFloat
        let bgRadius = (cornerRadius >= 2 ) ? cornerRadius - 2 : 0
        for _ in 0..<dimension{
            yDirection = squarePadding
            for _ in 0..<dimension{
                let background = UIView(frame: CGRect(x: xDirection, y: yDirection, width: squareWidth, height: squareWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = squareColor
                addSubview(background)
                yDirection += squarePadding + squareWidth
            }
            xDirection += squarePadding + squareWidth
        }
        
    }
    //MARK: - Helper Functions
    func isPositionValid(_ pos: (Int,Int)) -> Bool{
        let (x,y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension )
    }
    //MARK: - GAME FUNCTIONS
    
    /// Update the gameboard by inserting square in a given location. Insertion with pop animation
    func insertSquare(at pos: (Int,Int),number: Int){
        assert(isPositionValid(pos))
        let (row, col) = pos
        let x = squarePadding + CGFloat(col)*(squareWidth + squarePadding)
        let y = squarePadding + CGFloat(row)*(squareWidth + squarePadding)
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        let square = SquareView(position: CGPoint(x: x, y: y), width: squareWidth, number: number, radius: r, delegate: provider )
        square.layer.setAffineTransform(CGAffineTransform(scaleX: squarePopStartScale, y: squarePopStartScale))
        addSubview(square)
        bringSubviewToFront(square)
        squares[IndexPath(row: row, section: col)] = square
        
        // Add to board
        UIView.animate(
            withDuration: squareExpandTime,
            delay: squarePopDelay,
            options: UIView.AnimationOptions(),
        animations: {
            square.layer.setAffineTransform(
                CGAffineTransform(scaleX: self.squarePopMaxScale, y: self.squarePopMaxScale))
        },
        completion: { finished in
            //shrink the square after pop animation
            UIView.animate(withDuration: self.squareContractTime) {
                square.layer.setAffineTransform(CGAffineTransform.identity)
            }
        })

    }
}
