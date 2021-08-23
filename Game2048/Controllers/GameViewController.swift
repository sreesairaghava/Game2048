//
//  ViewController.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

class GameViewController: UIViewController {
    
    // How many squares in both directions the gameboard contains
    var dimension: Int
    // The value of the winning square
    var limit: Int
    var board: GameboardView?
    var play: GamePlay?
    
    var scoreView: ScoreViewProtocol?
    
    // Game Appearance
    let boardWidth: CGFloat = 230.0
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    // Amount of space to place between the different component views (gameboard, score view, etc)
    let viewPadding: CGFloat = 10.0
    
    // Amount that the vertical alignment of the component views should differ from if they were centered
    let verticalViewOffset: CGFloat = 0.0
    
    init(dimension d: Int, limit l: Int) {
        dimension = d > 2 ? d : 2
        limit = l > 8 ? l : 8
        super.init(nibName: nil, bundle: nil)
        play = GamePlay(dimension: dimension, limit: limit, delegate: self)
        view.backgroundColor = UIColor.white
        setupSwipeControls()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupGame() {
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
        // This nested function provides the x-position for a component view
        func xPositionToCenterView(_ v: UIView) -> CGFloat {
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vcWidth - viewWidth)
            return tentativeX >= 0 ? tentativeX : 0
        }
        // This nested function provides the y-position for a component view
        func yPositionForViewAtPosition(_ order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            //      let viewHeight = views[order].bounds.size.height
            let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
            let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0
            
            // Not sure how to slice an array yet
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        // Create the score view
        let scoreView = ScoreView(backgroundColor: UIColor.black,
                                  textColor: UIColor.white,
                                  font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0),
                                  radius: 6)
        scoreView.score = 0
        
        // Create the gameboard
        let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameboardView(dimension: dimension,
                                      squareWidth: width,
                                      squarePadding: padding,
                                      cornerRadius: 6,
                                      backgroundColor: UIColor.black,
                                      foregroundColor: UIColor.darkGray)
        
        // Set up the frames
        let views = [scoreView, gameboard]
        
        var f = scoreView.frame
        f.origin.x = xPositionToCenterView(scoreView)
        f.origin.y = yPositionForViewAtPosition(0, views: views)
        scoreView.frame = f
        
        f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionForViewAtPosition(1, views: views)
        gameboard.frame = f
        
        
        // Add to game state
        view.addSubview(gameboard)
        board = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
        
        assert(play != nil)
        let p = play!
        p.insertsquareAtRandomLocation(withValue: 2)
        p.insertsquareAtRandomLocation(withValue: 2)
    }
    
    func followUp(){
        assert(play != nil)
        let p = play!
        let randomVal = Int(arc4random_uniform(10))
        p.insertsquareAtRandomLocation(withValue: randomVal == 1 ? 4 : 2)
    }
    
    func setupSwipeControls() {
        view.addGestureRecognizer(createSwipeGestureRecognizer(for: .up, vc: self))
        view.addGestureRecognizer(createSwipeGestureRecognizer(for: .down, vc: self))
        view.addGestureRecognizer(createSwipeGestureRecognizer(for: .left, vc: self))
        view.addGestureRecognizer(createSwipeGestureRecognizer(for: .right, vc: self))
    }
    
        @objc func didSwipe(_ sender: UISwipeGestureRecognizer){
            assert(play != nil)
            let p = play!
            switch sender.direction {
            case .up:
                p.queueMove(direction: .up) { finished in
                    if finished{
                        //follow up function
                        self.followUp()
                    }
                }
            case .down:
                p.queueMove(direction: .down) { finished in
                    if finished{
                        self.followUp()
                    }
                }
            case .left:
                p.queueMove(direction: .left) { finished in
                    if finished{
                        // follow up func call
                        self.followUp()
                    }
                }
            case .right:
                p.queueMove(direction: .right) { finished in
                    if finished{
                        self.followUp()
                    }
                }
            default:
                break
            }
        }
    
    //MARK: - Helper Methods
    private func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction, vc: UIViewController) -> UIGestureRecognizer{
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: vc.self, action: #selector(didSwipe(_:)))
        // Configure swipe Gesture Recognizer
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        swipeGestureRecognizer.direction = direction
        return swipeGestureRecognizer
    }
}

extension GameViewController: GamePlayProtocol{
    func scoreChanged(to score: Int) {
        if scoreView == nil {
            return
        }
        let s = scoreView!
        s.scoreChanged(to: score)
    }
    
    func moveOneSquare(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveOnesquare(from: from, to: to, value: value)
    }
    
    func moveTwoSquares(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveTwosquares(from: from, to: to, value: value)
    }
    
    func insertSquare(at location: (Int, Int), withValue value: Int) {
        assert(board != nil)
        let b = board!
        b.insertSquare(at: location, value: value)
    }
}
