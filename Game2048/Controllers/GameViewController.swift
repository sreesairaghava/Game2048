//
//  ViewController.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

class GameViewController: UIViewController {
    //Board dimensions
    var dimension: Int
    //The value of the winning square
    var limit: Int
    // Board view instance
    var board: GameboardView?
    var play: GamePlay?
    
    
    //Init()
    init(dimension d: Int, limit l: Int) {
        //If dimension of the game is less than 2 make dimension as 2
        dimension = d > 2 ? d : 2
        limit = l >  8 ? l : 8
        super.init(nibName: nil, bundle: nil)
        play = GamePlay(dimension: dimension, limit: limit, delegate: self)
        view.backgroundColor = UIColor.white
    }
    required init?(coder: NSCoder) {
        fatalError("NScoding is not supported!..")
    }
    // View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        setupGame()
    }
    
    func setupGame() {
        let gameboard = GameboardView(
            dimension: 4,
            cornerRadius: 8,
            squareWidth: 60,
            squarePadding: 5,
            backgroundColor: UIColor.black,
            foregroundColor: UIColor.darkGray
        )
        // Frames
        gameboard.center = view.center
        board = gameboard
        assert(play != nil)
        let p = play!
        p.insertSquareAtRandomLocation(withValue: 2)
        p.insertSquareAtRandomLocation(withValue: 32)
        view.addSubview(gameboard)
    }

}

extension GameViewController: GamePlayProtocol{
    func scoreChanged(to score: Int) {
    }
    
    func moveOneSquare(from: (Int, Int), to: (Int, Int), number: Int) {
        
    }
    
    func moveTwoSquare(from: ((Int, Int), (Int, Int)), to: (Int, Int), number: Int) {
        
    }
    
    func insertSquare(at location: (Int, Int), withNumber number: Int) {
        assert(board != nil)
        let b = board!
        b.insertSquare(at: location, number: number)
    }
    
    
}
